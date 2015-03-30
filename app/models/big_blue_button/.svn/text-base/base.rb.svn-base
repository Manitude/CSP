require 'rubygems'
require 'net/http'
require 'openssl'
require 'addressable/uri'
require 'base64'
module BigBlueButton
  # BBB launch : Determine the server host for the given learner by hitting the curl request. Launch the coach to that host. 
  # If no learner, launch coach to default host
 class Base < ::ActiveResource::Base
        include RosettaStone::YamlSettings
         yaml_settings(:config_file => 'aria_integration.yml', :hash_reader => false)
         self.proxy    = settings[:proxy_host]
      class << self
        def form_url(action,meetingID,student_guid = "None",fullName = nil,userID = nil)
          response_array = []
          if student_guid == "None"
              response_array[1] = settings[:url]
          else
              response_array = determine_server_host(student_guid,meetingID) 
          end
                if action == "create"
                        params = {:meetingID => meetingID,
                                  :attendeePW => settings[:attendeePW],
                                  :moderatorPW => settings[:moderatorPW],
                                  :record => settings[:record],
                                  :name => settings[:name]
                                }
                  elsif action == "join"
                        params = {:fullName => fullName,
                                  :meetingID => meetingID,
                                  :userID => userID,
                                  :password => settings[:moderatorPW]
                                  }
                  end
        data = params.to_query
        checksum = generate_checksum(action,data)
        if action == "create"
          url = "https://#{response_array[1]}/bigbluebutton/api/#{action}?"+"#{data}&checksum="+checksum
        else
          url = "http://#{response_array[1]}/bigbluebutton/api/#{action}?"+"#{data}&checksum="+checksum
        end
        url_parsed = URI.parse(url)
        http = Net::HTTP::Proxy(proxy.try(:host),proxy.try(:port)).new(url_parsed.host, url_parsed.port)
        http.use_ssl = true if action == "create"
        response = http.get(url_parsed.request_uri)
        return response.code,url_parsed
        end
        def generate_checksum(action,data)
                data = action+data+settings[:salt]
                return Digest::SHA1.hexdigest(data)
        end
    def determine_server_host(student_guid,meeting_id)
      http = Net::HTTP::Proxy(proxy.try(:host),proxy.try(:port)).new(settings[:auth_host_url],443)
      http.use_ssl = true
      postData = { "grant_type" => "password", "client_id" => settings[:CLIENT_ID], "username" => settings[:username], "password" => settings[:password]}
      response = http.post('/oauth/token',postData.to_query)
      if response.code != '200'
         raise "Bad response code #{response.code}"
      end
      pairs = response.body.scan /"([^"]+)":"([^"]+)"/
      userID = nil
      bearer = nil
      pairs.each do |pair|
         userID = pair[1] if pair[0] == 'userId'
         bearer = pair[1] if pair[0] == 'access_token'
      end
      if userID.nil? || bearer.nil?
         raise "Could not find userID or bearer in response: #{response.body}"
      end
      puts "cURL snippet for use hosts api:"
      known_instances = RosettaStone::InstanceDetection.known_instances.keys
      instance_name = RosettaStone::InstanceDetection.instance_name
      if instance_name == "production"
        user_host =  %Q@curl 'https://#{settings[:host_url]}/schedule/hosts' --proxy #{proxy} -k -H 'Authorization: Bearer #{bearer}' -H 'Content-Type: application/json' -d '{"data": [["#{student_guid}", "#{meeting_id}"]]}'@
      else
        user_host =  %Q@curl 'https://#{settings[:host_url]}/schedule/hosts' -H 'Authorization: Bearer #{bearer}' -H 'Content-Type: application/json' -d '{"data": [["#{student_guid}", "#{meeting_id}"]]}'@
      end  
      user_host_response = `#{user_host}`
      response_array = user_host_response.scan /"([^"]+)":"([^"]+)"/
      return response_array.flatten
   end
   
  end
 end
end