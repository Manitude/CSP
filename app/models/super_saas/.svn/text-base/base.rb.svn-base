module SuperSaas
  class Base < ::ActiveResource::Base

    include RosettaStone::YamlSettings
    yaml_settings(:config_file => 'super_saas.yml', :hash_reader => false)
    unless Ambient.connection_type
      Ambient.init
      Ambient.connection_type = 'supersaas1'
    end
    self.site     = settings[:host]
    self.proxy    = settings[:proxy_host]
    self.user     = settings[Ambient.connection_type][:username]
    self.password = settings[Ambient.connection_type][:password]
    self.timeout  = 300

    class << self

      def within_rescuer(handle_down = false)
        begin
          yield if block_given?
        rescue ActiveResource::ResourceNotFound
          Rails.logger.error("Data not found.")
          return nil
        rescue ArgumentError
          return nil
        rescue Errno::ECONNREFUSED
          Rails.logger.error("Connection refused from eschool.")
          return (handle_down ? {:connection_refused => true} : nil)
        rescue ActiveResource::ServerError
          Rails.logger.error("Eschool ServerError.")
          return nil
        rescue Exception => ex
          Rails.logger.error(ex.message)
          HoptoadNotifier.notify(ex)
          return nil
        end
      end

      def get_schedule_id(language_identifier,number_of_seats)
        settings[:schedule_id][get_schedule_name(language_identifier,number_of_seats)]
      end

      def get_schedule_name(language_identifier,number_of_seats)
        language_identifier += "G" if number_of_seats.to_i > 1
        SUPER_SAAS_SCHEDULE_NAME[language_identifier]
      end

      def get_connection
        Net::HTTP::Proxy(proxy.try(:host),proxy.try(:port)).new(site.host)
      end

      def get_md5_checksum(user_guid)
        Digest::MD5.hexdigest("#{settings[Ambient.connection_type][:username]}#{settings[Ambient.connection_type][:password]}#{user_guid}")
      end

      def reset_credentials(connection_type)
        self.user = settings[connection_type][:username]
        self.password = settings[connection_type][:password]
      end
    end
  end
end
