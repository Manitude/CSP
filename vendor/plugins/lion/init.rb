# With Rails 2.3.8+, we get the built in fallbacks, so, don't need to use Globalize2 for it anymore
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks) unless I18n.respond_to?(:fallbacks)

require 'zlib'
require File.join(File.dirname(__FILE__), 'lib', 'lion')
require File.join(File.dirname(__FILE__), 'lib', 'lion_mailer')
require File.join(File.dirname(__FILE__), 'lib', 'lion', 'utilities')
require File.join(File.dirname(__FILE__), 'lib', 'lion', 'csv')
require File.join(File.dirname(__FILE__), 'lib', 'lion', 'j18n')
require File.join(File.dirname(__FILE__), 'lib', 'lion', 'query')
require File.join(File.dirname(__FILE__), 'lib', 'lion', 'screenshots')
require File.join(File.dirname(__FILE__), 'lib', 'lion', 'translate')
require File.join(File.dirname(__FILE__), 'lib', 'i18n_extensions')


if Rails.test?
  require File.join(File.dirname(__FILE__), 'lib', 'test', 'translation_test')
end

I18n.default_locale = Lion.default_locale

Lion.supported_locales.each do |iso_code|
  rails_en_locale = Lion.rails_en_locale.to_sym
  default_locale = Lion.default_locale
  if iso_code == default_locale
    I18n.fallbacks[iso_code.to_sym] = [iso_code.to_sym, rails_en_locale]
    I18n.fallbacks[rails_en_locale] = [rails_en_locale, iso_code.to_sym]
    #I18n.fallbacks[rails_en_locale] = [iso_code.to_sym]
  else
    I18n.fallbacks[iso_code.to_sym] = [iso_code.to_sym, default_locale.to_sym, rails_en_locale] # avoids the other default fallback :root (which will automatically be created in the translations table if you don't do this).  NOTE: even though globalize will insert a row for 'en', we think this is ok because Rails wants the 'en' fallback to exist for activerecord translations... or else we'd have to redefine en.ymls everywhere to be en-US.yml, and remember to do so every time we upgrade rails!!!
  end
  Object.const_set(iso_code.to_s.upcase.sub(/\-.*/, ''), iso_code) # which will make EN = 'en-US'
end

#I18n.load_path = [] # gets rid of the built-in en.yml paths
Lion.used_translations_directories.each do |dir|
  Lion::CSV.csv_files_for(dir).each do |filepath|
    I18n.load_path << filepath
  end
end
