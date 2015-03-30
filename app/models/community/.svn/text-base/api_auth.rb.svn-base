module Community
  class ApiAuth < ::ActiveResource::Base

    include RosettaStone::YamlSettings
    yaml_settings(:config_file => 'community.yml', :hash_reader => false)

    self.site     = settings[:host]
    self.proxy    = settings[:proxy_host]

    self.user     = settings[:username]
    self.password = settings[:password]

  end
end
