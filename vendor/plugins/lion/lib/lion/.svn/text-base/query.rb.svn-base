class Lion
  module Query
    class << self
      
      def get_translations_hash(force_refresh = false)
        translations_hash = I18n.backend.send(:translations)
        if ((translations_hash.keys.size == 0) || (force_refresh == true))
          I18n.backend.send(:init_translations)
          translations_hash = I18n.backend.send(:translations)
        end
        translations_hash
      end
      
      def ruby_files_to_search_for_translation_strings
        Lion.patterns_of_ruby_files_to_search_for_translation_strings.inject([]) do |memo, pattern|
          memo += Dir[File.join(Rails.root, *pattern.split(','))]
        end
      end

      def javascript_files_to_search_for_translation_strings
        Lion.patterns_of_javascript_files_to_search_for_translation_strings.inject([]) do |memo, pattern|
          memo += Dir[File.join(Rails.root, *pattern.split(','))]
        end
      end

      def files_to_search_for_translation_strings
        ruby_files_to_search_for_translation_strings + javascript_files_to_search_for_translation_strings
      end
      
      def all_key_strings_that_can_be_different_from_their_default_locale_translation
        Lion.files_that_can_have_default_locale_translation_different_from_the_key_if_using_natural_keys.inject([]) do |memo, partial_path|
          memo += Lion::CSV.get(File.join(Rails.root, partial_path)).keys
        end
      end
      
      def next_batch_number
        highest_batch_number = 0
        Lion.all_csv_files.each do |filepath|
          csv = Lion::CSV.get(filepath)
          highest_batch_number = csv.rows.inject(highest_batch_number) do |memo, row|
            if row.batch.to_i > 0
              memo = row.batch.to_i if row.batch.to_i > memo
            end
            memo
          end
        end
        highest_batch_number + 1
      end
      
      def find_file_for_key(key)
        Lion.all_csv_files.each do |filepath|
          csv = Lion::CSV.get(filepath)
          return filepath if csv.keys.include?(key)
        end
        nil
      end

      def find_used_keys
        used_keys = []
        files_to_search_for_translation_strings.each do |file_path|
          used_keys += find_all_keys_in_file(file_path)
        end
        used_keys.uniq
      end
      
      def find_unused_keys
        Lion::Translate.translation_keys_stringified - find_used_keys - non_harvestable_keys
      end
      
      def non_harvestable_keys
        Lion.csvs_that_contain_non_harvestable_keys.inject([]) do |memo, relative_path|
          csv = Lion::CSV.get_from_relative_path(relative_path)
          if csv.rails_translation?
            #the translation_keys_stringified is going to return the first part of the
            #hash, so, something like 'activerecord' instead of 'activerecord.errors...'
            memo + csv.keys.collect{|val| val.split('.')[0]}.uniq!
          else
            memo + csv.keys
          end
        end
      end
      
      def find_all_keys_in_file(file_path)
        keys = []
        i = 1
        file_contents = File.open(file_path, 'r').read
        Lion.translation_method_names_that_are_harvested.each do |method_name|
          while file_contents =~ %r/#{method_name}\((["'])((?:\\\1|.)*?)\1\s*[,\)]/ # this regex finds the key even if it has escaped quotes inside it
            quote_type = $1
            matched_key = $2
            file_contents.gsub!(%r/#{method_name}\((["'])#{Regexp.escape(matched_key)}\1\s*[,\)]/, '')
            keys << matched_key.gsub(%r/\\#{quote_type}/, quote_type) # unescapes the quotes that were in the code, because the key will not have those escapes
            i += 1
            raise 'Something went very wrong with the regex' if i > 10000
          end
        end
        keys.uniq
      end

      def find_code_files_that_contain_keys(keys)
        found_file_paths = {}
        files_to_search_for_translation_strings.each do |file_path|
          File.open(file_path, 'r').readlines.map{|line| line.chomp}.each do |line|
            keys.each do |key|
              if line =~ /#{Regexp.escape(key)}/
                found_file_paths[file_path] = [] if found_file_paths[file_path].nil?
                found_file_paths[file_path] << key if !found_file_paths[file_path].include?(key)
              end
            end
          end
        end
        found_file_paths
      end
      
      def found_string_in_file(file_path, string, new_key = '')
        file_contents = File.open(file_path, 'r').read
        if file_contents =~ %r/_\((['"])#{Regexp.escape(string)}['"]/m
          quote = $1
          if !new_key.blank?
            File.open(file_path, 'w') do |f|
              f.write file_contents.gsub!(%r/_\(#{quote}#{Regexp.escape(string)}#{quote}/m, "_(#{quote}#{new_key}#{quote}")
            end
          end
          return true
        end
        return false
      end

      def files_and_lines_that_have_a_string_in_them(string)
        files_and_lines = []
        files_to_search_for_translation_strings.each do |file_path|
          line_index = 1
          File.foreach(file_path) do |line|
            files_and_lines << "#{file_path}:#{line_index}    #{line}" if line =~ /[^\.]#{string}/ # the "not dot" is to avoid finding window.awaiting_default_locale_string
            line_index += 1
          end
        end
        files_and_lines
      end

      def find_unregistered_keys
        hash_of_keys_not_registered = {}
        keys = get_translations_hash[Lion.default_locale.to_sym].keys.map(&:to_s).map(&:un_substitute_characters)
        files_to_search_for_translation_strings.each do |file_path|
          found_unregistered_key = false
          File.foreach(file_path) do |line|
            Lion.translation_method_names_that_are_harvested.each do |method_name|
              hash_of_keys_not_registered = check_line_for_regex_recursively(file_path, keys, hash_of_keys_not_registered, line, method_name)
            end
          end
        end
        hash_of_keys_not_registered
      end

      def find_keys_in(files = files_to_search_for_translation_strings)
        hash_of_keys_found = {}
        keys_to_exclude = []
        files.each do |file_path|
          File.foreach(file_path) do |line|
            Lion.translation_method_names_that_are_harvested.each do |method_name|
              hash_of_keys_found = check_line_for_regex_recursively(file_path, keys_to_exclude, hash_of_keys_found, line, method_name)
            end
          end
        end
        hash_of_keys_found.keys.map { |key| key.gsub(/\\(['"])/, '\1') }
      end

      def check_line_for_regex_recursively(file_path, keys, hash_of_keys_to_return, line, translation_method_name, loopnum = 1, called_by = 'outer')
        loopnum += 1
        if line =~ regex_for_translation_method_call(translation_method_name)
          quote_type_used = $1
          found_key = $2
          if !keys.include?(found_key)
            matched = false
            [found_key.gsub(/\\"/, '"'), found_key.gsub(/\\'/, "'")].each do |quote_escaped_key| # just in case the string in the source file has escaped quotes...
              if keys.include?(quote_escaped_key)
                matched = true
                break
              end
            end
            hash_of_keys_to_return[found_key] = file_path if !matched
          end
          hash_of_keys_to_return = check_line_for_regex_recursively(file_path, keys, hash_of_keys_to_return, line.gsub("#{translation_method_name}(#{quote_type_used}#{found_key}#{quote_type_used}", ''), translation_method_name, loopnum, 'inner')
        end
        hash_of_keys_to_return
      end

      def regex_for_translation_method_call(method_name)
        # note: \A doesn't seem to work so well inside of []
        %r/(?:\A|[\s\W])#{method_name}\((["']?)([^\1]+?)\1[,\)]/
      end

      def historical_to_release_keys
        keys = []
        Dir.glob(File.join(RAILS_ROOT, 'doc', 'translations', 'releases', '*.csv')).each do |filepath|
          keys += csv_hash_of_arrays(filepath).keys
        end
        keys.uniq
      end

      def untranslated_strings
        translations_hash = get_translations_hash
        strings = []
        Lion.supported_locales.each do |iso|
          translations_hash[Lion.default_locale].keys.each do |key|
            strings << mock_translate(key) if !Lion::Translate.translation_exists_for(iso, key, translations_hash)
          end
        end
        strings.uniq.sort
      end
      
      def untranslated_keys
        translations_hash = get_translations_hash
        new_keys = []
        Lion.supported_locales.each do |iso|
          translations_hash[Lion.default_locale].keys.each do |key|
            new_keys << key.to_s.un_substitute_characters if !Lion::Translate.translation_exists_for(iso, key, translations_hash)
          end
        end
        new_keys.uniq.sort
      end

       #FIXME: delete me?
      def strings_not_found_in_releases
        translations_hash = get_translations_hash
        new_keys = []
        Lion.supported_locales.each do |iso|
          translations_hash[Lion.default_locale].keys.each do |key|
            new_keys << key.to_s.un_substitute_characters if !Lion::Translate.translation_exists_for(iso, key, translations_hash)
          end
        end
        (new_keys.uniq - historical_to_release_keys).sort
      end

      def all_untranslated_screenshotable_keys
        #keys1 = strings_not_found_in_releases
        keys1 = untranslated_keys
        keys2 = all_non_screenshotable_keys_as_strings
        (keys1 - keys2)
      end

      def has_translations_for_every_locale?(csv_row_data)
        Lion.supported_locales.each do |iso|
          return false if csv_row_data[iso].blank?
        end
        true
      end
      
      def all_screenshots_taken?(iso)
        all_screenshots_taken = true
        screenshotable_count = 0
        screenshoted_count = 0
        Lion::CSV.output_csv.rows.each do |row|
          if %w(yes awaiting).include?(row.screenshotable)
            screenshotable_count += 1
            screenshoted_count += 1 if row.field("#{iso}_screenshot") == 'yes'
            all_screenshots_taken = false if ['no', '', nil].include?(row.field("#{iso}_screenshot"))           
          end
        end
        puts "#{screenshoted_count} screenshots taken out of #{screenshotable_count}"
        all_screenshots_taken
      end
      
    end
  end
end
