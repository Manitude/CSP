module SuperSaas
  class Coach < Base
    class << self

      def custom_method_collection_url(method_name, options = {})
        prefix_options, query_options = split_options(options)
        "/api/users/#{method_name}#{query_string(query_options)}"
      end

      def find_by_guid(guid)
        within_rescuer do
          SuperSaas::Coach.new(get guid)
        end
      end

      def create_or_update(coach, connection_type)
        reset_credentials(connection_type)
        within_rescuer do
          put coach.coach_guid, {"user[email]" => coach.rs_email, "user[credit]"=>"-", "user[full_name]" => coach.full_name}
        end
      end
      
    end
  end
end