# Copyright:: Copyright (c) 2009 Rosetta Stone
# License:: All rights reserved.

class Lion
  module TranslationTest
    
    # NOTE: there are example model_translation tests in comments below. Just search for "model_translation" in this file
    
    # enable this if any particular test is running slow and you want to see what is running instead of just dots
    # def setup
    #  $stderr.write "\n=========== #{self.class.to_s}: #{@method_name} at #{Time.now} ========= "
    #  super
    # end

    def test_harvester_regex
      Lion.translation_method_names_that_are_harvested.each do |method_name|
        good_strings = [
          "#{method_name}('moo')",
          "#{method_name}('\"moo\"')",
          "#{method_name}('what \"moo\" what')",
          "\n#{method_name}('monkey')",
          "monkey(#{method_name}('moo'))",
          method_name + '("\'moo\'")',
          method_name + '("moo")',
        ]
        bad_strings = [
          "squirrel#{method_name}('hi')"
        ]
        good_strings.each do |str|
          assert(str =~ Lion::Query.regex_for_translation_method_call(method_name), "\"#{str}\" should match")
        end
        bad_strings.each do |str|
          assert(str !~ Lion::Query.regex_for_translation_method_call(method_name), "\"#{str}\" should not match")
        end
      end
    end
    
    def test_japanese_translations_have_valid_linebreaks
      return if !Lion.supported_locales.include?(:"ja-JP")
      chars_that_cannot_be_at_beginning_of_lines = "!%),.:;?]}¢°’”‰′″℃、。々〉》」』】〕ぁぃぅぇぉっゃゅょゎ゛゜ゝゞァィゥェォッャュョヮヵヶ・ーヽヾ！％），．：；？］｝｡｣､･ｧｨｩｪｫｬｭｮｯｰﾞﾟ￠"
      chars_that_cannot_be_at_end_of_lines = "$([\{£¥‘“〈《「『【〔＄（［｛｢￡￥"
      errors = []
      th = Lion::Query.get_translations_hash[:"ja-JP"]
      Lion::CSV.all_csv_keys.each do |key|
        values_for_key(th,key).each do |translated_string|
          key_to_report = key
          key_to_report = "#{key}... (you'll have to look in the rails translation csvs for something that starts with #{key}.)" if th[key].is_a?(Hash)
          next if translated_string.nil? || translated_string.strip == ':'
          translated_string.gsub!(/<[bB][rR] ?\/?>/, '___br___') # normalizing all variations of the break tag
          translated_string.gsub!(/%\{[^\}]+\}/, 'placeholder') # getting rid of interpolations... the percentage sign throws it off
          errors << "#{key_to_report}" if translated_string =~ /(^|___br___)[#{Regexp.escape(chars_that_cannot_be_at_beginning_of_lines)}]/ ||
            translated_string =~ /[#{Regexp.escape(chars_that_cannot_be_at_end_of_lines)}]($|___br___)/
        end
      end
      flunk "The following keys have invalid linebreaks in the japanese translation:\n\n" + errors.compact.join("\n") if errors.any?
    end
    
    def test_has_no_double_brace_interpolations
      errors = []
      Lion.supported_locales.each do |iso|
        th = Lion::Query.get_translations_hash[iso.to_sym]
        th.keys.each do |key|
          key_to_report = key
          key_to_report = "#{key}... (you'll have to look in the rails translation csvs for something that starts with #{key}.)" if th[key].is_a?(Hash)
          values_for_key(th,key).each do |translated_string|
            errors << "#{key_to_report}" if translated_string =~ /\{\{\w+\}\}/
          end
        end
      end
      flunk "The following keys have double braces... please replace with %{the_new_syntax}\n\n" + errors.join("\n") if errors.any?
    end

    def test_has_no_bad_interpolations
      errors = []
      Lion.supported_locales.each do |iso|
        th = Lion::Query.get_translations_hash[iso.to_sym]
        th.keys.each do |key|
          key_to_report = key
          key_to_report = "#{key}... (you'll have to look in the rails translation csvs for something that starts with #{key}.)" if th[key].is_a?(Hash)
          values_for_key(th,key).each do |translated_string|
            errors << "#{key_to_report}" if translated_string =~ /[^%]\{\w+\}/
          end
        end
      end
      flunk "The following keys probably have a malformed interpolation... please replace with %{the_variable}\n\n" + errors.join("\n") if errors.any?
    end
    
    def test_has_any_translations_and_has_all_translations
      Lion::CSV.make_empty_csv('test', "csv_file_that_tests_do_stuff_to.csv", "#{Rails.root}/vendor/plugins/lion/")
      current_csv = Lion::CSV.get("#{Rails.root}/vendor/plugins/lion/test/csv_file_that_tests_do_stuff_to.csv")
      current_csv.clear

      has_all_translations = {'key' => 'has_all_translations'}
      Lion.supported_locales.each do |iso|
        has_all_translations[iso.to_s] = "translation for #{iso}"
      end
      current_csv.add_or_update_row(Lion::CSV.sanitize_row(current_csv, has_all_translations))
      current_csv.add_or_update_row(Lion::CSV.sanitize_row(current_csv, {'key' => 'has_no_translations'}))
      current_csv.add_or_update_row(Lion::CSV.sanitize_row(current_csv, {'key' => 'has_some_translations', 'en-US' => 'translation for en-US', 'es-419' => 'translation for es-419'}))

      assert current_csv.row_for_key('has_all_translations').has_any_translations?, 'failed has_any_translations for has_all_translations'
      assert current_csv.row_for_key('has_all_translations').has_all_translations?, 'failed has_all_translations for has_all_translations'
      assert !current_csv.row_for_key('has_no_translations').has_all_translations?, 'failed has_all_translations for has_no_translations'
      assert !current_csv.row_for_key('has_no_translations').has_any_translations?, 'failed has_any_translations for has_no_translations'
      assert current_csv.row_for_key('has_some_translations').has_any_translations?, 'failed has_any_translations for has_some_translations'
      assert !current_csv.row_for_key('has_some_translations').has_all_translations?, 'failed has_all_translations for has_some_translations'
    end
      
    def test_each_key_has_a_default_locale_translation
      errors = []
      locale_hash = Lion::Query.get_translations_hash[Lion.default_locale.to_sym]
      locale_hash.keys.each do |key|
        errors << key if locale_hash[key].blank?
      end
      flunk "These keys have no default translations. They should at least be in #{Lion.default_locale}:\n#{errors.inspect}" if errors.any?
    end
      
    def test_translations
      Lion.supported_locales.each do |iso|
        assert_valid_translations(iso)
      end
    end
    
    def test_for_unused_keys
      unused = Lion::Query.find_unused_keys - keys_that_were_added_outside_of_csv
      flunk "These keys are no longer used: #{unused.inspect}.  Please run rake lion:delete_unused_keys" if unused.any?
    end
    
    def test_that_awaiting_default_locale_string_does_not_appear_in_code
      files_and_lines = Lion::Query.files_and_lines_that_have_a_string_in_them('awaiting_default_locale_string')
      puts "\n\nFound files that contained strings that are awaiting default locale approval (this is just a warning... everything is ok, but these should be gone when we branch!)\n" if files_and_lines.any?
      files_and_lines.each{ |fl| puts fl }
    end
      
    def test_csv_files_do_not_have_duplicate_keys_within_the_file
      Lion.all_csv_files do |csv_file|
        duplicates = dups_in_array(Lion::CSV.get(csv_file).keys)
        assert_true(duplicates.blank?, "Duplicate keys exist in '#{csv_file}':\n#{duplicates}")
      end
    end
    
    def test_for_short_keys_that_have_less_chance_to_be_unique
      short_keys = Lion::CSV.all_csv_keys.select{|key| key.length < 6} # 6 is arbitrary, sorry.
      flunk "These keys are too short... They are in danger of not being unique. Please make up a longer key that is more likely to be unique:\n" + short_keys.join("\n") + "\n" if short_keys.any?
    end
    
    def test_translation_files_do_not_have_the_same_key_across_different_csvs
      all_keys_in_csvs = []
      Lion.all_csv_files.each do |csv_file|
        all_keys_in_csvs += Lion::CSV.get(csv_file).keys
      end
      duplicates = dups_in_array(all_keys_in_csvs)
      assert_true(duplicates.blank?, "Duplicate keys exist across different files (just grep for them in config/translations and you will find them):\n#{duplicates.inspect}")
    end
    
    def test_has_no_unsupported_characters
      translations_hash = Lion::Query.get_translations_hash[Lion.default_locale.to_sym]
      illegal_characters = "’" # the curly apostrophe causes yml files to go screwy.. probably ruby's fault.  the standard single apostrophe should suffice
      illegal_keys = translations_hash.keys.map(&:to_s).map(&:un_substitute_characters).select{|key| key =~ /[#{illegal_characters}]/}
      flunk "these keys have one or more of these illegal characters [#{illegal_characters}].  Here are the offending keys: \n#{illegal_keys.join("\n")}\n\n\n" if illegal_keys.any?
    end
    
    # the interpolations in key "hey, you {{first_name}}" should match the interpolations in translation: "hola, usted {{first_name}}"
    def test_that_interpolations_in_key_match_interpolations_in_translation
      return if !Lion.using_natural_keys
      errors = []
      translations_hash = Lion::Query.get_translations_hash
      translations_hash.keys.each do |iso|
        translations_hash[iso].keys.each do |key|
          next if translations_hash[iso][key].blank? #== Lion.untranslated_string
          key_interpolation_strings = Lion::Utilities.get_interpolation_keys(key.to_s)
          value_interpolation_strings = Lion::Utilities.get_interpolation_keys(translations_hash[iso][key])
          if key_interpolation_strings != value_interpolation_strings
            diff = ((key_interpolation_strings - value_interpolation_strings) + (value_interpolation_strings - key_interpolation_strings)).uniq
            errors << "this key:\n\"#{key.to_s.un_substitute_characters}\"\n\nhas these unmatched interpolations:\n#{diff.inspect}"
          end
        end
      end
      errors.uniq!
      if errors.any?
        flunk errors.join("\n\n\n") + "\n\n" + errors.size.to_s + " errors"
      end
    end
    
    def test_interpolation_mismatch_raises
      Lion.stubs(:using_natural_keys).returns(true)
      Lion.stubs(:raise_on_mismatched_interpolations_in_translations).returns(true)
      # run these, knowing we don't have translations...
      assert_raises(RuntimeError) do
        unharvested_translate('asdf', :asdf => 'asdf')
      end
      assert_raises(RuntimeError) do
        unharvested_translate('asdf {{qwer}}', :asdf => 'asdf')
      end
      assert_raises(RuntimeError) do
        unharvested_translate('asdf {{qwer}}', :qwer => 'qwer', :zxcv => 'zxcv')
      end
      # put the translation in there
      with_fake_translations({'en-US' => [{'asdf {{qwer}}' => 'asdf {{qwer}}'}]}) do
        if RosettaStone::RailsVersionString < RosettaStone::VersionString.new(2,3,4)
          assert_raises(I18n::MissingInterpolationArgument) do
            unharvested_translate("asdf {{qwer}}")
          end
        end
        # now run the same ones over again now that we have translations...
        assert_raises(RuntimeError) do
          unharvested_translate('asdf {{qwer}}', :asdf => 'asdf')
        end
        assert_raises(RuntimeError) do
          unharvested_translate('asdf {{qwer}}', :qwer => 'qwer', :zxcv => 'zxcv')
        end
      end
    end
      
    def test_for_unnecessary_whitespace_in_keys
      return if !Lion.using_natural_keys || !Lion.fail_on_unnecessary_whitespace_in_translations
      err_keys = []
      translations_hash = Lion::Query.get_translations_hash
      translations_hash.keys.each do |iso|
        translations_hash[iso].keys.each do |key|
          if key.to_s.size != key.to_s.squish.size
            err_keys << key if !err_keys.include?(key)
          end
        end
      end
      if err_keys.any?
        flunk "These keys have unnecessary whitespace. This is just asking for errors. Please fix this.\n" + err_keys.uniq.map{|key| "\"#{key.to_s.un_substitute_characters}\""}.join("\n")
      end
    end
    
    def test_for_unregistered_strings
      unregistered_keys = Lion::Query.find_unregistered_keys
      if unregistered_keys.any?
        fail_str = "found new keys:\n"
        unregistered_keys.each_pair do |key,filename|
          fail_str << " - \"#{key}\" (#{filename.sub(/#{RAILS_ROOT}#{File::SEPARATOR}/,"")})\n"
        end
        fail_str << "\n\nPlease run the following command to add your new keys and automatically copy them to the other locales\n\n./rake lion:add_new_keys\n\n"
    
        flunk fail_str
      end
    end
    
    def test_finding_unregistered_strings
      test_file = File.join(Rails.root, 'vendor/plugins/lion/test/file_that_tests_do_stuff_to.txt')
      keys_it_should_find = []
      File.open(test_file, 'w') do |f|
        Lion.translation_method_names_that_are_harvested.each do |method_name|
          key = "#{method_name}_on_its_own_line"
          keys_it_should_find << key
          f << "#{method_name}('#{key}')\n"
        end
        one_line = ''
        Lion.translation_method_names_that_are_harvested.each do |method_name|
          key = "#{method_name}_in_line_with_other_methods"
          keys_it_should_find << key
          one_line += "#{method_name}('#{key}')"
        end
        f << one_line + "\n"
      end
      Lion::Query.stubs(:files_to_search_for_translation_strings).returns([test_file])
      assert_equal keys_it_should_find.sort, Lion::Query.find_unregistered_keys.keys.sort
    end
    
    def test_all_have_valid_batch_values
      invalid_batch_rows = []
      Lion.all_csv_files.each do |filepath|
        csv = Lion::CSV.get(filepath)
        csv.rows.each do |row|
          if row.batch.to_i == 0 && !row.batch.blank? && (row.batch != '?')
            invalid_batch_rows << "invalid batch number \"#{row.batch}\" for key \"#{row.key}\" in file \"#{filepath}\""
          end
        end
      end
      if invalid_batch_rows.any?
        flunk invalid_batch_rows.join("\n")
      end
    end
      
    def test_all_default_locale_keys_have_translations
      translations_hash = Lion::Query.get_translations_hash[Lion.default_locale.to_sym]
      untranslated_english_keys = []
      translations_hash.keys.each do |key|
        untranslated_english_keys << key if translations_hash[key].blank?
      end
      if untranslated_english_keys.any?
        flunk "these english strings had no translations: #{untranslated_english_keys.inspect}"
      end
    end
    
    def test_keys_and_default_locale_translations_match
      return if !Lion.using_natural_keys
      I18n.locale = Lion.default_locale
      unmatched_pairs = ""
      (Lion::Translate.translation_keys_stringified - Lion::Query.all_key_strings_that_can_be_different_from_their_default_locale_translation).each do |key|
        translated_value = mock_translate(key)
        if key != translated_value
          unmatched_pairs += "\"#{key}\" != \"#{translated_value}\n\""
        end
      end
      if !unmatched_pairs.blank?
        flunk "These keys do not match the default_locale translation.\n\n#{unmatched_pairs}\n\nPlease run rake lion:change_keys_that_are_different_from_default_locale_translation to fix this."
      end
    end
      
    def test_translate_into
      this_locale = 'asdf'
      other_locale = 'qwer'
      the_key = 'the key'
      with_fake_translations({this_locale => [{the_key => the_key}], other_locale => [{the_key => "#{the_key} in other locale"}]}) do      
        I18n.locale = other_locale
        translation = unharvested_translate(the_key)
        I18n.locale = this_locale
        assert_not_equal unharvested_translate(the_key), Lion::Translate.translate_into(other_locale, the_key), "111 something was wrong with #{the_key}"
        assert_equal translation, Lion::Translate.translate_into(other_locale, the_key), "222 something was wrong with #{the_key}"
      end
    end
      
    def test_if_csv_has_outdated_screenshot_test_names
      csv_test_names = []
      Lion.used_csv_files.each do |csv_file|
        data = Lion::CSV.get(csv_file)
        csv_test_names += data.rows.map{|row| row.test_name.gsub(Lion::CSV.was_string, '') if !row.test_name.blank?}.uniq.compact
      end
      all_test_names = Lion::Screenshots.all_selenium_test_names
      outdated_test_names = csv_test_names.uniq - all_test_names.uniq
      assert outdated_test_names.empty?, "We have some outdated test_names in our csvs. If this test has been deleted in this commit, please delete it in the appropriate csv.  If the test name has been changed, then please change the name in the appropriate csv.  Here are the test_names: #{outdated_test_names.inspect}"
    end
      
      
    def test_csvs_are_valid
      final_errors = []
      translations_hash_keys = Set.new(Lion::Translate.translation_keys_stringified)
      (Lion.used_translations_directories + Lion.unused_translations_directories).each do |dir|
        Lion::CSV.csv_files_for(dir).each do |file|
          show_progress("testing validity of #{dir}/#{file}")
          errors = Lion::CSV.get(file).validate(:check_that_keys_are_in_our_system => (Lion.unused_translations_directories.include?(dir) ? false : true),
            :return_errors => true, :hash_keys=>translations_hash_keys)
          final_errors << "had these errors for #{dir}/#{file}: #{errors.join("\n\n\n")}" if errors.any?
        end
      end

      all_used_csv_keys = []
      Lion.used_translations_directories.each do |dir|
        Lion::CSV.csv_files_for(dir).each do |file|
          show_progress("testing that strings in #{dir}/#{file} are consistent with the strings that were loaded")
          data = Lion::CSV.get(file)
          if data.rails_translation?
            data.keys.each do |key|
              top_level_key = key.split('.').first.to_sym
              all_used_csv_keys << top_level_key
              final_errors << "\"#{top_level_key}\" was not in master hash\n" if !translations_hash_keys.include?(top_level_key.to_s)
            end
          else
            all_used_csv_keys += data.keys
            data.keys.each do |key|
              final_errors << "\"#{key}\" was not in master hash\n" if !translations_hash_keys.include?(key)
            end
          end
        end
      end
      show_progress("testing that the sum total of all csv strings represent every key that was loaded into the environment")
      keys_the_master_hash_had_that_the_csvs_did_not = (translations_hash_keys.map(&:to_s).sort - all_used_csv_keys.map(&:to_s).sort - keys_that_were_added_outside_of_csv)
      keys_the_csvs_had_that_the_master_hash_did_not = (all_used_csv_keys.map(&:to_s).sort - translations_hash_keys.map(&:to_s).sort)
      if keys_the_master_hash_had_that_the_csvs_did_not.any?
        final_errors << "The master hash had more keys than the csvs: #{keys_the_master_hash_had_that_the_csvs_did_not.inspect}"
      end
      if keys_the_csvs_had_that_the_master_hash_did_not.any?
        final_errors << "The csvs had more keys than the master hash: #{keys_the_csvs_had_that_the_master_hash_did_not.inspect}"
      end
      unused_keys = []
      Lion.unused_csv_files.each do |file|
        show_progress("testing that strings in unused/#{file} are NOT contained in the strings that are loaded into the environment")
        data = Lion::CSV.get(file)
        unused_keys += data.keys
        data.keys.each do |key|
          final_errors << "\"#{key}\" was in master hash BUT WAS NOT SUPPOSED TO BE\n" if translations_hash_keys.include?(key)
        end
      end
      assert final_errors.empty?, "had these errors:\n#{final_errors.join("\n")}"
    end
    
    def test_all_symbolic_keys_are_valid
      return if Lion.using_natural_keys
      # we want keys to be able to be valid file names for screenshotting.
      bad_keys = Lion::CSV.all_csv_keys.select{|key| key !~ /^[a-zA-Z0-9_\.-]+$/}
      flunk "Here are some invalid keys #{bad_keys.inspect}" if bad_keys.any?
    end
  
    def test_we_have_translations_for_supported_locales
      Lion.supported_locales.each do |iso|
        assert_nothing_raised do
          unharvested_translate(Lion.locale_language_key(iso))
        end
      end
    end
  
    def test_i18n_production_interpolation_on_missing_translation
      return if !Lion.using_natural_keys
      Lion.expects(:raise_on_missing_translations).returns(false)
      Rails.stubs(:test?).returns(false)
      interpolated_string = unharvested_translate('this does not {{exist}}', :exist => 'aaa')
      assert_equal 'this does not aaa', interpolated_string
    end
  
    def test_i18n_production_interpolation_does_not_mess_up_missing_translations_when_there_is_no_interpolation_to_be_done
      Lion.stubs(:raise_on_missing_translations).returns(false)
      Lion.stubs(:raise_on_untranslated_translations).returns(false)
      Rails.stubs(:test?).returns(false)
      translated_string = unharvested_translate('this does not exist', {}, false)
      if Lion.using_natural_keys
        assert_equal 'this does not exist', translated_string
      else
        assert_equal nil, translated_string
      end
    end
  
    def test_i18n_exception_notifier_sends_on_missing_translation
      RosettaStone::GenericExceptionNotifier.expects(:deliver_exception_notification)
      assert_raises I18n::MissingTranslationData do
        unharvested_translate('this does not {{exist}}', :exist => 'exist')
      end
    end

    def test_i18n_exception_notifier_sends_on_missing_interpolation
      return if RosettaStone::RailsVersionString > RosettaStone::VersionString.new(2,3,4)
      Lion.stubs(:raise_on_mismatched_interpolations_in_translations).returns(true)
      RosettaStone::GenericExceptionNotifier.expects(:deliver_exception_notification)
      with_fake_translations({'en-US' => [{'asdf {{qwer}}' => 'asdf {{qwer}}'}]}) do
        assert_raises I18n::MissingInterpolationArgument do
          unharvested_translate('asdf {{qwer}}')
        end
      end
    end
  
    def test_we_have_keys_for_time_zones
      return if !File.exists?(File.join(Rails.root, 'config', 'translations', 'static', 'time_zones.csv'))
      ::ActiveSupport::TimeZone.all.map(&:name).each do |time_zone|
        assert_nothing_raised do
          translate_from_default_locale_string(time_zone)
        end
      end
    end

    def test_if_interpolations_are_consistent_across_languages
      errors = []
      Lion::CSV.all_used_csv_data.each do |row|
        key_is_from_rails_translation = false
        rails_default_interp_keys = ['attribute','model','count']

        default_locale_interp_keys = Lion::Utilities.get_interpolation_keys(row.field(Lion.default_locale.to_s), false).uniq
        #Only check if this key is from rails if it has one of the rails interpolations
        #Otherwise, we'll be here all night.
        if ((default_locale_interp_keys & rails_default_interp_keys).length > 0)
          key_is_from_rails_translation = Lion::CSV.file_from_key(row.key).rails_translation?
        end
        default_locale_interp_keys -= rails_default_interp_keys if key_is_from_rails_translation
        (Lion.supported_locales - [Lion.default_locale]).each do |locale|
          next if row.field(locale.to_s).blank?
          interp_keys = Lion::Utilities.get_interpolation_keys(row.field(locale.to_s), false).uniq
          interp_keys -= rails_default_interp_keys if key_is_from_rails_translation
          if (default_locale_interp_keys != interp_keys) && (Lion.inconsistent_interpolation_strings && !Lion.inconsistent_interpolation_strings.include?(row.key))
            errors << "problem with #{row.key} in #{locale} regarding locale interpolation keys #{interp_keys.inspect} not matching default_locale #{default_locale_interp_keys.inspect}"
          end
        end
      end
      flunk errors.join("\n") if errors.any?
    end
  
    private



    def find_missing_translations_for(this_iso_code, translations_hash)
      translations_hash[this_iso_code.to_sym].keys.each do |string_to_translate|
        Lion.supported_locales.each do |iso_code|
          assert_not_nil translations_hash[iso_code.to_sym][string_to_translate], "missing translation for '#{string_to_translate}' in #{iso_code}. Have you run 'rake i18n:copy'?"
        end
      end
    end
  
    def get_duplicate_keys(keys1, keys2)
      diff_of_keys = keys1 - keys2
      return (diff_of_keys.size != keys1.size) ? (keys1 - diff_of_keys) : []
    end
  
    def assert_valid_translations(iso)
      begin
        I18n.locale = iso
        assert_nothing_raised do
          Lion::Query.get_translations_hash[iso.to_sym].keys.each do |key|
            mock_translate(key)
          end
        end
      ensure
        I18n.locale = Lion.default_locale
      end
    end
  
    # Here is an example of a model translation you can put in test/unit/translation_test.rb
    # def test_model_translations
    #   assert_model_translations_work(site_messages(:maintenance), :body, "this is the new maintenance message")
    # end
  
    def assert_model_translations_work(model_instance, attribute, original_value)
      I18n.locale = Lion.default_locale
      other_locale = Lion.supported_locales.detect{|iso| iso != Lion.default_locale}
      assert_equal original_value, model_instance.send(attribute)
      model_instance.update_attribute(attribute, original_value + 'changed')
      assert_equal original_value + 'changed', model_instance.send(attribute)
      I18n.locale = other_locale
      model_instance.update_attribute(attribute, 'other value')
      assert_equal 'other value', model_instance.send(attribute)
      I18n.locale = Lion.default_locale
      assert_equal original_value + 'changed', model_instance.send(attribute)
      I18n.locale = 'xx-XX'
      model_instance.update_attribute(attribute, 'xx-XX value') # will create a new row, not update an existing one
      assert_equal 'xx-XX value', model_instance.send(attribute)
    end
  
    # Here is an example of a test that would use the helper below.
    # def test_deleting_object_with_model_translations
    #   book = books(:one)
    #   book.chapters.destroy_all
    #   assert_deleting_object_with_model_translations(book)
    # end
  
    def assert_deleting_object_with_model_translations(model_instance)
      # the model_instance needs to have all associations deleted already to prevent THOSE errors from raising at the end of this test
      localizations_count = model_instance.translations.size
      assert localizations_count >= 1
      model_name = model_instance.class.to_s
      assert_difference("#{model_name}.count", -1) do
        assert_difference("#{model_name}Translation.count", -1 * localizations_count) do
          assert_nothing_raised do
            model_instance.destroy
          end
        end
      end
    end
  
    def get_hash_counts_of_keys(hash_counts_of_keys, keys_to_look_at)
      keys_to_look_at.each do |key|
        hash_counts_of_keys[key] = hash_counts_of_keys[key] ? (hash_counts_of_keys[key] + 1) : 1
      end
      hash_counts_of_keys
    end
  
    def dups_in_array(a)
      a.inject({}) {|h,v| h[v]=h[v].to_i+1; h}.reject{|k,v| v==1}.keys
    end
    
    def show_progress(s)
      puts s if ENV['show_translation_test_output'] == 'true'
    end
    
    def with_fake_translations(hash, &block)
      # hash will be something like this: {'en-US' => [{'asdf' => 'asdf'}, {'qwer' => 'qwer'}], 'fr-FR' => [{'zxcv' => 'zxcv'}]}
      hash.keys.each do |locale|
        hash[locale].each do |key_value|
          I18n.backend.store_translations locale, key_value.keys.first.to_sym => key_value.values.first
        end
      end
      
      yield
    ensure
      # now reload because we just screwed up the hash
      I18n.backend.send(:reload!)
      I18n.backend.send(:init_translations)
      I18n.backend.send(:load_translations)
    end

    def keys_that_were_added_outside_of_csv
      keys = []
      keys = Lion.programmatically_added_keys
    rescue
      keys
    end

    #Note that this is really for Viper, since Viper uses Rails normal validations, so a key may
    #be "activerecord.errors...." in the translation csv, but that turns into {:activerecord=>:errors..}
    #in the translation hash.  So, we want to at least get all the translated strings that are in
    #the activerecord hash
    def values_for_key(translation_hash, key)
      if !translation_hash[key].is_a?(Hash)
        return [translation_hash[key]]
      else
        return find_strings_in_hash(translation_hash[key])
      end
    end

    def find_strings_in_hash(hash)
      hash.keys.map do |key|
        if hash[key].is_a?(Hash)
          find_strings_in_hash(hash[key])
        else
          hash[key]
        end
      end.flatten
    end
  end
end
