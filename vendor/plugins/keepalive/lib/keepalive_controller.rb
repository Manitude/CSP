module RosettaStone
  module KeepAlive

    class KeepaliveController < ActionController::Base
      MAX_WARM_UP_TO = 40
      STARTUP_WAIT_TIME = 10 #seconds
      #Options that we only allow from inside Rosetta Stone
      ADVANCED_OPTIONS = [:response_size, :warm_up_to, :num_dispatches, :warm_up]
      include RosettaStone::PrefixedLogger

      # in Rails 2.3+, there is no longer any need to explicitly disable session support
      session :disabled => true if RosettaStone::RailsVersionString < RosettaStone::VersionString.new(2,3,0)

      before_filter :verify_ip

      def index
        PulseChecker.check_all!

        # ---------------------------
        # dispatch "warm-up" support
        # ---------------------------
        #
        # this is intended to be used to start up a number of dispatch.fcgi processes when using
        # something like mod_fcgid.  ghetto style.
        #
        # when warm_up_to=N, we quickly fire off N warm_up requests (warm_up=true) to ourselves.
        # when warm_up=true, we tie up the current dispatch... by sleeping for a few seconds.
        #
        # like i said, ghetto style!
        #
        # typical usage would be like the following, executed from a given application server:
        #
        # curl --proxy localhost:80 http://launch.rosettastone.com/keepalive?warm_up_to=15
        #
        if params[:warm_up] == 'true'
          logger.info("WARM UP: request from #{request.remote_ip}")
          sleep(STARTUP_WAIT_TIME)
        end

        if params[:num_dispatches]
          logger.info("NUM_DISPATCHES: request from #{request.remote_ip}")
          render :text => current_process_count.to_s and return
        end

        warm_up_to = params[:warm_up_to].to_i
        warm_up_to = [warm_up_to,MAX_WARM_UP_TO].min
        if warm_up_to > 0
          logger.info("WARM UP TO: #{warm_up_to}")
          if current_process_count > warm_up_to
            logger.info("WARM UP TO: ignoring, current process count is #{current_process_count}")
          else
            warm_up_url = "#{request.host_with_port}#{request.path}?warm_up=true"
            (warm_up_to).times do
              system(%Q[curl --silent --proxy localhost:80 "#{warm_up_url}" &])
            end
          end
        end

        response_size = params[:response_size].to_i
        if response_size > 0 && response_size < 65536
          render :text => (1..response_size).inject('') {|string,count| string << rand(10).to_s}
        else
          render :nothing => true
        end
      end

      private

      def has_advanced_actions?
        (params.keys.map(&:to_sym) & ADVANCED_OPTIONS).size > 0
      end

      def verify_ip
        #We allow the simple ping to be hit from external IPs,
        #but the risky stuff is restricted to internal-network only
        return true unless has_advanced_actions?
        begin
          ip = IPAddr.new(request.remote_ip)
        rescue ArgumentError
          logger.error("Could not parse remote IP address '#{request.remote_ip}'.  Disallowing access.")
          render(:nothing => true, :status => 404) and return false
        end

        self.class.ip_range_list.each do |ip_range|
          return true if ip_range.include?(ip)
        end

        logger.error("Remote IP address not allowed to hit keepalive '#{request.remote_ip}'.  Disallowing access.")
        render(:nothing => true, :status => 404) and return false
      end

      # override perform_action and log_processing in actionpack so we don't log keepalive controller hits.
      # see https://trac.lan.flt/opx/ticket/1846 for the reasoning.
      # this will obviously need to change if these method names change in rails.
      # Note: this only works in Rails 2.x.
      def perform_action
        perform_action_without_benchmark # which does not log anything
      end

      def log_processing
        # do nothing
      end

      def current_process_count
        `pgrep -f "#{request.env['DOCUMENT_ROOT']}" | wc -l`.to_i
      end

      include RosettaStone::OverridableYamlSettings
      overridable_yaml_settings(:config_file => "keepalive_hosts",
        :hash_reader => true,
        :use_method_access => false,
        :defaults_root_dir => File.expand_path('../', File.dirname(__FILE__))
      )

      def self.ip_range_list
        @ip_range_list ||= all_settings[Rails.env].collect do |ip_string|
          IPAddr.new(ip_string)
        end
      end
    end

  end # KeepAlive
end

# Defeats the point of the namespacing, but i can't be bothered fighting with the totally broken Rails dependency loading
KeepaliveController = RosettaStone::KeepAlive::KeepaliveController
