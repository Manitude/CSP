namespace :lion do

  desc "creates the appropriate directories, config file, etc."
  task :setup => :environment do
    Lion::CSV.make_empty_csv('dynamic', 'strings.csv')
    Lion::CSV.make_empty_csv('static', 'strings.csv')
    Lion::CSV.make_empty_csv('unused', 'strings.csv')
    Lion::CSV.make_empty_csv('io', 'input.csv')
    Lion::CSV.make_empty_csv('io', 'output.csv')
  end

  desc "populate from gettext po files"
  task :import_gettext => :environment do
    po_dirs = {'de' => 'de-DE', 'es' => 'es-419', 'fr' => 'fr-FR', 'it' => 'it-IT', 'ja' => 'ja-JP', 'ko' => 'ko-KR', 'zh' => 'zh-CN'}

    csv_path = ENV['csv']
    csv_path = "db/translations/dynamic/strings.csv" if ENV['csv'].blank?
    puts "importing into #{csv_path}"
    current_csv = Lion::CSV.get(csv_path)
    # current_csv
    current_csv.rows.each do |current_row|
      old_key = current_row['en-US']
      subs = old_key.scan(/\{\{\w+\}\}/) || []
      subd_key = old_key.gsub(/\{\{\w+\}\}/, "%s")
      po_dirs.each do |k,v|
        GetText.set_locale(k)
        puts "#{k} #{GetText._(subd_key)} (#{subs})"
        #if GetText._(subd_key) == subd_key
        #  current_row[v] = nil
        #else
        current_row[v] = GetText._(subd_key) % subs
        #end
        current_csv.add_or_update_row(current_row)
      end
    end
  end

  desc "change one english string. IMPORTANT: it only changes the english string.  All other translations stay the same and are not blanked out.  PLEASE DIFF AFTER RUNNING THIS."
  task :change_one_english_string => :environment do
    raise 'please specify from="blah blah blah" to="BLAH BLAH BLAH"' if ENV['from'].blank? || ENV['to'].blank?
    change_keys_that_are_different_from_default_locale_translation([[ENV['from'], ENV['to']]])
  end

  desc "change_keys_that_are_different_from_default_locale_translation"
  task :change_keys_that_are_different_from_default_locale_translation => :environment do
    change_keys_that_are_different_from_default_locale_translation
  end

  desc "keys_that_are_different_from_default_locale_translation"
  task :keys_that_are_different_from_default_locale_translation => :environment do
    keys_that_are_different_from_default_locale_translation
  end

  desc "this finds all lines in the app that call the method awaiting_default_locale_string"
  task :find_awaiting_strings => :environment do
    files_and_lines = Lion::Query.files_and_lines_that_have_a_string_in_them('awaiting_default_locale_string')
    files_and_lines.each{ |fl| puts fl }
  end

  desc "harvest characters like Å and Ö which we can substitute for A and O until ruby doesn't suck at sorting multibyte characters. for now, harvesting them on an as-needed basis, using this task"
  task :find_diacritics => :environment do
    translations_hash = Lion::Query.get_translations_hash
    weird_chars = []
    Lion.latin_character_locales.each do |iso|
      translations_hash[iso.to_sym].keys.each do |key|
        s = translations_hash[iso.to_sym][key]
        while (s =~ /([^A-Za-z0-9\!\@\#\$\%\^\&\*\(\)\_\+\-\–\=\{\}\|\\\\\[\]\:\"\;\'\<\>\?\,\.\/\n\r\“\„\…\¡\¿\º ])/) do
          weird_chars << $1 if !weird_chars.include?($1)
          s.gsub!($1, '')
        end
      end
    end
    weird_chars.each do |wc|
      puts wc
    end
  end

  # --------------------------------- #
  # ----------- main tasks ---------- #
  # --------------------------------- #

  desc "Take screenshots of translated phrases using selenium. It is required to provide every environment variable. See the code for the required environment variables"
  task :screenshots_with_args => :environment do
    raise 'please specify true/false for on_every_click' if ENV['on_every_click'].blank?
    raise 'please specify a comma-delimited list of locales, or "all" for translation_screenshot_locale' if ENV['translation_screenshot_locale'].blank?
    raise 'please specify true/false for use_chosen_tests' if ENV['use_chosen_tests'].blank?
    screenshots
  end

  desc "resets the screenshot values in output.csv for the default_locale so you can pretend that you're at the start of a screenshot harvest... mostly for debugging purposes"
  task :reset_screenshot_values_in_output_csv => :environment do
    reset_screenshot_values_in_output_csv(Lion.default_locale.to_s)
  end

  desc "diff the csv with the current version in svn"
  task :diff_csv => :environment do
    csv_path = ENV['csv']
    csv_path = "db/translations/dynamic/strings.csv" if ENV['csv'].blank?
    puts "diff for #{csv_path}"
    current_csv = Lion::CSV.get(csv_path)
    csv_in_svn = Lion::CSV.parse(%x[svn cat #{csv_path}])
    current_csv.rows.each do |current_row|
      svn_row = csv_in_svn.row_for_key(current_row.key)
      if svn_row.nil?
        puts "key \"#{current_row.key}\" is not in svn"
      else
        right_diff = current_row.to_hash.diff(svn_row.to_hash)
        left_diff = svn_row.to_hash.diff(current_row.to_hash)
        if !right_diff.empty?
          puts "------------\n\"#{current_row.key}\""
          puts "column: old >> new"
          right_diff.keys.each_with_index do |col, ii|
            puts "#{col}: #{left_diff[col]} >> #{right_diff[col]}"
          end
        end
      end
    end
  end

  desc "diff the English strings in the current csv with the csv at rev"
  task :diff_csv_english => :environment do
    file = ENV['file'] || 'strings.csv'
    dir = ENV['dir'] || 'dynamic'
    if ENV['rev'].blank?
      raise "You must include the rev number to compare against"
    end
    current_csv = Lion::CSV.get_from_dir_and_file(dir,file)
    old_csv = Lion::CSV.parse(%x[svn cat -r #{ENV['rev']} #{Lion::CSV.filepath_for(dir, file)}])
    new_keys = []
    current_csv.rows.each do |current_row|
      old_row = old_csv.row_for_key(current_row.key)
      if old_row.nil?
        new_keys << current_row.key
      else
        left_diff = old_row['en-US']
        right_diff = current_row['en-US']
        if left_diff != right_diff
          puts "------------ Changed English ---------------"
          puts "key : #{current_row.key}"
          puts "from: #{left_diff}"
          puts "to  : #{right_diff}"
          puts "--------------------------------------------"
        end
      end
    end
    if new_keys.length > 0
      puts "---------------------------"
      puts "The following are new keys:"
      new_keys.each{|nk| puts nk}
      puts "---------------------------"
    end
  end

  desc "string='The string I want to find' ./rake lion:find_this_string will look up all keys for strings that partially match case-insensitively. It will search the default_locale by default, but if you want to search another locale, add locale=fr-FR or whatever locale you want"
  task :find_this_string => :environment do
    string = ENV['string']
    locale = ENV['locale'].blank? ? Lion.default_locale.to_s : ENV['locale']
    raise 'Please specify string="something you want to search for"' if string.blank?
    raise "#{locale} is not a supported locale" if !Lion.supported_locales.map(&:to_s).include?(locale)
    matched_rows = Lion::CSV.all_csv_data.select { |current_row| current_row[locale] =~ /#{string}/i }

    if matched_rows.any?
      matched_rows.map{|current_row| current_row.key}.each { |key| puts Lion::Query.files_and_lines_that_have_a_string_in_them(key) }
    else
      puts "Nothing found"
    end
  end

  desc "key=About_You944230572 ./rake lion:test_name_for_key will give you the test_name that harvests this key"
  task :test_name_for_key => :environment do
    puts Lion::Screenshots.camelized_test_name_for_key(ENV['key'])
  end

  desc "key=About_You944230572 ./rake lion:screenshot_for_key will run the test and hopefully harvest this key, if it has a test_name associated with it."
  task :screenshot_for_key => :environment do
    current_row = Lion::CSV.all_csv_data.detect { |current_row| current_row.key == ENV['key'] }
    #"SingleSession::ProfileTest: test_add_delete_language"
    raise "there was no test_name for this key" if current_row.test_name.blank?
    ENV['single_test'] = Lion::Screenshots.full_test_path_from_test_name(current_row.test_name)
    ENV['on_every_click'] = 'true'
    ENV['only_shoot_this_key'] = ENV['key']
    screenshots.each{|line| puts line}
  end

  desc "key=About_You944230572 ./rake lion:practice_screenshot_for_key will run the test and will tell you if the key is harvestable"
  task :practice_screenshot_for_key => :environment do
    current_row = Lion::CSV.all_csv_data.detect { |current_row| current_row.key == ENV['key'] }
    #"SingleSession::ProfileTest: test_add_delete_language"
    raise "there was no test_name for this key" if current_row.test_name.blank?
    ENV['single_test'] = Lion::Screenshots.full_test_path_from_test_name(current_row.test_name)
    ENV['on_every_click'] = 'true'
    ENV['only_shoot_this_key'] = ENV['key']
    ENV['suppress_actual_shot'] = 'true'
    ENV['source'] = 'all'
    with_clearing_output_csv do
      screenshots.each{|line| puts line}
    end
  end

  task :screenshot_harvest => :environment do
    # even though def screenshot will reset RAILS_ENV to test, we need the environment to load with production so ActionMailer can be set up properly for emails to be sent
    raise "Please specify RAILS_ENV=production or the emails will not send" if ENV['RAILS_ENV'] != 'production'
    raise "You apparently do not have your screenshot directory set up at #{Lion.screenshots_base_file_path}" if !File.exist?(Lion.screenshots_base_file_path)
    puts "reverting screenshots and svn upping"
    puts %x[cd #{Lion.screenshots_base_file_path};svn revert -R *;svn up]
    puts "reverting and upping app code and db:migrating"
    puts %x[svn revert -R *;svn up;./rake db:migrate; ./rake db:test:prepare]
    # FIXME: put this in configs
    ActionMailer::Base.smtp_settings = {
      :address =>        "relay.rosettastone.local",
      :port =>           25,
      :domain =>         "rosettastone.com",
    }
    ENV['on_every_click'] = 'true'
    ENV['use_chosen_tests'] = 'true'
    merge_screenshotable_strings_into_input_csv
    puts "=========================PROBLEMS=========================="
    problems = update_csvs_and_blame(screenshots)
    if problems.any?
      ENV['RAILS_ENV'] = 'production' # so the emails can send.. it was set to test in def screenshot so the testing framework will work
      Lion.send_mail('Problems with the screenshot build', problems.map{|line| line.chomp}) if ENV['do_not_send_email'] != 'true'
    else
      diffs = ""
      Lion.used_csv_files.each do |fp|
        diffs += %x[csv=#{fp} ./rake lion:diff_csv]
      end
      diff_array = diffs.split("\n")
      diff_array.each{|line| puts line.chomp}
      Lion.send_mail('Screenshot build success! Here are the diffs', diff_array.map{|line| line.chomp}) if ENV['do_not_send_email'] != 'true'
      write_markdown_for_all_batches
      commit_after_screenshot_harvesting if ENV['do_not_commit'] != 'true'
    end
  end

  desc "merges screenshotable strings into input.csv"
  task :merge_screenshotable_strings_into_input_csv => :environment do
    merge_screenshotable_strings_into_input_csv
  end

  desc "updating csvs and blaming people"
  task :update_csvs_and_blame => :environment do
    update_csvs_and_blame
  end

  desc "commits the screenshot pngs, csvs, markdown, and story docs"
  task :commit_after_screenshot_harvesting => :environment do
    commit_after_screenshot_harvesting
  end

  desc "run one test in screenshot mode, taking all screenshots that that test can take.  It will use input.csv as source and edit the output.csv file"
  task :take_all_screenshots_from_one_test => :environment do
    raise "Please specify single_test=test/selenium/single_session/your_test_file.rb -n test_my_stuff" if ENV['single_test'].blank?
    ENV['on_every_click'] = 'true'
    ENV['single_test'] = Lion::Screenshots.full_test_path_from_test_name(ENV['single_test'])
    with_resetting_output_csv do
      screenshots.each{|line| puts line}
    end
  end

  desc "run one test in screenshot mode, taking only the screenshots it hasn't yet taken (because output.csv says it hasn't). It will edit the output.csv file"
  task :retake_screenshots_from_one_test => :environment do
    raise "Please specify single_test=test/selenium/single_session/your_test_file.rb -n test_my_stuff" if ENV['single_test'].blank?
    ENV['single_test'] = Lion::Screenshots.full_test_path_from_test_name(ENV['single_test'])
    ENV['on_every_click'] = 'true'
    screenshots.each{|line| puts line}
  end

  desc "verify that the shot would be taken on a specific test, but do not take the shot. This allows developers to see if the screenshot will be harvested, but does not require the screenshot directories to be set up"
  task :practice_screenshot_harvest_from_one_test => :environment do
    raise "Please specify single_test=test/selenium/single_session/your_test_file.rb -n test_my_stuff" if ENV['single_test'].blank?
    ENV['single_test'] = Lion::Screenshots.full_test_path_from_test_name(ENV['single_test'])
    ENV['on_every_click'] = 'true'
    ENV['suppress_actual_shot'] = 'true'
    ENV['source'] = 'all'
    with_clearing_output_csv do
      screenshots.each{|line| puts line}
    end
  end

  desc "just like practice_screenshot_harvest_from_one_test except it just runs the test in screenshot mode, but not stopping every click to take shots"
  task :quick_practice_screenshot_harvest_from_one_test => :environment do
    raise "Please specify single_test=test/selenium/single_session/your_test_file.rb -n test_my_stuff" if ENV['single_test'].blank?
    ENV['single_test'] = Lion::Screenshots.full_test_path_from_test_name(ENV['single_test'])
    ENV['on_every_click'] = 'false'
    ENV['suppress_actual_shot'] = 'true'
    ENV['source'] = 'all'
    with_clearing_output_csv do
      screenshots.each{|line| puts line}
    end
  end

  desc "Runs all tests and takes screenshots.  This is very slow."
  task :run_tests_and_take_screenshots => :environment do
    ENV['on_every_click'] = 'true'
    screenshots
  end

  desc "Runs only the tests that we know will harvest the screenshots in question in input.csv"
  task :run_chosen_tests_and_take_screenshots => :environment do
    ENV['on_every_click'] = 'true'
    ENV['use_chosen_tests'] = 'true'
    screenshots
  end

  desc "Updates the csvs with the screenshot data collected in output.csv"
  task :update_csvs_from_output_csv => :environment do
    update_csvs_from_output_data.each{|line| puts line}
  end

  desc "all_untranslated_keys"
  task :all_untranslated_keys => :environment do
    puts Lion::Query.untranslated_keys.join("\n")
  end

  desc "all_untranslated_screenshotable_keys"
  task :all_untranslated_screenshotable_keys => :environment do
    puts Lion.all_untranslated_screenshotable_keys.join("\n")
  end

  #FIXME: make it so that you do not have to specify the destination
  desc "Transfers translation data from input.csv into the appropriate destination csv file. If 'from=output', then output is copied to input.  For example: destination_directory=dynamic destination_file=strings.csv increment_status=true ./rake lion:import"
  task :import => :environment do
    FileUtils.cp(Lion::CSV.output_csv.path, Lion::CSV.input_csv.path) if ENV['from'] == 'output'
    import_file_path = Lion::CSV.filepath_for('io', ENV['input_file'] || 'input.csv')
    puts "Importing from #{import_file_path}"
    columns = ENV['columns'].split(',') if ENV['columns'] #If you want, you can say 'columns=en-US,fr-FR' and only change en-US and fr-FR values
    raise 'Import file did not exist' if !File.exist?(import_file_path)
    import_csv = Lion::CSV.get(import_file_path)
    if ENV['increment_status'] == 'true'
      raise 'There is more than one status in this file, and increment_status is on.  This makes me nervous.  Please make all statuses the same, or turn off increment_status' if import_csv.rows.map{|current_row| current_row.status}.uniq.size > 1
    end
    if import_csv.validate(:check_that_keys_are_in_our_system => false)
      import_csv.rows.each do |current_row|
        current_row[current_row.index('status')] = Lion::CSV.status_after(current_row.status) if ENV['increment_status'] == 'true'
        destination_file = Lion::CSV.file_from_key(current_row.key)
        if destination_file
          rows_to_merge = columns || Lion::CSV.columns_safe_to_merge
          destination_file.merge_row(current_row, rows_to_merge)
        else
          puts "\n\n\n\n\n\n================================================================================================="
          puts "The key \"#{current_row.key}\" must have been deleted. Not my fault."
          puts "=================================================================================================\n\n\n\n\n\n"
        end
      end
      if ENV['skip_tests'] != 'true'
        puts "==== now running tests... ===="
        ENV['show_translation_test_output'] = 'true'
        puts %x[ruby test/unit/translation_test.rb] if ENV['do_not_run_tests'] != 'true'
      end
    else
      puts "Nothing was imported"
    end
  end

  desc "saves the csv with the FasterCSV format (optionally specify args file=blah.csv dir=dynamic), just in case you edited it with OpenOffice or Excel and got the quotes all different.  This allows for more accurate diffs... plus it sorts it!"
  task :save_csv => :environment do
    file = ENV['file'] || 'strings.csv'
    dir = ENV['dir'] || 'dynamic'
    Lion::CSV.get_from_dir_and_file(dir, file).sort
  end

  desc "Often, if you save a csv with a spreadsheet it will change how the quoting is done.  This sorts and saves the FasterCSV way, so the diffs are better"
  task :save_csvs => :environment do
    Lion.all_csv_files.each{|file_path| Lion::CSV.get(file_path).sort}
  end

  desc "valid_statuses"
  task :valid_statuses => :environment do
    puts Lion::CSV.statuses.join("\n")
  end

  desc "returns all the keys that have the status you provide as an environment variable.  For a list of statuses, run rake lion:valid_statuses"
  task :keys_with_status => :environment do
    check_for_stat
    Lion.used_csv_files.each do |filepath|
      csv = Lion::CSV.get(filepath)
      puts csv.select(:status => ENV['stat']).map{|current_row| current_row.key}.join("\n")
    end
  end

  desc "Edit cells in csv file(s) based on criteria. For example, target_dir=dynamic target_file=strings.csv where_status=not_approved edit_batch=9 ./rake edit_with_criteria (see code for more examples)"
  task :edit_with_criteria => :environment do
    # examples:
    # -- this will change all rows in dynamic/strings.csv with status of not_approved to have the value 9 in the batch column
    # target_dir=dynamic target_file=strings.csv where_status=not_approved edit_batch=9 ./rake lion:edit_with_criteria
    # -- this will change all rows in dynamic/strings.csv with en_dash_US to have the value 9 in the batch column
    # target_dir=dynamic target_file=strings.csv where_en_dash_US=Hello edit_en_dash_US="Hello there" ./rake lion:edit_with_criteria
    # -- this will change all rows in dynamic/strings.csv to have a status of 'not_approved' if they have the word connection (case-insensitive) in the english translation
    # target_dir=dynamic target_file=strings.csv like_i_en_dash_US=connection edit_status=not_approved ./rake lion:edit_with_criteria
    target_dir = ENV['target_dir'] || raise('Please specify target_dir')
    target_file = ENV['target_file'] || raise('Please specify target_file')
    csv = Lion::CSV.get_from_dir_and_file(target_dir, target_file)
    csv.edit_with_criteria(get_select_hash, get_criteria_hash('edit'))
  end

  desc "export strings matching a certain criteria into output.csv.  For example, from=dynamic batch=4 to_batch=10 where_screenshotable=no where_status=verified increment_status=true ./rake export_with_criteria (see code for more examples)"
  task :export_with_criteria => :environment do
    # examples:
    # this will export non_or_partial and also the ones with status less than translated
    # translated=none_or_partial join_type=or where_status=not_approved__or__being_approved__or__approved__or__being_translated ./rake lion:export_with_criteria
    # -- this will look in all csvs in the dynamic directory with screenshotable=no and status=translated and will export them to io/output.csv, increment their statuses to 'being_verified' and edit their batch to 10
    # -- it will also set the source file's strings to batch=10
    # -- it will also set the source file's strings' statuses to 'being_verified'
    # from=dynamic where_screenshotable=no where_status=translated to_batch=10 increment_status=true ./rake lion:export_with_criteria
    # -- this will look in all used csv files (see lion.yml for which directories have used files) and export all en-US translations with the text "connection" (case-sensitively... for insensitive matching, use "like_i_"
    # like_en_dash_US=connection ./rake lion:export_with_criteria
    # -- this will print out everything but will not write to any file
    # like_en_dash_US=connection dry_run=true ./rake lion:export_with_criteria
    # -- this will get all partially translated or untranslated strings, and set them to batch 11 (other values for translated are 'none', 'all', and 'partial')
    # translated=none_or_partial to_batch=11 ./rake lion:export_with_criteria
    # -- this will get all appropriate strings for export... it includes all strings which are partially translated, AND it also contains strings that have a status of LESS than 'translated'
    # export_type=needs_any_translation ./rake lion:export_with_criteria
    raise 'invalid export_type.  must be all_appropriate' if ENV['export_type'] && !%w(needs_any_translation).include?(ENV['export_type'])
    ENV['translated'] = 'none_or_partial' if ENV['export_type'] == 'needs_any_translation'
    raise 'invalid value for increment_status... either do not provide it, or specify the value to be true' if !ENV['increment_status'].blank? && ENV['increment_status'] != 'true'
    raise 'increment_status=true yet you did not provide a status to filter by.  This would yield strange results, by auto-incrementing whatever status it found.' if ENV['increment_status'] == 'true' && ENV['where_status'].blank?
    raise 'invalid batch number' if !ENV['batch'].blank? && ENV['batch'].to_i == 0 && ENV['batch'] != 'null'
    raise 'invalid translated value.  must be all, partial, or none' if ENV['translated'] && !%w(all partial none none_or_partial).include?(ENV['translated'])
    untranslated_keys = Lion::Query.untranslated_keys if ENV['untranslated'] == 'true'
    output_csv = Lion::CSV.get_from_dir_and_file('io', 'output.csv')
    output_csv.clear
    all_rows = []
    batch = (ENV['to_batch'] == 'auto') ? Lion::Query.next_batch_number : ENV['to_batch']
    select_hash = get_select_hash
    select_hash['translated'] = ENV['translated'] if ENV['translated']
    csvs_to_export_from = ENV['from'].blank? ? Lion.used_csv_files : Lion::CSV.csv_files_for(ENV['from'])
    csvs_to_export_from.each do |filepath|
      csv = Lion::CSV.get(filepath)
      this_csv_rows = csv.select(select_hash)
      # edit the source csv's status and batch values
      this_csv_rows.each do |current_row|
        current_row[current_row.index('status')] = Lion::CSV.status_after(current_row.status) if ENV['increment_status'] == 'true'
        current_row[current_row.index('batch')] = batch if batch
        csv.add_or_update_row(current_row, false)
      end
      csv.save
      all_rows += this_csv_rows
    end

    all_rows.each do |current_row|
      puts "exporting \"#{current_row.key}\""
      output_csv.add_or_update_row(current_row, false) if ENV['dry_run'] != 'true'
    end
    if ENV['dry_run'] != 'true'
      output_csv.save
      if has_excel_export_capabilities?
        book = Spreadsheet::Workbook.new
        sheet = book.create_worksheet
        sheet.name = "Translations"
        output_csv.csv_table.to_a.each_with_index do |row, index|
          sheet.row(index).concat(row)
        end

        workbook = File.open(Lion::CSV.filepath_for('io', 'output.xls'), 'w+')
        book.write(workbook)
        workbook.close
      end
    end
  end

  desc "get the next batch number from all csvs"
  task :next_batch_number => :environment do
    puts Lion::Query.next_batch_number.to_s
  end

  desc "find_unregistered_keys"
  task :find_unregistered_keys => :environment do
    Lion::Query.find_unregistered_keys.keys.each{|key| puts key}
  end

  desc "automatically copies new translation keys into config/translations/dynamic/strings.csv, or if you specify dir=dynamic to=whatever.csv it will put it in dynamic/whatever.csv"
  task :replace_old_keys => :environment do
    to_file = ENV['to'] || 'strings.csv'
    to_dir = ENV['dir'] || 'dynamic'
    unregistered_strings = Lion::Query.find_unregistered_keys.keys
    translation_keys_stringified = Lion::Translate.translation_keys_stringified
    unregistered_strings.each do |string|
      new_key = Lion.convert_to_string_key(string)
      if translation_keys_stringified.include?(new_key)
        puts "UH OH! The key we tried to create for you, \"#{new_key}\" seems to already exist.  Perhaps you are trying to add a new string to translate, but we already have it translated... but you might also be trying to add a string that has the same word(s) but means something completely different.  If you are indeed mistakenly using the same string, then use the key for that string in the code.  If it is indeed a different string, then make up your own key and put it in the appropriate csv"
      else
        to_csv = Lion::CSV.get_from_dir_and_file(to_dir, to_file)
        to_csv.add_or_update_row(FasterCSV::Row.new(to_csv.headers, Lion::CSV.empty_row(new_key, string)))
        puts "\"#{new_key}\" added to the appropriate csv! (you're welcome)"
      end
    end
    if !Lion.using_natural_keys
      convert_keys_to_symbols(:keys_to_change => unregistered_strings, :update_csvs => false, :update_code => true, :update_screenshot_names => false, :run_test => false, :check_if_key_already_exists => false)
    end
    puts "==== now re-running tests... you're on your own after that ===="
    ENV['show_translation_test_output'] = 'true'
    puts %x[ruby test/unit/translation_test.rb]
  end



  desc "automatically copies new translation keys into config/translations/dynamic/strings.csv, or if you specify dir=dynamic to=whatever.csv it will put it in dynamic/whatever.csv"
  task :add_new_keys => :environment do
    to_file = ENV['to'] || 'strings.csv'
    to_dir = ENV['dir'] || 'dynamic'
    unregistered_strings = Lion::Query.find_unregistered_keys.keys
    translation_keys_stringified = Lion::Translate.translation_keys_stringified
    unregistered_strings.each do |string|
      new_key = Lion.convert_to_string_key(string)
      if translation_keys_stringified.include?(new_key)
        puts "UH OH! The key we tried to create for you, \"#{new_key}\" seems to already exist.  Perhaps you are trying to add a new string to translate, but we already have it translated... but you might also be trying to add a string that has the same word(s) but means something completely different.  If you are indeed mistakenly using the same string, then use the key for that string in the code.  If it is indeed a different string, then make up your own key and put it in the appropriate csv"
      else
        to_csv = Lion::CSV.get_from_dir_and_file(to_dir, to_file)
        to_csv.add_or_update_row(FasterCSV::Row.new(to_csv.headers, Lion::CSV.empty_row(new_key, string)))
        puts "\"#{new_key}\" added to the appropriate csv! (you're welcome)"
      end
    end
    if !Lion.using_natural_keys
      convert_keys_to_symbols(:keys_to_change => unregistered_strings, :update_csvs => false, :update_code => true, :update_screenshot_names => false, :run_test => false, :check_if_key_already_exists => false)
    end
    puts "==== now re-running tests... you're on your own after that ===="
    ENV['show_translation_test_output'] = 'true'
    puts %x[ruby test/unit/translation_test.rb]
  end

  desc "convert_keys_to_symbols... make sure to set the yml value of using_natural_keys to false before running this.... and get a beverage.  it will be awhile"
  task :convert_keys_to_symbols => :environment do
    convert_keys_to_symbols(:keys_to_change => Lion::CSV.all_csv_keys, :update_csvs => true, :update_code => true, :update_screenshot_names => true, :run_test => true, :check_if_key_already_exists => true)
  end

  desc "if you change auto_generated_symbolic_key_length you will have to run this task"
  task :update_things_that_depend_on_auto_generated_symbolic_key_length => :environment do
    raise 'You must provide I_HAVE_UPDATED_THE_SCREENSHOTS_DIRECTORY=true and be telling the truth' if ENV['I_HAVE_UPDATED_THE_SCREENSHOTS_DIRECTORY'] != 'true'
    raise 'Please provide from=50 or whatever number you previously had.  I will get the new value from lion.yml' if ENV['from'].blank?
    Lion::CSV.all_csv_keys.each do |new_key|
      old_key = Lion.convert_to_filename(new_key, ENV['from'])
      change_screenshot_name(:old_file_without_extension => old_key, :new_file_without_extension => Lion.convert_to_filename(new_key))
    end
    write_markdown_for_all_batches
  end

  desc "change a symbolic key"
  task :change_key => :environment do
    raise 'You must provide I_HAVE_UPDATED_THE_SCREENSHOTS_DIRECTORY=true and be telling the truth' if ENV['I_HAVE_UPDATED_THE_SCREENSHOTS_DIRECTORY'] != 'true'
    raise 'You must provide from=some_key' if ENV['from'].blank?
    raise 'You must provide to=some_new_key or to=_auto_assign_' if ENV['to'].blank?
    raise 'You have not set up your screenshots directory, so I refuse to continue' if !File.exist?(Lion.screenshots_base_file_path)
    change_key(:old_key => ENV['from'], :new_key => ENV['to'], :update_csvs => true, :update_code => true, :update_screenshot_names => true, :update_markdown => !ENV['update_markdown'].blank? )
  end

  desc "return a list of all the statuses currently in used csvs"
  task :current_used_statuses => :environment do
    Lion::CSV.all_used_csv_data.inject([]){|memo, current_row| memo << current_row.status}.uniq.each do |status|
      puts status
    end
  end

  desc "Use this to find which keys to delete from the lib/locale/*/*.yml files because they no longer exist in reality"
  task :find_unused_keys => :environment do
    keys_not_found = Lion::Query.find_unused_keys
    if keys_not_found.any?
      puts '-----------------------------------------------------------------------------------'
      puts "Here are #{keys_not_found.size} keys that don't appear to be in our rails codebase:"
      puts '-----------------------------------------------------------------------------------'
      keys_not_found.each do |key|
        puts key
      end
    else
      puts "Looks like every translation is accounted for in the code"
    end
  end

  desc "delete_unused_keys"
  task :delete_unused_keys => :environment do
    Lion::Query.find_unused_keys.each do |key|
      file = Lion::Query.find_file_for_key(key)
      if file
        #file could be null if the key came from outside of lion (yml files or programatically added)
        puts "moving \"#{key}\" to unused/strings.csv"
        Lion::CSV.get(file).move_key_to_unused(key)
      end
    end
  end

  desc "find_keys_that_do_not_have_screenshot_files_in_filesystem"
  task :find_keys_that_do_not_have_screenshot_files_in_filesystem => :environment do
    Lion.non_shot_keys.each do |key|
      puts key
    end
  end

  desc "finds alt and title tags that have translated text in them... can be used to find non-screenshotable strings, but is not necessarily an indicator, since they could be elsewhere in the code not within an alt tag"
  task :find_alt_and_title_tags_with_translations => :environment do
    Lion::Query.files_to_search_for_translation_strings.each do |file_path|
      File.foreach(file_path) do |line|
        if line =~ /alt=["']<%= _\(/ || line =~ /title=["']<%= _\(/
          puts "-----------------"
          puts file_path
          puts line
        end
      end
    end
  end

  desc "Windows hoses the linebreaks when converting to csv, so this unhoses them"
  task :fix_windows_csv => :environment do
    raise 'please specify filename=blah.csv' if ENV['filename'].blank?
    tmp_file = File.join(Rails.root, 'doc', 'translations', 'tmp_' + ENV['filename'])
    line = File.open(File.join(Rails.root, 'doc', 'translations', ENV['filename']), 'r').readlines.first
    File.open(tmp_file, 'w') do |f|
      f << line.gsub(/\r/, "\n")
    end
    `mv #{tmp_file} #{File.join(Rails.root, 'doc', 'translations', ENV['filename'])}`
    puts "DONE!"
  end

  desc "rebuilds all the markdown from data in the csvs."
  task :write_markdown_for_all_batches => :environment do
    write_markdown_for_all_batches
  end

  desc "find the english string in a file and replace it with its key. it does not have to be inside an underscore method. You must give it a file though"
  task :replace_default_locale_string_with_key => :environment do
    Lion::CSV.get_from_dir_and_file('static', 'countries.csv').rows.each do |current_row|
      if Lion::Query.found_string_in_file(ENV['file'], current_row.field(Lion.default_locale.to_s), current_row.key)
        puts "========== replaced \"#{current_row.field(Lion.default_locale.to_s)}\" with \"#{current_row.key}\" in #{ENV['file']} ========="
      end
    end
  end

  desc "fix_time_zone_keys"
  task :fix_time_zone_keys => :environment do
    ::ActiveSupport::TimeZone.all.map(&:name).each do |time_zone|
      Lion::CSV.get_from_dir_and_file('static', 'time_zones.csv').update_row_values("tz_#{time_zone}", :key => Lion.convert_to_string_key(time_zone))
    end
  end

  desc "Update product languages csv from the available products file"
  task :update_product_languages_csv => :environment do
    #Currently, this only works in Viper since this is where Viper's shared product_languages file
    #is, and Viper also has the static_resources plugin
    filename = File.join(Rails.root, 'db', 'translations', 'shared', 'product_languages.csv')
    raise "product languages file not found.  This task may only work in viper" unless File.exists?(filename)
    csv = Lion::CSV.new(filename)
    product_languages_not_in_file = {}
    Hash.from_xml(RosettaStone::StaticResources::AvailableProductsXml.fetch_current)['products']['product'].each do |product|
      rs_code, entry = product_languages_hash_entry(product)
      if ProductLanguages::V3_LANGUAGE_DATA.has_key?(rs_code)
        entry = ProductLanguages::V3_LANGUAGE_DATA[rs_code]
      else
        product_languages_not_in_file[rs_code] = entry
      end

      #Now, add the translation to the file
      new_row = {}
      new_row[:key] = entry[:translation_key]
      new_row[:context] = 'this is in a list of languages that Rosetta Stone software teaches'
      new_row[:status] = 'approved'
      new_row[:comment] = "Taken from Course locale files"
      new_row[:screenshotable] = 'no'
      new_row[:batch] = '1'
      Lion.supported_locales.each do |locale|
        new_value = translation_for_product_in_locale(product, locale)
        new_row[locale] = new_value if new_value
      end
      #Update the existing row with data from above, but
      #don't get rid of data that may already be there.
      updated_row = csv.row_for_key(new_row[:key]) || FasterCSV::Row.new(csv.headers, [])
      new_row.each_pair{|col, value| updated_row[col.to_s] = value}
      #Write new/updated translations to the file
      csv.add_or_update_row(updated_row, true)
    end
    if product_languages_not_in_file.length > 0
      puts "Put the following lines in the product_langauges.rb file:"
      product_languages_not_in_file.sort.each {|pl|puts "\"#{pl.first}\" => {:translation_key => \"#{pl.last[:translation_key]}\", :display_name => \"#{pl.last[:display_name]}\", :iso_code => '#{pl.last[:iso_code]}'}"}
    end
  end

end

private

def write_markdown_for_all_batches
  highest_batch_number = Lion::Query.next_batch_number - 1
  Lion.supported_locales.map(&:to_s).each do |iso|
    puts "writing markdown for #{iso}"
    1.upto(highest_batch_number) do |batch_num|
      puts "batch #{batch_num}"
      keys = []
      Lion.used_csv_files.each do |fp|
        csv = Lion::CSV.get(fp)
        keys += (csv.select('batch' => batch_num, "#{iso}_screenshot" => 'yes') + csv.select('batch' => batch_num, "#{iso}_screenshot" => "#{Lion::CSV.was_string}yes")).map{|current_row| current_row.key}
      end
      write_markdown(iso, batch_num, keys.sort, true)
    end
  end
  puts %x[./rake sg:build]
end

def set_was?(value)
  value && value !~ /^#{Lion::CSV.was_string}/
end

def set_prefixed_row_value(current_row, index_for_value, prefix)
  current_row[index_for_value] = "#{prefix}#{current_row[index_for_value]}"
end

def set_new_row_value(current_row, index_for_value, new_value)
  current_row[index_for_value] = new_value
end


def set_iso_codes(iso)
  iso = Lion.default_locale.to_s if iso.blank?
  iso_codes = iso.split(',')
  iso_codes = Lion.supported_locales.map(&:to_s) if iso == 'all'
  iso_codes
end

def write_markdown(iso, batch, screenshots_taken, rewrite = false)

  # * remember to make a new entry in index if a new batch....
  this_batch_filename = batch_filename(batch, iso)
  this_archive_filename = archive_filename(iso)
  if !File.exist?(File.join(Rails.root, 'doc', 'story', 'markdown', 'translations', this_archive_filename))
    make_directories('archive')
  end
  if !File.exist?(File.join(Rails.root, 'doc', 'story', 'markdown', 'translations', this_batch_filename)) || rewrite
    make_directories(zero_padded(batch))
    File.open(File.join(Rails.root, 'doc', 'story', 'markdown', 'translations', "translation_screenshots"), 'w') do |f|
      f << "# Translation Screenshots\n"
      Lion.supported_locales.map(&:to_s).each do |locale|
        f << "* [Archive, #{locale}](#{archive_filename(locale)}.html?format=raw)\n"
      end
      batch.to_i.downto(1) do |batch_num|
        f << "***\n"
        Lion.supported_locales.map(&:to_s).each do |locale|
          f << "* [Batch #{batch_num}, #{locale}](#{batch_filename(batch_num, locale)}.html?format=raw)\n"
        end
      end
    end
  end

  write_markdown_body(iso, Lion::Screenshots.all_screenshotted_keys(iso), this_archive_filename)
  write_markdown_body(iso, screenshots_taken, this_batch_filename)

end

def make_directories(dir_name)
  FileUtils.mkdir_p(File.join(Rails.root, 'doc', 'story', 'markdown', 'translations', dir_name))
  FileUtils.mkdir_p(File.join(Rails.root, 'doc', 'story', 'html', 'translations', dir_name))
end

def zero_padded(num)
  "%03d" % num
end

def batch_filename(batch_num, iso)
  "#{zero_padded(batch_num)}/#{iso}"
end

def archive_filename(iso)
  "archive/#{iso}"
end


def write_markdown_body(iso, keys, filename)
  puts "==== Updating markdown for #{filename}"
  FileUtils.touch(File.join(Rails.root, 'doc', 'story', 'html', 'translations', filename + '.html'))
  File.open(File.join(Rails.root, 'doc', 'story', 'markdown', 'translations', filename), 'w') do |f|
    f << "<a name=\"top\"></a>\n"
    f << "# Screenshots for #{iso} translations\n"
    keys.each do |key|
      f << " * [#{key.gsub('_', '&#95;')}](##{Lion.convert_to_filename(key)})\n"
    end
    f << "\n"
    keys.each do |key|
      f << "\n<h2 id=\"#{Lion.convert_to_filename(key)}\">#{key.gsub('_', '&#95;')}</h2>\n\n"
      f << "<a href=\"#top\">return to top</a>\n\n"
      filename = Lion.using_natural_keys ? Lion.convert_to_filename(key) : key
      f << " * ![see screenshot](#{Lion.path_to_screenshots_directory}/#{iso}/#{filename}.png?format=raw)\n"
    end
  end
end

def screenshots
  input_csv = Lion::CSV.input_csv
  output_csv = Lion::CSV.output_csv
  single_test = ENV['single_test']
  if ENV['skip_tests'] != 'true' && single_test.blank?
    puts "==== Copying input.csv to output.csv"
    FileUtils.cp(input_csv.path, output_csv.path)
    output_csv = Lion::CSV.output_csv
    puts "==== deleting unused keys in output.csv"
    output_csv.delete_unused_keys
  end

  ENV['RAILS_ENV'] = 'test'
  ENV['take_translation_screenshots'] = 'true'
  ENV['translation_screenshot_locale'] ||= Lion.default_locale.to_s

  iso_codes = set_iso_codes(ENV['translation_screenshot_locale'])

  if (iso_codes - Lion.supported_locales.map(&:to_s)).size > 0
    raise "invalid locale(s) specified #{iso_codes.inspect}"
  end

  test_output = ""

  iso_codes.each do |iso|

    if ENV['skip_tests'] != 'true'

      output_csv = reset_screenshot_values_in_output_csv(iso) if single_test.blank?

      # so the webserver will override the locale
      ENV['translation_screenshot_locale'] = iso

      if ENV['use_chosen_tests'] == 'true' || ENV['use_these_tests']
        input_csv = Lion::CSV.input_csv
        tests_ran = []
        if ENV['use_these_tests']
          tests_to_run = ENV['use_these_tests'].split(',')
        else
          tests_to_run = input_csv.select(:test_name => 'not_null').map{|current_row| current_row.test_name}.uniq
        end
        if !ENV['use_these_tests'] && ENV['run_tests_until_all_are_shot'] == 'true'
          tests_to_run += Lion::Screenshots.all_selenium_test_names
          tests_to_run.uniq
        end
        puts "=========== Here are the tests that are going to be run:"
        tests_to_run.each do |test_string|
          puts test_string
        end
        tests_to_run.each_with_index do |test_string, ii|
          full_test_command = "ruby " + Lion::Screenshots.full_test_path_from_test_name(test_string)
          puts "========= running #{full_test_command} (#{(ii + 1).to_s} of #{tests_to_run.size})"
          test_output += %x[#{full_test_command}]
          break if Lion::Query.all_screenshots_taken?(iso)
        end
      else
        if single_test
          only_shoot_this_key = ENV['only_shoot_this_key'] ? "only_shoot_this_key=#{ENV['only_shoot_this_key']}" : ''
          cmd = "#{only_shoot_this_key} ruby #{single_test}"
          puts "==== Running #{cmd}"
          test_output += %x[ruby #{single_test}]
        else
          Lion.selenium_suites.each do |suite|
            puts "==== Running Selenium Suite #{suite} for #{iso}"
            this_test_output = %x[./rake test:selenium:#{suite}]
            puts this_test_output
            if Lion::Screenshots.haz_error(this_test_output)
              test_output += this_test_output
            end
          end
        end
        # calling the rake task like below will abort the entire rake task if any selenium tests fail (a likely event)
        #Rake::Task["test:selenium:system"].invoke
      end
    end
  end

  final_output = []
  if !test_output.blank? && Lion::Screenshots.haz_error(test_output)
    final_output = test_output.split("\n")
  end

  if final_output.any?
    puts final_output
    puts "Looks like there were problems.. FIX IT!"
  elsif single_test.blank?
    puts "All Done. Look over output.csv, and if everything went smoothly, update the status column in output.csv and run:"
    puts "./rake lion:update_csvs_from_output_csv"
    puts "then you might want to consider running the following if you are done with all locales and are ready to update all the markdown:"
    puts "./rake lion:write_markdown_for_all_batches"
  end
  final_output
end

def arrays_equal(array1, array2, filepath)
  diff = ((array1 - array2) + (array2 - array1)).uniq.sort
  raise "updated #{filepath} has difference in keys #{diff}" if diff.size > 0
end


def convert_keys_to_symbols(options)
  raise "Please set using_natural_keys to false in lion.yml" if Lion.using_natural_keys
  all_csv_keys = Lion::CSV.all_csv_keys
  options[:keys_to_change].each_with_index do |key, i|
    puts "\n\n\n\n\n==================================================================================================================="
    puts "================= looking at \"#{key}\", which is #{i + 1} out of #{options[:keys_to_change].size} ====================="
    puts "==================================================================================================================="
    old_key = key
    new_key = Lion.convert_to_string_key(key)

    if options[:check_if_key_already_exists] && all_csv_keys.include?(new_key)
      puts "UH OH! The key we tried to create for you, \"#{new_key}\" seems to already exist.  Perhaps you are trying to add a new string to translate, but we already have it translated... but you might also be trying to add a string that has the same word(s) but means something completely different.  If you are indeed mistakenly using the same string, then use the key for that string in the code.  If it is indeed a different string, then make up your own key and put it in the appropriate csv"
    else
      change_key(options.merge(:old_key => old_key, :new_key => new_key))
    end
  end

  # run translations test
  ENV['show_translation_test_output'] = 'true'
  puts %x[ruby test/unit/translation_test.rb] if options[:run_test]
end

def change_key(options)
  old_key, new_key = options[:old_key], options[:new_key]
  if new_key == '_auto_assign_'
    new_key = Lion.convert_to_string_key(unharvested_translate(old_key))
    puts "New key is #{new_key}!"
  end
  Lion::CSV.file_from_key(old_key).update_row_values(old_key, :key => new_key)                           if options[:update_csvs]
  replace_key_in_all_files(:old_key => old_key, :new_key => new_key)                                     if options[:update_code]
  change_screenshot_name(:old_file_without_extension => old_key, :new_file_without_extension => new_key) if options[:update_screenshot_names]
  change_screenshot_name_in_story_markdown(old_key, new_key)                                             if options[:update_markdown]
end

def replace_key_in_all_files(options)
  Lion::Query.files_to_search_for_translation_strings.each do |file|
    if Lion::Query.found_string_in_file(file, options[:old_key], options[:new_key])
      puts "========== replaced \"#{options[:old_key]}\" in #{file} ========="
    end
  end
end

def change_screenshot_name(options)
  puts %x[cd #{Lion.screenshots_base_file_path}]
  Lion.supported_locales.map(&:to_s).each do |iso_code|
    Lion::Screenshots.screenshot_images(iso_code).each do |png_file|
      base_name = File.basename(png_file, ".png")
      if base_name == options[:old_file_without_extension]
        from_path = File.join(Lion.screenshots_base_file_path, 'translations', iso_code, "#{base_name}.png")
        to_path = File.join(Lion.screenshots_base_file_path, 'translations', iso_code, "#{options[:new_file_without_extension]}.png")
        if File.exists?(from_path)
          puts "moving from #{from_path} to #{to_path}"
          puts %x[svn mv #{from_path} #{to_path}]
        end
      end
    end
  end
end

def change_screenshot_name_in_story_markdown(old_key, new_key)
  Dir.glob("#{Rails.root}/doc/story/markdown/translations/*/*").each do |file|
    if Lion::Query.found_string_in_file(file, old_key, new_key)
      puts "========== replaced \"#{old_key}\" with \"#{new_key}\" in #{file} ========="
    end
  end
end

def keys_that_are_different_from_default_locale_translation
  translations_hash = Lion::Query.get_translations_hash[Lion.default_locale.to_sym]
  translation_keys_stringified = Lion::Translate.translation_keys_stringified
  keys_to_change = []
  keys_that_are_ok_to_be_different = Lion::Query.all_key_strings_that_can_be_different_from_their_default_locale_translation
  translations_hash.keys.each do |key|
    if (
        !keys_that_are_ok_to_be_different.include?(key.to_s.un_substitute_characters)) && # if the key is not in that special group
      (translations_hash[key] != key.to_s.un_substitute_characters) #&& # and english translation is different than its key
      # !translation_keys_stringified.include?(translations_hash[key] # and what we're about to change it to isn't already a key
      #)
      keys_to_change << [key.to_s.un_substitute_characters, translations_hash[key]]
    end
  end
  keys_to_change
end

def change_keys_that_are_different_from_default_locale_translation(keys_to_change = [])
  raise 'I do not know why you are running this, since you are using symbolic keys' if !Lion.using_natural_keys
  original_data = Lion::CSV.all_used_csv_data
  keys_to_change = keys_that_are_different_from_default_locale_translation if keys_to_change.empty?
  keys_to_change.each_with_index do |key_pair, i|
    puts "\n\n\n\n\n\n"
    puts "================= looking at #{key_pair.inspect}, which is #{i + 1} out of #{keys_to_change.size} ====================="
    old_key = key_pair.first
    new_key = key_pair.last
    # substitute in csv.. changing metadata appropriately as well
    (Lion.all_csv_files + Lion.io_csv_files).each do |filepath|
      csv = Lion::CSV.get(filepath)
      if csv.keys.include?(old_key)
        row_array_to_update = csv.detect(:key => old_key)
        row_array_to_update['key'] = new_key
        row_array_to_update['status'] = 'not_approved' if !Lion.io_csv_files.include?(filepath)
        row_array_to_update[Lion.default_locale.to_s] = new_key
        csv.delete_row(old_key, false)
        csv.add_or_update_row(row_array_to_update)
        puts "replaced in csv"
        break
      end
    end

    change_screenshot_name(:old_file_without_extension => old_key, :new_file_without_extension => Lion.convert_to_filename(new_key)) if !ENV['do_not_change_image_names']
    replace_key_in_all_files(:old_key => old_key, :new_key => new_key)

  end

  puts "comparing old and new translation hashes"
  new_data = Lion::CSV.all_used_csv_data
  missing_translations_in_original_data, missing_translations_in_new_data = compare_translations_between_data(original_data, new_data)
  missing_translations_in_new_data.each do |key, value|
    puts "UH OH!!! there were translations for \"#{key}\" which were changed.  Here they are:\n"
    value.each do |val|
      puts val
    end
    puts "\n\n"
  end

  write_markdown_for_all_batches if ENV['skip_sg_build'] != 'true'

  puts "Running translation_tests now"
  ENV['show_translation_test_output'] = 'true'
  puts %x[ruby test/unit/translation_test.rb]
end


def compare_translations_between_data(data1, data2)
  missing_translations_in_data1 = {}
  missing_translations_in_data2 = {}
  Lion.supported_locales.map(&:to_s).each do |iso|
    values1_for_iso = data1.map{|current_row| current_row.field(iso)}
    values2_for_iso = data2.map{|current_row| current_row.field(iso)}
    diff1_2, diff2_1 = differences_between_arrays(values1_for_iso, values2_for_iso)
    diff1_2.each do |value|
      missing_translations_in_data2 = compile_missing_translations_hash(missing_translations_in_data2, data1, value, iso)
    end
    diff2_1.each do |value|
      missing_translations_in_data1 = compile_missing_translations_hash(missing_translations_in_data1, data2, value, iso)
    end
  end
  [missing_translations_in_data1, missing_translations_in_data2]
end

def differences_between_arrays(array1, array2)
  diff1_2 = array1.uniq - array2.uniq
  diff2_1 = array2.uniq - array1.uniq
  [diff1_2, diff2_1]
end

def find_key_for_value(data, val, iso)
  data.detect{|current_row| current_row.field(iso) == val}.key
end

def compile_missing_translations_hash(memo, data, val, iso)
  key = find_key_for_value(data, val, iso)
  if memo[key]
    memo[key] << val
  else
    memo[key] = [val]
  end
  memo
end

def check_for_stat
  raise 'Please provide a valid status like stat=not_approved (unix barks if you use the word status)' if ENV['stat'].blank? || !Lion::CSV.statuses.include?(ENV['stat'])
end

def get_select_hash(hash = {})
  %w(where like like_i).each do |select_type|
    hash.merge(get_criteria_hash(select_type, hash))
  end
  hash
end

def get_criteria_hash(type, hash = {})
  Lion::CSV.column_headers.each do |col_head|
    hash[col_head] = ENV[col_head] if ENV[col_head]
    # since environment variables don't like to have dashes in them, they must be specified with _dash_ instead of the dash character.  this does the reverse substitution
    hash_key = col_head
    env_var = "#{type}_#{col_head}".gsub('-', '_dash_')
    hash_key = env_var if env_var =~ /^like/
    hash[hash_key] = ENV[env_var] if ENV[env_var]
  end
  hash
end

def update_csvs_from_output_data
  iso_codes = set_iso_codes(ENV['translation_screenshot_locale'])
  output = []
  iso_codes.each do |iso|
    puts "==== updating csvs with new screenshot data for #{iso}"
    output += Lion::Screenshots.update_csvs_with_output_data(iso)
  end
  puts '==== Running translation tests just to make sure we did not screw anything up'
  {:csv_update_output => output, :translation_test_output => %x[ruby test/unit/translation_test.rb].split("\n")}
end

def commit_after_screenshot_harvesting
  puts "svn adding and committing the screenshot files (takes at least 30 minutes)"
  puts %x[cd #{Lion.screenshots_base_file_path};svn st | grep "\?" | sed s/\?// | xargs svn add;svn ci -m "committing new and changed screenshots"]
  puts "adding any new markdown stuff"
  puts %x[svn st | grep "\?" | sed s/\?// | xargs svn add]
  puts "committing csv and markdown files"
  puts %x[svn revert #{Lion.csv_base_directory}/io/input.csv #{Lion.csv_base_directory}/io/output.csv]
  puts %x[svn ci -m "committing changes to source csvs and markdown after screenshot harvesting"]
end

def reset_screenshot_values_in_output_csv(iso)
  puts "==== resetting the screenshot values for #{iso} in output.csv"
  Lion::CSV.output_csv.edit_with_criteria({}, {"#{iso}_screenshot" => nil})
  Lion::CSV.output_csv
end

def with_clearing_output_csv(&block)
  with_copying_and_restoring_output_csv do
    puts "clearing output.csv so the system does not think it took the screenshot already... just in case the committed version says it has..."
    Lion::CSV.output_csv.clear
    yield
  end
end


def with_resetting_output_csv(&block)
  with_copying_and_restoring_output_csv do
    puts "resetting screenshot values in output.csv so the system does not think it took the screenshot already... just in case the committed version says it has..."
    reset_screenshot_values_in_output_csv(Lion.default_locale.to_s)
    yield
  end
end

def with_copying_and_restoring_output_csv(&block)
  begin
    FileUtils.cp(File.join(Lion.csv_base_directory, 'io', 'output.csv'), File.join('tmp', 'output.csv'))
    yield
  ensure
    puts "restoring output.csv to what it was"
    FileUtils.cp(File.join('tmp', 'output.csv'), File.join(Lion.csv_base_directory, 'io', 'output.csv'))
  end
end

def blame_people(prob_output, problems)
  if prob_output.any?
    problems += prob_output
    keys_not_shot = []
    prob_output.each do |prob|
      if prob =~ /We lost a screenshot for "(.+)"/
        puts "\n\n" + prob
        test_path, test_name = Lion::Screenshots.full_test_path_from_test_name(Lion::Screenshots.camelized_test_name_for_key($1)).split(" -n ")
        Lion::Screenshots.blame_test(test_name, test_path)
      elsif prob =~ /Screenshot not taken for "(.+)"/
        keys_not_shot << $1
      end
    end
    full_file_paths = Lion::Query.find_code_files_that_contain_keys(keys_not_shot)
    full_file_paths.each do |file_path, keys|
      local_file_path = file_path.gsub(Rails.root + "/", "")
      Lion::Screenshots.blame_file(local_file_path, keys)
    end
  end
end

def update_csvs_and_blame(problems = [])
  if problems.empty?
    output = update_csvs_from_output_data
    prob_output = output[:csv_update_output]
    blame_people(prob_output, problems)
    translation_test_output = output[:translation_test_output]
    if Lion::Screenshots.haz_error(translation_test_output) && ENV['ignore_failed_translation_tests'] != 'true'
      translation_test_output.each{|line| puts line}
      problems += translation_test_output
    end
  end
  problems
end

def merge_screenshotable_strings_into_input_csv
  puts 'merging all potentially screenshotable strings into input.csv'
  non_screenshotable_keys = Lion::Screenshots.all_non_screenshotable_keys_as_strings
  input_csv = Lion::CSV.input_csv
  input_csv.clear
  Lion.used_csv_files.each do |fp|
    puts '----' + fp
    Lion::CSV.get(fp).rows.each do |current_row|
      if !non_screenshotable_keys.include?(current_row.key)
        puts 'adding ' + current_row.key
        input_csv.add_or_update_row(current_row, false)
      end
    end
  end
  input_csv.save
end

def course_from_product_hash(product_hash)
  if product_hash["course"].is_a?(Hash)
    product_hash["course"]
  else
    product_hash["course"].last
  end
end

def default_product_languages_key(product_hash)
  "pl_#{Lion.underscorify(translation_for_product_in_locale(product_hash, :'en-US'), Lion.auto_generated_symbolic_key_length, true, true)}"
end

def product_languages_hash_entry(product_hash)
  course = course_from_product_hash(product_hash)
  rs_code = course["id"][3..5]
  rs_code = "#{course["id"][13..14]}-#{rs_code}" if course["id"][13..14] != "PE"
  hash = { :translation_key => default_product_languages_key(product_hash), :display_name => translation_for_product_in_locale(product_hash, :"en-US"), :iso_code => course["language"], :parature_code => nil }
  [rs_code, hash]
end

def translation_for_product_in_locale(product_hash, desired_locale)
  course = course_from_product_hash(product_hash)
  begin
    course["locale"].detect{|loc| loc["id"] == desired_locale.to_s}["string"].detect{|str| str["id"] =~ /language_name/}["text"]
  rescue => e
    nil
  end
end

def has_excel_export_capabilities?
  begin
    require 'spreadsheet'
  rescue MissingSourceFile
    return false
  end
  true
end
