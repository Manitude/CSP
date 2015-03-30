class FasterCSV::Row
  def method_missing(meth, *args)
    # allows us to do row.key instead of row.field('key')
    return self.field(meth.to_s) if Lion::CSV.column_headers.include?(meth.to_s)
    super
  rescue NoMethodError
    raise NoMethodError, "undefined method `#{meth}' for #{self.to_s}:Class."
  end

  def has_any_translations?
    (Lion.supported_locales - [Lion.default_locale]).any?{|iso| !self.field(iso.to_s).blank?}
  end

  def has_all_translations?
    (Lion.supported_locales - [Lion.default_locale]).all?{|iso| !self.field(iso.to_s).blank?}
  end

  def make_unused!
    Lion::CSV.columns_inappropriate_for_unused.each do |col|
      self[self.index(col)] = nil
    end
    self
  end

  def has_status_of_at_least?(comparison_status)
    Lion::CSV.status_ranking(self.status) >= Lion::CSV.status_ranking(comparison_status)
  end

end

class String
  # HACK: TODO: FIXME: when rails fixes it so that you can specify something other than a period for the activerecord error message delimiter, these can go away
  def substitute_characters
    self.gsub('.', '||||') # with something that is very very very very unlikely to appear in a string
  end
  def un_substitute_characters
    self.gsub('||||', '.')
  end
end

module ActionView
  module Helpers
    module TranslationHelper
      def translate(key, options = {})
        raise "You shouldn't be using the translate method if you are using Lion"
      end
      alias :t :translate
    end
  end
end

module I18n
  module Backend
    class Simple
      # HACK: to make rails 2.2 translations work with keys like 'Hello there. I am a string with a period in it.' instead of forcing us to create the key :hello_there_i_am_a_symbol_without_a_period_in_it
      def deep_symbolize_keys(hash)
        hash.inject({}) { |result, (key, value)|
          value = deep_symbolize_keys(value) if value.is_a? Hash
          stored_key = (key.to_sym rescue key) || key
          result[stored_key] = value
          if key.is_a? String
            new_key = key.dup.substitute_characters # dup because it's frozen
            if new_key.to_sym != stored_key.to_sym
              result[(new_key.to_sym rescue new_key) || new_key] = value # put in the substituted one
              result.delete(stored_key) # and delete the original
            end
          end
          result
        }
      end

      #load_file will call this when a csv is found
      def load_csv(filename)
        csv_data = Lion::CSV.get(filename)
        # our goal is to get a hash like this: {'en-US' => {'key' => 'translation', 'key2' => 'translation2'}}
        data = {}

        Lion.supported_locales.each do |locale|
          data[locale] = {}
          csv_data.rows.each do |row|
            if csv_data.rails_translation?
              # To be compatible with the Rails-way of activerecord validation error messaging,
              # we support keys like "activerecord.errors.messages.blank" in the rails directory,
              # and split it up and create a hash like:
              #{:activerecord=>{:errors=>{:messages=>{:blank=>"localized string"}}}}
              hashed_key = row.field(locale.to_s)
              row.field('key').split('.').reverse_each do |sub_key|
                containing_hash = {}
                containing_hash[sub_key.to_sym] = hashed_key
                hashed_key = containing_hash
              end
              data[locale].deep_merge!(hashed_key)
            else
              localized_str = row.field(locale.to_s)
              if (localized_str.present? ||
                    (Lion.respond_to?(:legitimately_blank_strings) &&
                      Lion.legitimately_blank_strings.include?(row.field('key'))))
                data[locale][row.field('key')] = localized_str
              end
            end
          end
        end
        data
      end
    end
  end

  protected

  def self.just_raise_that_exception(exception, locale, key, options)
    error_subject = ''
    if MissingTranslationData === exception
      error_subject = "Missing translation for \"#{key.to_s.un_substitute_characters}\""
      if !Lion.raise_on_missing_translations && !Rails.test?
        if Lion.using_natural_keys
          string = key.to_s.un_substitute_characters # because the key had been un-periodized before it was translated
          options.each do |key, value|
            string.gsub!(/\{\{#{key.to_s}\}\}/, value)
          end
          return string # return the untranslated string with all the interpolations resolved from how it was called
        elsif Rails.development?
          return key.to_s
        else
          return nil # there is not much we can do if it is a symbolic key and fallbacks to the default_locale didn't work
        end
      end
    elsif MissingInterpolationArgument === exception
      error_subject = "Missing interpolation argument for \"#{key.to_s.un_substitute_characters}\""
    else
      error_subject = "UNKNOWN EXCEPTION"
    end
    RosettaStone::GenericExceptionNotifier.deliver_exception_notification(exception)
    logger.error "#{error_subject} #{exception.inspect}"
    raise exception if !Rails.production?
  end

end

I18n.exception_handler = :just_raise_that_exception
