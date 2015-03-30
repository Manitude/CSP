module Locos
  class Lotus
    include RosettaStone::YamlSettings
    yaml_settings(:config_file => 'locos.yml', :hash_reader => false)
    
    class << self

      def find_learners_in_dts
        within_locos_rescuer do
          http = SimpleHTTP::Client.new settings[:locos]
          response = http.get('/app_metrics/active_session_count')
          response.body.to_i
        end
      end
      
      def find_active_session_details_by_activity
        within_locos_rescuer do
          http = SimpleHTTP::Client.new settings[:locos]
          response = http.get('/app_metrics/active_session_details_by_activity_2')
          raise Exception.new("LoCoS did not respond well!") if !response.success?
          ActiveSupport::JSON.decode response.body
        end
      end

      private

      def within_locos_rescuer
        begin
          yield if block_given?
        rescue Exception => ee
          HoptoadNotifier.notify(ee)
          return nil
        end
      end
      
    end
  end
end
