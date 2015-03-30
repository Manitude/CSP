# -*- encoding : utf-8 -*-

class SystemReadiness::Ruby < SystemReadiness::Base
  class << self
    def verify
      version = RUBY_VERSION
      allowed_versions = defined?(SUPPORTED_RUBY_VERSIONS) ? SUPPORTED_RUBY_VERSIONS : %w(1.8.7)
      if ENV['SKIP_RUBY_VERSION_CHECK'] == 'true'
        return true, 'skipped'
      elsif allowed_versions.include?(version)
        return true, nil
      else
        return false, "Detected ruby version '#{version}'; supported versions are #{allowed_versions}"
      end
    end
  end
end
