class Lion
  module Screenshots
    class << self
      
      def non_screenshotable_file_path; File.join(Rails.root, 'doc', 'translations', 'non_screenshotable.yml'); end
      def screenshots_taken(iso); Lion::CSV.output_csv.select({"#{iso}_screenshot" => 'yes'}).map{|row| row.key}.sort; end
      
      def all_non_screenshotable_keys_as_strings
        Lion::CSV.all_used_csv_data.select{|row| row.field("screenshotable") == 'no'}.map{|row| row.key}.sort
      end
      
      def all_screenshotted_keys(iso)
        Lion::CSV.all_used_csv_data.select{|row| row.field("#{iso}_screenshot") == 'yes' || row.field("#{iso}_screenshot") == "#{Lion::CSV.was_string}yes"}.map{|row| row.key}.sort
      end
      
      def all_screenshotable_keys_as_strings; translation_keys_stringified - all_non_screenshotable_keys_as_strings; end
      
      def update_csvs_with_output_data(iso)
        output = []
        Lion::CSV.output_csv.rows.each do |row|
          key = row.key
          csv = Lion::CSV.get(Lion::Query.find_file_for_key(key)) #FIXME - redundant function.. same exists in csv.rb
          update_hash = {"status" => row.status}
          if row.field("#{iso}_screenshot") == 'yes'
            puts "==== screenshot=YES for \"#{key}\""
            update_hash.merge!({"#{iso}_screenshot" => 'yes', 'test_name' => row.test_name, 'screenshotable' => 'yes'})
          elsif row.field("screenshotable") == 'no'
            puts "==== screenshot=NO (but it's ok) for \"#{key}\""
            update_hash.merge!({"screenshotable" => 'no', 'context' => row.context})
          elsif (row.field("screenshotable") == 'awaiting' || row.field("screenshotable").blank?) && row.field("#{iso}_screenshot") != "yes"
            puts "==== UH OH Screenshot not taken for \"#{key}\" when it should have"
            output << "Screenshot not taken for \"#{key}\""
            update_hash.merge!({"#{iso}_screenshot" => "no"})
          elsif csv.row_for_key(key).field("#{iso}_screenshot") == 'yes'
            puts "==== UH OH (not ok): #{Lion::CSV.was_string}yes for \"#{key}\""
            output << "We lost a screenshot for \"#{key}\""
            update_hash.merge!({"#{iso}_screenshot" => "#{Lion::CSV.was_string}yes"})
          end
          csv.update_row_values(key, update_hash)
        end
        output
      end
      
      def full_test_path_from_test_name(test_name_original, raise_on_unfound = true)
        test_path = ''
        test_name = ''
        #SingleSession::ProfileTest: test_stamps_page
        if test_name_original =~ /^\w+::\w+: \w+$/
          test_path = test_name_original.split(': ').first.split('::').map(&:underscore).join('/') + '.rb'
          test_name = test_name_original.split(': ').second
        #test_activation_and_complete_profile_scenario_paid_true_complete_false_active_true(SingleSession::RegistrationTest):
        elsif test_name_original =~ /^(\w+)\((\w+::\w+)\):?$/
          test_name = $1
          test_path = $2.split('::').map(&:underscore).join('/') + '.rb'
        #test/selenium/single_session/your_test_file.rb -n test_my_stuff
        elsif test_name_original =~ /rb \-n \w+$/
          return test_name_original
        elsif raise_on_unfound
          raise "This test '#{test_name_original}' did not match any pattern i was expecting"
        else
          return
        end
        "test/selenium/#{test_path} -n #{test_name}"
      end
      
      def screenshot_images(iso = Lion.default_locale)
        Dir.glob(File.join(Lion.screenshots_base_file_path, 'translations', iso, '*.png')).map{ |full_path| full_path.split('/').last }
      end

      # this looks into the filesystem for screenshot images that aren't there.  This might give false positives because
      # the image that is there might be out of date... so it depends on your definition of "non_shot"
      def non_shot_keys(iso = Lion.default_locale)
        list_of_keys = all_screenshotable_keys_as_strings
        screenshot_image_keys = screenshot_images.map{|image_file| image_file.split('.').first }
        screenshot_image_keys.each do |sik|
          list_of_keys.each do |lok|
            if sik == lok
              list_of_keys.delete(lok)
            end
          end
        end
        list_of_keys
      end
      
      def haz_error(output_text)
        if (output_text.split("\n").last =~ /0 failures/ && output_text.split("\n").last =~ /0 errors/)
          return false
        else
          return true
        end
      end

      def blame_test(test_name, test_path)
        blame_hash = {}
        test_body = []
        capture_test_body = false
        %x[svn blame #{test_path}].split("\n").each do |blame_line|
          if blame_line =~ /def #{test_name}/
            capture_test_body = true
          else
            capture_test_body = false if capture_test_body && (blame_line =~ /def test_/)
          end
          if capture_test_body
            test_body << blame_line
            if blame_line =~ /^ *(\d+) +(\w+) /
              blame_hash[$1] = $2
            end
          end
        end
        blame_array = []
        blame_hash.keys.sort.reverse.each do |revision|
          blame_array << blame_hash[revision] if !blame_array.include?(blame_hash[revision])
        end
        puts "#{test_path} is no longer harvesting that key. The culprit is:"
        puts blame_array.join(",")
        puts "The proof:"
        test_body.map{|line| puts line}
      end

      def blame_file(file_path, strings_to_match)
        blame_hash = {}
        %x[svn blame #{file_path}].split("\n").each do |blame_line|
          strings_to_match.each do |stm|
            if blame_line =~ /#{stm}/
              if blame_line =~ /^ *\d+ +(\w+) /
                name = $1
                blame_hash[name] = [] if blame_hash[name].nil?
                blame_hash[name] << stm
              end
            end
          end
        end
        puts "For #{file_path}:"
        blame_hash.each do |name, keys|
          puts "#{name} has not shot #{keys.join(",")}"
        end
      end
      
      def camelized_test_name_for_key(key)
        Lion::CSV.file_from_key(key).row_for_key(key).test_name
      end
      
      def all_selenium_test_names
        all_test_names = []
        Lion.selenium_suites.each do |suite|
          output = %x[grep -r "def test_" test/selenium/#{suite} | fgrep -v .svn]
          output.split("\n").each do |line|
            # line is something like "test/selenium/multi_session/arena_test.rb:  def test_viewing_invitations"
            if line.split('def ').first =~ /(\w*)\.rb/
              # should output something like "MultiSession::ArenaTest: test_viewing_invitations"
              all_test_names << "#{suite.camelize}::#{$1.camelize}: #{line.split('def ').second}"
            end
          end
        end
        all_test_names
      end
      
    end
  end
end
