require 'net/http'
require 'json'
module AdobeConnect

 class Base < ::ActiveResource::Base
	
    include RosettaStone::YamlSettings
         yaml_settings(:config_file => 'adobe_connect.yml', :hash_reader => false)
         self.proxy       = settings[:proxy_host]
         self.user        = settings[:username]
         self.password    = settings[:password]
         self.timeout = 30
    class << self

        def provide_launch_link(supersaas_id, user_id, host_uri=settings[:host_uri])
            # login_id may be either coach's guid or CM/Support Agent's email address.
            user = Account.find_by_id(user_id)
            login_id = user.is_coach? ? user.coach_guid : user.email
            cs    = ConfirmedSession.find_by_eschool_session_id(supersaas_id)
            @http = Net::HTTP::Proxy(proxy.try(:host),proxy.try(:port)).new(host_uri, 443)
            @http.use_ssl = true
            @cookie=login_as_admin
            #Check if the coach exists in Adobe Connect, if not return false. New profile will not be created.
            #returning false indicates user does not exist in adobe connect
            #returning nil indicates login failed

            adobe_user_id = find_user(login_id)
            #Check if the user doesn't exist and create profile if the user is a CM/Support Agent.
            adobe_user_id = create_user(user.email) if !adobe_user_id && !user.is_coach?
            return false unless adobe_user_id

            #AdobeConnect accepts meeting ids starting with character only. Agreed across applications to prepend "m"
            supersaas_id = "m"+supersaas_id.to_s

            # First try to create a meeting. If create meeting fails, find the meeting for the supersaas id
            adobe_meeting_id = create_meeting(supersaas_id,cs.session_start_time)
            adobe_meeting_id = find_meeting(supersaas_id) unless adobe_meeting_id

            add_status = quick_add_user_to_meeting(adobe_user_id, adobe_meeting_id)
            
            ret_url = generate_launch_link(login_id,supersaas_id) if add_status
            return ret_url
        end

        def one_time_login
            @http = Net::HTTP::Proxy(proxy.try(:host),proxy.try(:port)).new(host_uri=settings[:host_uri], 443)
            @http.use_ssl = true
            path = '/api/xml?action=common-info'
            cookie = @http.get(path).response['set-cookie']
            puts cookie
            path1 = '/api/xml?'
            puts "Username is #{settings['username']}"
            data_map = {"login" => settings["username"],"password" => settings["password"],"action"=>"login"}           
            cookie_post = @http.post(path1,data_map.to_query,{"Cookie" => cookie}).response['set-cookie']
            cookie = cookie_post if cookie_post && cookie_post.match(/^BREEZESESSION/)
            return cookie 
        end

        def users_in_meeting_logged_in(supersaas_id, cookie)
            data_map = {
                'action'=> 'sco-contents',
                'sco-id'=> settings["meeting_folder_id"],
                'filter-type'=> 'meeting',
                'filter-url-path'=>  "/m#{supersaas_id}/" #"/meet#{supersaas_id}/"
                }
            raw_response = call_api(data_map,cookie)
            resp = LibXML::XML::Parser.string(raw_response.body).parse
            puts "--users_in_meeting_logged_in--"
            sco_id = resp.find('//sco').first.try(:property,"sco-id")
            if sco_id
                data_map = {
                    'action'=> 'report-meeting-attendance',
                    'sco-id'=> sco_id,
                    }
                resp = call_api(data_map,cookie).body
                puts resp 
                return resp 
            end
            return nil
        end

    	def login_as_admin
            #Log in as administrator
            #Returns cookie(string) on successful login, else nil
			path = '/api/xml?action=common-info'
			cookie = @http.get(path).response['set-cookie']
            puts cookie
			path1 = '/api/xml?'
            puts "Username is #{settings['username']}"
			data_map = {"login" => settings["username"],"password" => settings["password"],"action"=>"login"}			
			cookie_post = @http.post(path1,data_map.to_query,{"Cookie" => cookie}).response['set-cookie']
            cookie = cookie_post if cookie_post && cookie_post.match(/^BREEZESESSION/)
            return cookie 
    	end

        def call_api(data_map, cookie=@cookie)
            @http ||= Net::HTTP::Proxy(proxy.try(:host),proxy.try(:port)).new(host_uri=settings[:host_uri], 443)
            @http.use_ssl = true
            path='/api/xml?'
            resp = @http.post(path,data_map.to_query,{"Cookie" => cookie})
            return resp
        end

    	def create_user(email)
            #Creates a user in adobe connect
            #Returns the adobe connect id for the created user
            data_map = {
            'first-name'=> 'Rosetta Stone',
            'last-name'=> 'Support',
            'email'=> email,
            'login'=> email,
            'password' => settings["user_password"],
            'send-email'=> 'false',
            'has-children'=> '0',
            'type'=> 'user',
            'action'=>'principal-update'
            }
            resp = LibXML::XML::Parser.string(call_api(data_map).body).parse
            puts resp
            return resp.find('//principal').first.try(:property,"principal-id")
    	end

        def find_user(guid)
            #Find user using the guid
            #Returns the adobe connect id for the user if present, else nil
             data_map = {
            'action'=> 'principal-list',
            'filter-type'=> 'user',
            'filter-login'=> guid
            }   
            resp = LibXML::XML::Parser.string(call_api(data_map).body).parse
            principal_id = resp.find('//principal').first.try(:property,"principal-id")
            if principal_id
                data_map = {
                'action'=> 'principal-info',
                'principal-id'=> principal_id
                }
                resp = LibXML::XML::Parser.string(call_api(data_map).body).parse
                puts resp
                return resp.find('//principal').first.try(:property,"principal-id")
                #return positive code indicating user has adobe connect id
            else
                puts "NOT FOUND"
            end
            return false
        end

        def create_meeting(supersaas_id, session_start_time)
            #Create a meeting in adobe connect for the supersaas_id, for session_start_time
            #Returns the sco_id for the session            
            start_time = DateTime.strptime(session_start_time.strftime("%Y-%m-%dT%H:%M"),"%Y-%m-%dT%H:%M") 
            end_time = start_time + 60.minutes
             data_map = {
            'action'=> 'sco-update',
            'type'=> 'meeting',
            'name'=> "Live Session: #{supersaas_id}",
            'folder-id'=> settings["meeting_folder_id"],
            'source-sco-id' => settings["template_id"],
            'date-begin'=> start_time,
            'date-end'=> end_time,
            'url-path'=> "#{supersaas_id}"
            }
            resp = LibXML::XML::Parser.string(call_api(data_map).body).parse
            puts resp
            return resp.find('//sco').first.try(:property,"sco-id")
        end

        def find_meeting(supersaas_id)
            #Finds meeting using  meet#{supersass_id}
            #Returns the sco_id if available, else nil
            data_map = {
            'action'=> 'sco-contents',
            'sco-id'=> settings["meeting_folder_id"],
            'filter-type'=> 'meeting',
            'filter-url-path'=> "/#{supersaas_id}/"
            }
            resp = LibXML::XML::Parser.string(call_api(data_map).body).parse 
            sco_id = resp.find('//sco').first.try(:property,"sco-id")
            if sco_id
                data_map = {
                'action'=> 'sco-info',
                'sco-id'=> sco_id
                }
                resp = LibXML::XML::Parser.string(call_api(data_map).body).parse
                puts resp
                return resp.find('//sco').first.try(:property,"sco-id")
            else
                puts "NOT FOUND"
            end
            return false
        end

        def users_in_meeting(supersaas_id)
            #Returns the number of users currently inside the meeting room
            #To be used only after checking if such a meeting exists, using find_meeting
            data_map = {
                'action'=> 'sco-contents',
                'sco-id'=> settings["meeting_folder_id"],
                'filter-type'=> 'meeting',
                'filter-url-path'=>  "/#{supersaas_id}/" #"/meet#{supersaas_id}/"
                }
            resp = LibXML::XML::Parser.string(call_api(data_map).body).parse
            puts resp 
            sco_id = resp.find('//sco').first.try(:property,"sco-id")
            if sco_id
                data_map = {
                    'action'=> 'report-meeting-attendance',
                    'sco-id'=> sco_id,
                    }
                resp = LibXML::XML::Parser.string(call_api(data_map).body).parse
                puts resp    
            end
        end

        def quick_add_user_to_meeting(principal_id, sco_id) 
            data_map = {
                'action'=> 'permissions-update',
                'acl-id'=> sco_id,
                'principal-id'=> principal_id,
                'permission-id'=> "host"
                }
            resp = LibXML::XML::Parser.string(call_api(data_map).body).parse
            puts resp
            return true
        end

        def add_user_to_meeting(guid, supersaas_id)
            #Adds a user to a meeting
            #true/false is returned depending on success/failure
            change_user_permission_on_meeting(guid,supersaas_id,"host")
        end

        def change_user_permission_on_meeting(guid, supersaas_id, permission)
            errors=[]
            data_map = {
           'action'=> 'principal-list',
            'filter-type'=> 'user',
            'filter-login'=> guid
            }
            resp = LibXML::XML::Parser.string(call_api(data_map).body).parse
            puts resp
            principal_id = resp.find('//principal').first.try(:property,"principal-id")
            if principal_id.nil? 
                errors<< "No user found with GUID #{guid}"
            end
            data_map = {
            'action'=> 'sco-contents',
            'sco-id'=> settings["meeting_folder_id"],
            'filter-type'=> 'meeting',
            'filter-url-path'=> "/#{supersaas_id}/"
            }
            resp = LibXML::XML::Parser.string(call_api(data_map).body).parse
            puts resp
            sco_id = resp.find('//sco').first.try(:property,"sco-id")
            if sco_id.nil? 
                errors<< "No meeting found with meeting id #{supersaas_id}"
            end
            if errors.empty?
                data_map = {
                'action'=> 'permissions-update',
                'acl-id'=> sco_id,
                'principal-id'=> principal_id,
                'permission-id'=> permission
                }
                resp = LibXML::XML::Parser.string(call_api(data_map).body).parse
                puts resp
                return true
            else
                puts errors.join("\n")
                return false
            end
        end

        def login_and_get_session_value(guid)
            #Logs in as the user ( coach in the case of CSP )
            #Returns session value on successful login, else nil

            path = '/api/xml?action=common-info'
            cookie = @http.get(path).response['set-cookie']
            path1 = '/api/xml?'
            data_map = {"login" => guid,"password" => settings["user_password"],"action"=>"login"}
            resp = call_api(data_map,cookie)
            response = LibXML::XML::Parser.string(resp.body).parse
            cookie_post = resp.response['set-cookie']
            cookie = cookie_post if cookie_post && cookie_post.match(/^BREEZESESSION/)
            stat_code = response.find('//status').first.try(:property,"code")
            if stat_code=="ok" and (res=Rack::Utils.parse_nested_query(cookie)).has_key?("BREEZESESSION")
                session_value = res["BREEZESESSION"] 
            else
                return nil
            end
        end

        def generate_launch_link(guid,supersaas_id)
            #Generates the launch link for adobe connect meeting
            #Returns the url on success, nil on failure
            session_value=login_and_get_session_value(guid)
            if session_value
                puts "https://#{settings['host_uri']}/#{supersaas_id}?launcher=false&session=#{session_value}"
                return "https://#{settings['host_uri']}/#{supersaas_id}?launcher=false&session=#{session_value}"
            else
                puts "USER LOGIN FAILED"
                return nil
            end
        end
    end
 end
end
