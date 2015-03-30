require 'active_support/cache/dalli_store'

class MemcacheService

  include RosettaStone::YamlSettings
  yaml_settings(:config_file => 'memcache.yml', :hash_reader => false)

  def self.cache(key, expires = 30.seconds)
    cache_store.fetch(key, :expires_in => expires){ yield if block_given? }
  end

  def self.cache_store
    @@cache ||= ActiveSupport::Cache::DalliStore.new(hosts, :namespace => 'coach_portal')
  end

  def self.hosts
    @@hosts ||= settings[::Rails.env]['memcache_host'].split(',').collect { |host| host.strip}
  end

  def self.clear_all
    cache_store.clear
  end

  def self.clear(key)
    cache_store.delete(key)
  end

end
