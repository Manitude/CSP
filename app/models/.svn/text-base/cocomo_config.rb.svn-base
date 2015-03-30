class CocomoConfig
  include RosettaStone::OverridableYamlSettings
  overridable_yaml_settings(:config_file => "cocomo", :hash_reader => false)

  class << self
    def room_url(room_identifier)
      [url, room_identifier].join('/')
    end
  end
end
