# -*- encoding : utf-8 -*-

# older Rails (2.0) don't have these, so backport them if not defined.
module Rails
  class << self
    def development?
      environment == 'development'
    end unless Rails.respond_to?(:development?)

    def test?
      environment == 'test'
    end unless Rails.respond_to?(:test?)

    def production?
      environment == 'production'
    end unless Rails.respond_to?(:production?)

    def env
      RAILS_ENV
    end unless Rails.respond_to?(:env)
    alias_method(:environment, :env) unless Rails.respond_to?(:environment)

    def root
      RAILS_ROOT
    end unless Rails.respond_to?(:root)

    def version
      ::Rails::VERSION::STRING
    end unless Rails.respond_to?(:version)
  end
end