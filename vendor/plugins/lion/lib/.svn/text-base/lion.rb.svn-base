class Lion

  include RosettaStone::OverridableYamlSettings
  overridable_yaml_settings(:config_file => "lion",:hash_reader => false)

  class << self
    # this allows interpolations to be sent along with the error message. For when it's used, see labeled_form_builder.rb and Lion::Translate.validation_message
    def interpolations_follow; '__interpolations_follow__'; end
    def supported_locales;              Lion.supported_locale_mapping.map{|slm| slm.split(',').first}.map(&:to_sym);                                                 end
    def supported_locale_language_keys; Lion.supported_locale_mapping.map{|slm| slm.split(',').last}.map{|locale| Lion.convert_to_string_key(locale)}; end
    #Gets a supported locale from the passed in locale.  If the locale is a rails
    #locale (such as 'en') then it will be converted into our locale ('en-US').
    #If the locale is not supported, then nil is returned
    def supported_locale(locale)
      if locale.to_s.length == 2
        #try to convert to the language-locale format
        iso_code = Lion.rails_locale_to_iso_locale_mapping.detect{|rlm| rlm.split(',').first.to_s == locale.to_s}
        return nil unless iso_code 
        locale = iso_code.split(',').last.to_sym
      end
      if !locale.to_s.blank? && supported_locales.include?(locale.to_sym)
        return locale.to_sym
      else
        return nil
      end
    end
    #Gets the rails locale from the passed in ISO locale.  Will return the ISO
    #code if there is no mapping between this ISO locale and the rails locale
    #defined in your lion.defaults.yml
    def rails_locale(locale)
      mapping = Lion.rails_locale_to_iso_locale_mapping.detect{|rlm| rlm.split(',').last.to_s == locale.to_s}
      if mapping
        return mapping.split(',').first.to_sym
      else
        return locale.to_sym
      end
    end
    # list of supported locales in two-letter form
    def supported_rails_locales; Lion.supported_locales.map{|iso| Lion.rails_locale(iso)}; end
    
    def locale_language(iso, do_spanify = false, bypass = false);    Lion.supported_locale_mapping.detect{|slm| slm.split(',').first.to_s == iso.to_s}.split(',').last.to_sym; end
    def locale_language_key(iso, do_spanify = false, bypass = false); Lion.reverse_lookup_key(Lion.locale_language(iso, do_spanify, bypass));              end
    
    def all_translations_directories; used_translations_directories + unused_translations_directories; end
    
    def io_csv_files; Dir.glob("#{Rails.root}/#{Lion.csv_base_directory}/io/*.csv"); end
    def used_csv_files; Lion.used_translations_directories.inject([]){|memo, dir| memo + Lion::CSV.csv_files_for(dir)}; end
    def unused_csv_files; Lion.unused_translations_directories.inject([]){|memo, dir| memo + Lion::CSV.csv_files_for(dir)}; end
    # FIXME: this could be better named because it doesn't include io files
    def all_csv_files; used_csv_files + unused_csv_files; end
    
    # FIXME: move to utilities after migration?
    def convert_to_string_key(string, length = Lion.auto_generated_symbolic_key_length)
      underscorify(string, length, true, true)
    end
    
    def reverse_lookup_key(string)
      underscorify(string, Lion.auto_generated_symbolic_key_length, true, true)
    end
    
    def underscorify(key, length = Lion.auto_generated_symbolic_key_length, do_it_regardless_of_key_type = false, use_crc32 = false)
      if using_natural_keys || do_it_regardless_of_key_type
        # this can convert a symbol, an un_substituted string, or a substituted string!!!!
        # the hash at the end is to maintain uniqueness in spite of the slice (like if two long strings only differed at the end)
        converted_key = key.to_s.un_substitute_characters
        youneek = use_crc32 ? Lion.crc32(converted_key) : converted_key.hash.abs.to_s
        converted_key.gsub(/ /m, '_').gsub(/[^a-zA-Z0-9_]/m, '').slice(0, 50) + youneek
      else
        key
      end
    end
    
    def crc32(string)
      Zlib.crc32(string).to_s(16).upcase
    end
    
    def convert_to_span_id(key, length = Lion.auto_generated_symbolic_key_length)
      underscorify(key, length)
    end
    def convert_to_filename(key, length = Lion.auto_generated_symbolic_key_length)
      underscorify(key, length)
    end
    
    def send_mail(subject, paragraphs)
      LionMailer.deliver_general_email(Lion.notification_emails.join(','), Lion.notification_email_from, subject, paragraphs)
    end

    # Changes the locale to the specified locale, but only for the duration
    # of the block.  If you pass in something like 'it' then it'll convert it
    # into the support locale ("it-IT")
    def with_locale(locale)
      old_locale = I18n.locale
      begin
        I18n.locale = self.supported_locale(locale)
        yield
      ensure
        I18n.locale = old_locale
      end
    end

    # Removes the fallback logic.  This should probably never be used, but, it's
    # helpful if you want to determine if a model translation (Globalize2) exists
    # for the language or not
    def with_no_fallback
      locale = I18n.locale.to_sym
      old_fallbacks = I18n.fallbacks[locale]
      begin
        #Always leave :en in because there aren't really any :en translations, but there
        #are a lot of default things that are set in :en that we want to use elsewhere,
        #such as date formats in activesupport/lib/active_support/locale/en.yml
        I18n.fallbacks[locale] = [locale,:en]
        yield
      ensure
        I18n.fallbacks[locale] = old_fallbacks
      end
    end
    
  end
end

