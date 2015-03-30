ENV['RAILS_ENV'] = 'test'
require File.dirname(__FILE__) + '/../../../../config/environment.rb' unless defined?(RAILS_ROOT)

module RosettaStone
  module Baffling

    # Mocking client, used by the main ApiClient class, when in test mode.
    class MockHttpClient
      attr_accessor :requests
      attr_accessor :http_options

      def get(request_path)
        requests << request_path
        # return successful response        
        OpenStruct.new(:status => '200', :body => '<user_details><social_apps><total><seconds>5</seconds></total></social_apps><total_rs_time>3675</total_rs_time></user_details>')
      end

      def initialize(opts)
        self.http_options = opts
        self.requests = []
      end
    end

    class ApiClient

    private
      def desired_http_client
        MockHttpClient.new(default_simplehttp_options)
      end
    end
  end
end
