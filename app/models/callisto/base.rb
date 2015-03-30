require 'rubygems'
require 'net/http'
require 'openssl'
require 'addressable/uri'
require 'base64'
module Callisto
 class Base < ::ActiveResource::Base
        include RosettaStone::YamlSettings
         yaml_settings(:config_file => 'aria_integration.yml', :hash_reader => false)
         self.proxy    = settings[:proxy_host]
      class << self
      
    #Returns an authentication token to be sent along with all Callisto calls.  
    def get_auth_token()
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
      return bearer
   
  end

  #Method to pull in the complete list of topics present in Biblio.
  def get_all_topics()
    begin
      bearer = get_auth_token() #Returns an authentication(bearer) token to be sent along with all Biblio calls.
      puts bearer
      if instance_name == "production"
        curl_request =  %Q@curl --url 'http://#{settings[:biblio_url]}/asset/groupTopics' --proxy #{proxy} -k --request GET -H 'Accept: application/json' -H 'Authorization: Bearer #{bearer}'@
      else
        curl_request =  %Q@curl --url 'http://#{settings[:biblio_url]}/asset/groupTopics' --request GET -H 'Accept: application/json' -H 'Authorization: Bearer #{bearer}'@
      end  
      puts curl_request
      response = `#{curl_request}`
      response_array = JSON.parse(response)["data"]
      return response_array
    rescue Exception=>ex
      Rails.logger.error(ex.message)
      HoptoadNotifier.notify(ex)
      return nil
    end
  end

  #Module to create a new coach in callisto. Check if the coach is created in "admin.callisto.io". User can loggin from editor.callisto.io
  # Returns an array as response. Sample response is as follows,

  # ["lastName", "TotaleAria", "language", "en", "level", "C1", "firstName", "Totalearia", 
  #  "organization", "0b0e71af5e82725587827d024cd9f05a", "email", "Totale_aria1@gmail.com", 
  #  "type", "User", "_id", "fe2d3890-fcde-4d45-98d7-00075fdaa14d", "client", "TODO", 
  #  "creationDate", "2014-03-27T11:53:13+0000", "creator", "fe2d3890-fcde-4d45-98d7-00075fdaa14d", 
  #  "modificationDate", "2014-03-27T11:53:13+0000", "registrationDate", "2014-03-27T11:53:13+0000", 
  #  "wallet", "23c7b4e6-4542-4934-ade9-9be93d59fa94", "_rev", "1-61c7cbf2fb15e54d21efa41933c5ea3d"]

   #Module to update an existing coach in callisto. Returns an array as response. Sample response is as follows,
  # #=> ["creator", "fe2d3890-fcde-4d45-98d7-00075fdaa14d", 
 #    "lastName", "TotaleAria", "creationDate", "2014-03-27T11:53:13+0000", "profileIcon", 
 #  "a9159d92-96c1-433c-b8a7-47579d671592", "wallet", "23c7b4e6-4542-4934-ade9-9be93d59fa94", 
 # "language", "en", "level", "C1", "firstName", "Totalearia", "_rev", 
 # "3-dccd294127fbae8b04a753673569e00f", "organization", "0b0e71af5e82725587827d024cd9f05a",
 #  "salt", "35fda259-a9ff-4900-9c8c-9b23f932f7cd", "modificationDate", "2014-03-27T13:56:43+0000",
 #   "email", "Totale_aria@gmail.com", "type", "User", "_id", "fe2d3890-fcde-4d45-98d7-00075fdaa14d", 
 #   "registrationDate", "2014-03-27T11:53:13+0000", "client", "TODO", 
 #   "password", "oSM1RMP0pN+uWar7liZ0w0DLMbc="]
  def validateSingleQuote(text)
    text.gsub("'", "\\u0027")
  end

  def instance_name
    RosettaStone::InstanceDetection.instance_name
  end 

  def create_or_update_coach_in_callisto(action,coach,language)
      bearer = get_auth_token
      language = language == "AUS" ? "en-US" : "en-GB"
      pref_name = validateSingleQuote(coach.preferred_name)
      full_name = validateSingleQuote(coach.full_name)
      if action == "create"
        if instance_name == "production"
          curl_request =  %Q@curl 'https://#{settings[:host_url]}/users' --proxy #{proxy} -k -H 'Authorization: Bearer #{bearer}' -H 'Content-Type: application/json' -d '{"email":"#{coach.rs_email}", "firstName":"#{pref_name}","lastName":"#{full_name}","password":"#{settings[:coach_password]}","subtype":"#{settings[:sub_type]}","_id":"#{coach.coach_guid}", "targetLanguage": {"language" : "#{language}"}}'@
        else
          curl_request =  %Q@curl 'https://#{settings[:host_url]}/users' -H 'Authorization: Bearer #{bearer}' -H 'Content-Type: application/json' -d '{"email":"#{coach.rs_email}", "firstName":"#{pref_name}","lastName":"#{full_name}","password":"#{settings[:coach_password]}","subtype":"#{settings[:sub_type]}","_id":"#{coach.coach_guid}", "targetLanguage": {"language" : "#{language}"}}'@
        end  
      elsif action == "update"
        if instance_name == "production"
          curl_request =  %Q@curl --request PUT 'https://#{settings[:host_url]}/users/#{coach.coach_guid}/identifying_attributes' --proxy #{proxy} -k -H 'Authorization: Bearer #{bearer}' -H 'Content-Type: application/json' -d '{"email":"#{coach.rs_email}","firstName":"#{pref_name}","lastName":"#{full_name}"}'@
        else
          curl_request =  %Q@curl --request PUT 'https://#{settings[:host_url]}/users/#{coach.coach_guid}/identifying_attributes' -H 'Authorization: Bearer #{bearer}' -H 'Content-Type: application/json' -d '{"email":"#{coach.rs_email}","firstName":"#{pref_name}","lastName":"#{full_name}"}'@
        end  
      end
      puts curl_request
      response = `#{curl_request}`
      response_array = response.scan /"([^"]+)":"([^"]+)"/
      puts response_array
      return response_array.flatten
  end

#Module to get the aria learner's level 

  def get_learner_level(learner_guid)
    bearer = get_auth_token
    if instance_name == "production"
      curl_request =  %Q@curl --request GET 'https://#{settings[:host_url]}/users/#{learner_guid}' --proxy #{proxy} -k -H 'Authorization: Bearer #{bearer}'@
    else
      curl_request =  %Q@curl --request GET 'https://#{settings[:host_url]}/users/#{learner_guid}' -H 'Authorization: Bearer #{bearer}'@
    end  
      puts curl_request
      response = `#{curl_request}`
      response_array = response.scan /"([^"]+)":"([^"]+)"/
      level = nil
      response_array.each do |pair|
         level = pair[1] if pair[0] == 'level'
      end
      return level
  end
 end
end
end



