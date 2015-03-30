class Lion
  module Translate
    class << self

      def translation_keys_stringified(force_refresh = false)
        Lion::Query.get_translations_hash(force_refresh)[Lion.default_locale.to_sym].keys.map(&:to_s).map(&:un_substitute_characters)
      end

      def translate_into(iso_code, string_or_symbol, interpolation_hash = {}, do_spanify = true)
        go_back_to_locale = I18n.locale 
        I18n.locale = iso_code
        translated_string = _(string_or_symbol, interpolation_hash = {}, do_spanify)
        I18n.locale = go_back_to_locale
        translated_string
      end

      def translation_exists_for(iso, string_or_symbol, translations_hash)
        string_or_symbol = string_or_symbol.substitute_characters.to_sym if string_or_symbol.is_a?(String)
        val = translations_hash[iso.to_sym][string_or_symbol]
        !val.blank?
      end
    
    end
  end
end

class Object

  # use this when you are adding a string that you don't necessarily want in production, but you need a placeholder for now, until the default translation is approved
  def awaiting_default_locale_string(unapproved_string)
    unapproved_string
  end

  def mock_translate(string_or_symbol, do_spanify = true) # used when we want to show "{{interpolations}} in the translated string" -- for screenshots
    th = Lion::Query.get_translations_hash[I18n.locale.to_sym]
    translation_without_interpolation = th[klass.prepare_string_or_symbol_for_translation(string_or_symbol)]
    # fallback for mock_translate
    if translation_without_interpolation.blank?
      translation_without_interpolation = Lion::Query.get_translations_hash[Lion.default_locale.to_sym][klass.prepare_string_or_symbol_for_translation(string_or_symbol)]
    end
    return do_spanify ? Lion::Utilities.spanify(string_or_symbol, translation_without_interpolation) : translation_without_interpolation
  end

  def self.prepare_string_or_symbol_for_translation(string_or_symbol)
    return string_or_symbol.substitute_characters.to_sym if string_or_symbol.is_a?(String)
    string_or_symbol # will be a symbol
  end

  def _(string_or_symbol, interpolation_hash = {}, do_spanify = true, bypass = false)
    return string_or_symbol if bypass # this is for when we want the harvester to find the string, but we don't want it to actually translate at that point... this is currently used when adding errors, because you have to do the translation AFTER you add the string to the errors collection or else the locale translation is cached at model load time
    key_sym = klass.prepare_string_or_symbol_for_translation(string_or_symbol)
    if Lion.using_natural_keys && (Rails.test? || Lion.raise_on_mismatched_interpolations_in_translations)
      key_interpolation_strings = Lion::Utilities.get_interpolation_keys(key_sym.to_s).sort
      interpolation_hash_strings = interpolation_hash.keys.map(&:to_s).sort
      if (interpolation_hash_strings - key_interpolation_strings).any? # the MissingInterpolationArgument exception is thrown if there are too few interpolations, but this catches it if there are too many
        raise "Unmatched interpolations for \"#{key_sym.to_s.un_substitute_characters}\" - the locale is #{I18n.locale}, the key_interpolations were #{key_interpolation_strings.inspect} and the interpolation_hash is #{interpolation_hash_strings.inspect}"
      end
    end
    translated_text = I18n.translate key_sym, interpolation_hash # do not call just translate because when calling from a view, it will call the TranslationHelper definition of translate, which will not raise, but instead will show a dumb span with something like "en, asdf" in it (if asdf is your untranslated string)
    if translated_text.blank?
      if Lion.raise_on_untranslated_translations
         raise "'" + key_sym.to_s + "' still not translated in " + I18n.locale.to_s
      else
        interpolation_hash[:locale] = Lion.default_locale # fallback to the default locale as a last resort.
        translated_text = I18n.translate key_sym, interpolation_hash
      end
    end
    return do_spanify ? Lion::Utilities.spanify(key_sym, translated_text) : translated_text
  end
  
  alias_method :unharvested_translate, :_
  
  # this method comes in handy when you are using symbolic keys yet for convenience you want to access the translation by
  # the default locale instead of the symbolic key. It of course assumes that the string has a key that was created
  # by Lion conventions
  def translate_from_default_locale_string(string, interpolation_hash = {}, do_spanify = true, bypass = false)
    key = Lion.using_natural_keys ? string : Lion.reverse_lookup_key(string)
    unharvested_translate(key, interpolation_hash, do_spanify, bypass)
  end
  
  def validation_message(string, interpolation_hash = {})
    s = string
    s += "#{Lion.interpolations_follow}#{interpolation_hash.inspect}" if !interpolation_hash.empty?
    s
  end
  
  def no_screenshot_translate(string, interpolation_hash = {}, bypass = false)
    unharvested_translate(string, interpolation_hash, false, bypass)
  end
end
