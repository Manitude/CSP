module CommunityApi

  class Util
    include RosettaStone::YamlSettings
    yaml_settings(:config_file => 'totale.yml', :hash_reader => false)

    def self.email_for_guids(guid_hash)
      api_prefix = '/api/identity/emails_from_guids'
      host, phost = [ settings[:host] + api_prefix, settings[:proxy_host] ]
      user, password = [ settings[:username] , settings[:password] ]

      url, p_url = [URI.parse(host), URI.parse(phost)]
      resp = nil
      http = Net::HTTP.new(url.host, url.port, p_url.host, p_url.port)

      req  = Net::HTTP::Post.new(url.path)
      req.basic_auth user, password
      req.set_content_type 'application/xml'

      guid_list, guid_xml = [guid_hash.keys, '']
      guid_list.each{|each_guid| guid_xml+='<guid>'+each_guid+'</guid>'} if guid_list
      req.body = '<users>'+guid_xml+'</users>'
      resp = http.start{|h| h.request(req)}

      xml_response =  XmlSimple.xml_in(resp.body)
      xml_response['user'].each{|each_entry| guid_hash[each_entry['guid'].join] = each_entry['email'].join} if xml_response['user']

      guid_hash
    end
  end
end