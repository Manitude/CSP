class Lion #:nodoc:
  module Utilities
    class << self

      # ---------------------------------------------------------------- #
      # ------- formatting conversions for keys/filenames/spans -------- #
      # ---------------------------------------------------------------- #
      def spanify(key, translated_text, css_class = nil)
        if ENV['take_translation_screenshots'] == 'true'
          css_class = " class=#{css_class}" if !css_class.blank?
          # Yes, you are a genius!  You noticed that there are no quotes around the id value.
          # The reason is that quotes would wreak havoc if the string is in javascript... 
          # So i'd rather not drink the xhtml grape juice during selenium screenshots than to introduce javascript bugs
          return "<span id=\"#{Lion.convert_to_span_id(key)}\"#{css_class}>#{translated_text.to_s}</span>"
        end
        translated_text
      end
      
      
      def diacritic_substitution_characters_for_ruby_sorting
        Lion.diacritic_mapping.inject({}) do |memo, val|
          pair = val.split(',')
          memo[pair.first] = pair.last
          memo
        end
      end

      # Removes diacritics from characters and returns a string devoid of diacritics
      # This can be helpful for sorting
      # ex: "über"=>"uber"
      def substitute_diacritics(s)
        s.gsub!(/([#{diacritic_substitution_characters_for_ruby_sorting.keys.join("")}])/){diacritic_substitution_characters_for_ruby_sorting[$1]}
        s
      end
      alias_method :substitute_diacritics_for_ruby_sorting, :substitute_diacritics
      
      def get_interpolation_keys(s, uniquify = true)
        string = s.dup # just being careful... when the string is a value in a hash, this method can alter the hash!
        keys = []
        while string =~ /%\{(\w+)\}/ do
          keys << $1
          if uniquify
            string.gsub!("%{#{$1}}", '')
          else
            string.sub!("%{#{$1}}", '')
          end
        end
        keys.sort
      end

    end
    
  end # Utilities
end # Lion