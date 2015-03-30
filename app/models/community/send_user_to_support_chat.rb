module Community
  class SendUserToSupportChat < ApiAuth

    def self.custom_method_collection_url(method_name, options = {})
      prefix_options, query_options = split_options(options)
      if method_name == :send_user_to_support_chat
        "/api/support/#{method_name}#{query_string(query_options)}"
      else
        "#{prefix(prefix_options)}#{collection_name}/#{method_name}.#{format.extension}#{query_string(query_options)}"
      end
    end

    def self.send_user_to_support_chat(guid,support_url)
      post :send_user_to_support_chat, {:request => {:user_guid => guid, :support_chat_url => support_url}}
    end

  end
end
