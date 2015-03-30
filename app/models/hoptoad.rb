class Hoptoad
  include RosettaStone::OverridableYamlSettings
  overridable_yaml_settings(:config_file => "hoptoad")

  class << self
    def method_missing(sym, *args, &block)
      return super unless self[Rails.env].has_key?(sym.to_s)
      self[Rails.env][sym.to_s]
    end
  end

end
