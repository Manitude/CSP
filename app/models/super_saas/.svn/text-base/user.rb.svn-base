module SuperSaas
  class User < Base
    class << self
      def login_as_admin
        http =  get_connection
        path = '/dashboard/login.html'
        cookie = http.get(path, nil).response['set-cookie']
        data_map = {"password"=> password, "name"=> user, "utf8"=>"%E2%9C%93", "remember"=>"K"}
        http.post(path, data_map.to_query,{"Cookie" => cookie}).response['set-cookie']
      end  

      def login_as_coach(coach)
        http =  get_connection
        data_map = {
                      "account" => user,
                      "password"=> password
                      }
        path = "/api/users/#{coach.coach_guid}?#{ data_map.to_query}"
        coach_id = LibXML::XML::Document.string(http.get(path).body).find("id").first.content
        cookie = login_as_admin
        path = "/users/act_as/#{coach_id}"
        cookie_user = http.post(path, nil,{"Cookie" => cookie}).response['set-cookie'].split(" ")
        cookie_admin = cookie.split(" ")
        cookie_admin[cookie_admin.index(cookie_admin.detect{|i| (i =~ /^_SS_s/)==0 })] = cookie_user.detect{|i| (i =~ /^_SS_s/)==0 }
        cookie_admin.join(" ")
      end  
    end
  end
end