module Eschool
  class JsonBase < ::ActiveResource::Base

    include RosettaStone::YamlSettings
    yaml_settings(:config_file => 'eschool.yml', :hash_reader => false)
    self.site     = settings[:host]
    self.proxy    = settings[:proxy_host]
    self.user     = settings[:username]
    self.password = settings[:password]
    self.timeout = 150
    self.format = :json
    
    class << self
      alias :super_headers :headers
      def headers
        super_headers['X-CSP-Audit'] = Thread.current[:user_details] || "Unknown - Unknown"
        super_headers
      end

      def within_eschool_rescuer(handle_eschool_down = false)
        begin
          yield if block_given?
        rescue ActiveResource::ResourceNotFound
          Rails.logger.error("Data not found.")
          return nil
        rescue Errno::ECONNREFUSED
          Rails.logger.error("Connection refused from eschool.")
          return (handle_eschool_down ? {:connection_refused => true} : nil)
        rescue ActiveResource::ServerError
          Rails.logger.error("Eschool ServerError.")
          return nil
        rescue Exception => ex
          Rails.logger.error(ex.message)
          HoptoadNotifier.notify(ex)
          return nil
        end
      end
    end

  end
end
