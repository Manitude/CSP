# encoding: utf-8

class Lion
  class CSV

    attr_reader :csv_table
    attr_reader :headers
    attr_reader :path
    attr_reader :options
    
    # FIXME: replace all Lion::CSV.new calls with Lion::CSV.get calls...
    def initialize(path, options = self.class.default_options)
      raise "csv does not exist at the path \"#{path}\"" if !File.exist?(path)
      @options = options
      @path = path
      if path.match(/\.xls$/)
        @csv_table = get_csv_from_xls(path, options)
      else
        @csv_table = FasterCSV.read(path, options)
      end
      @headers = @csv_table.headers
      if @headers.empty?
        @headers = Lion::CSV.column_headers
      end
    end

    def row_for_key(key); detect(:key => key); end
    def rows; @csv_table.map{|row|row if row}; end
    def detect(key_values); select(key_values).first; end
    def keys; rows.map{|row|row.key}; end
    def sort; save; end
    def clear; @csv_table.delete_if{|row| true}; save; end
    def rails_translation?; !@path.match(/#{File.join('translations','rails')}/).nil?; end
    
    def add_or_update_row(row, save_it = true)
      row = Lion::CSV.sanitize_row(self, row)
      delete_row(row.key, false)
      @csv_table << row
      save if save_it
    end
    
    def update_row_values(key, col_values)
      row = row_for_key(key)
      raise "no row found for key \"#{key}\" in #{self.path}" if row.nil?
      
      col_values.each do |col, val|
        row[row.index(col.to_s)] = val
      end
      add_or_update_row(row)
    end

    def merge_row(new_row_data, columns_to_merge = Lion::CSV.columns_safe_to_merge, overwrite_with_blank_values = false)
      new_row_data = Lion::CSV.sanitize_row(self, new_row_data)
      row = row_for_key(new_row_data.key)
      raise "row for key \"#{new_row_data.key}\" in #{path} did not exist" if !row
      columns_to_merge.each do |col|
        write_it = false
        if new_row_data.field(col).blank?
          if overwrite_with_blank_values
            write_it = true
          end
        else
          write_it = true
        end
        if write_it
          original_value = row.field(col)
          new_value = new_row_data.field(col)
          if new_value != original_value
            puts "----- \nKey \"#{new_row_data.key}\""
            if Lion.supported_locales.map(&:to_s).include?(col)  
              puts "FOR TRANSLATORS: setting english string \"#{new_row_data.field('en-US')}\" in #{col} from \"#{original_value}\" to \"#{new_value}\""
            else
              puts "~~~~FOR TRANSLATION MANAGER: setting #{col} from \"#{original_value}\" to \"#{new_value}\""
            end
            row[row.index(col)] = new_value
          end
        end
      end
      add_or_update_row(row)
    end

    def delete_row(key_or_keys, save_it = true)
      these_keys = key_or_keys.is_a?(Array) ? key_or_keys : [key_or_keys]
      these_keys.each do |key|
        @csv_table.delete_if{|row| row.key == key}
      end
      save if save_it
    end
    
    def move_key_to_unused(key)
      row = row_for_key(key)
      raise "could not find row for key \"#{key}\"" if !row
      Lion::CSV.get_from_dir_and_file('unused', 'strings.csv').add_or_update_row(row.make_unused!)
      delete_row(key)
    end
    
    def delete_unused_keys(move_to_unused = false)
      unused_keys = Lion::Query.find_unused_keys
      keys.each do |key|
        if unused_keys.include?(key)
          if move_to_unused
            move_key_to_unused(key)
          else
            row = row_for_key(key)
            raise "could not find row for key \"#{key}\"" if !row
            delete_row(key)
          end
        end
      end
    end
    
    def edit_with_criteria(select_hash, edit_hash)
      rows_to_edit = select(select_hash)
      rows_to_edit.each do |row|
        edit_hash.each do |col, val|
          row[row.index(col)] = val
        end
        add_or_update_row(row, false)
      end
      save
    end
    
    def select(key_values = {})
      joined_by_or = true if ENV['join_type'] == 'or'
      rows.select do |row|
        matched_every_select_key = true
        matched_any_select_key = false
        key_values.each do |select_key, value|
          if select_key == 'translated'
            case value
            when 'none'
              matched_every_select_key, matched_any_select_key = set_matched_bools(!row.has_any_translations?, matched_every_select_key, matched_any_select_key)
            when 'all'
              matched_every_select_key, matched_any_select_key = set_matched_bools(row.has_all_translations?, matched_every_select_key, matched_any_select_key)
            when 'partial'
              matched_every_select_key, matched_any_select_key = set_matched_bools(!(row.has_all_translations? || !row.has_any_translations?), matched_every_select_key, matched_any_select_key)
            when 'none_or_partial'
              matched_every_select_key, matched_any_select_key = set_matched_bools(!row.has_all_translations?, matched_every_select_key, matched_any_select_key)
            end
          elsif select_key =~ /like(_i)?_(\w+)/
            regex = $1 ? /#{value}/i : /#{value}/
            matched_every_select_key, matched_any_select_key = set_matched_bools(!(row.field(klass.restore_dash($2)) !~ regex), matched_every_select_key, matched_any_select_key)
          else
            value.to_s.split('__or__').each do |val|
              matched = (val == 'null') ? row.field(select_key.to_s).blank? : false
              matched = (!row.field(select_key.to_s).blank? && (val == 'not_null')) || (row.field(select_key.to_s) == val.to_s) if !matched
              matched_every_select_key, matched_any_select_key = set_matched_bools(matched, matched_every_select_key, matched_any_select_key)
            end
          end
        end
        joined_by_or ? matched_any_select_key : matched_every_select_key
      end
    end

    def set_matched_bools(matched, matched_every_select_key, matched_any_select_key)
      if !matched
        matched_every_select_key = false
      else
        matched_any_select_key = true
      end
      [matched_every_select_key, matched_any_select_key]
    end
    
    def save
      FasterCSV.open(@path, "w", self.class.default_options) do |out|
        out << @headers
        (rows.size > 1 ? @csv_table.sort_by{|row| row.field('key') } : rows).each do |row|
          out << row.fields if row.any?
        end
      end
    end
    
    def validate(options)
      check_that_keys_are_in_our_system = options[:check_that_keys_are_in_our_system]
      expected_headers = Lion::CSV.column_headers
      actual_headers = self.headers
      if (expected_headers.map(&:to_s) & actual_headers) != expected_headers
        raise %Q[column headings are invalid.  they should be "#{expected_headers.join(',')}" but were "#{actual_headers.join(',')}" (differences were #{(expected_headers - actual_headers).inspect}) in file #{@path}]
      end
      #The caller can avoid having to build this Set many times
      translations_hash_keys = options[:hash_keys] || Set.new(Lion::Translate.translation_keys_stringified)
      translations_hash = Lion::Query.get_translations_hash(true)[Lion.default_locale.to_sym] if rails_translation?
      unique_keys = []
      errors = []
      keys_checked = translations_hash_keys.dup

      self.rows.each do |row|
        key = row.key
        if rails_translation?
          hierarchy = key.split('.').collect{|val| val.to_sym}
          current_hash = translations_hash
          hierarchy.each do |current_key|
            errors << "#{self.path} has a key that is not in our system: \"#{key}\"" if !current_hash.has_key?(current_key) && check_that_keys_are_in_our_system
            current_hash = current_hash[current_key]
          end
        else
          errors << "#{self.path} has a key that is not in our system: \"#{key}\"" if !translations_hash_keys.include?(key) && check_that_keys_are_in_our_system
        end
        errors << "#{self.path} has a repeated key: \"#{key}\"" if unique_keys.include?(key)
        keys_checked = keys_checked - [key]
        unique_keys << key
      end
      self.rows.each do |row|
        key = row.key
        this_status = row.status
        # status columns should be valid
        if !Lion::CSV.valid_status_values.include?(this_status)
          errors << "Invalid status:\"#{this_status}\" for key:\"#{key}\".  It should be one of the following: #{Lion::CSV.statuses.inspect}"
        else
          # status should be valid
          if !self.path =~ /\/unused\// && !translations_hash_keys.include?(key)
            errors << "This key:\"#{key}\" should live in the \"unused\" directory, because it is not used... directory=#{directory} and filepath=#{filepath}"
          end
          if self.path =~ /\/unused\//
            rows.each do |row|
              if !row.test_name.blank?
                errors << "This unused key: \"#{row.key}\" should not have a test_name associated with it.  This should have been deleted when the string was retired."
              end
            end
          end
          if this_status != 'not_approved' && row.batch.blank?
            errors << "This key:\"#{key}\" should belong to a batch"
          end
          # if no translations (none but default_locale), it should have one of the following statuses: blank, not_approved, being_approved, approved, or being_translated
          if !row.has_any_translations? && !row.status.blank? && row.has_status_of_at_least?('translated')
            errors << "This key:\"#{key}\" has no translations, but has a status of \"#{row.status}\", which in my opinion, is inappropriate"
          end
        end

        # if there is a test_name and screenshotable is no...
        if !row.test_name.blank? && (row.screenshotable == 'no' || row.screenshotable.blank?)
          errors << "Something is fishy... there was a screenshot test_name, but it is supposedly not screenshotable.. this is regarding key:\"#{key}\" with test_name of \"#{row.test_name}\""
        end

        # if not screenshotable, verify that a comment exists
        if row.screenshotable == 'no' && row.context.blank?
          errors << "There was no context for non-screenshotable key \"#{key}\""
        end
        
        if row.screenshotable.blank? && row.has_status_of_at_least?('approved')
          errors << "Row with key \"#{row.key}\" does not have a screenshotable value, yet it is far enough in the process that you should have decided if it is screenshotable or not.  Say yes or no or awaiting for this value"
        end

      end
      if options[:return_errors]
        return errors
      else
        if errors.any?
          puts "UH OH! There were errors!"
          errors.map{|error| puts error}
        end
        return !errors.any?
      end
    end
    
    
    class << self
      
      def restore_dash(s)
        s.gsub('_dash_', '-')
      end
      
      # returns a valid FasterCSV::Row even if you pass it an array or hash
      def sanitize_row(csv, row)
        if row.is_a?(Array)
          row = FasterCSV::Row.new(csv.headers, row)
        elsif row.is_a?(Hash)
          row_array = []
          Lion::CSV.column_headers.each do |col_head|
            row_array << row[col_head] || ''
          end
          row = FasterCSV::Row.new(Lion::CSV.column_headers, row_array)
        else
          raise 'This method requires either an array, hash or a FasterCSV::Row' if !row.is_a?(FasterCSV::Row)
        end
        row
      end
      
      def get_data_from_files(files); files.inject([]){|memo, filepath| memo += Lion::CSV.get(filepath).rows; memo}; end
      def all_used_csv_data; get_data_from_files(Lion.used_csv_files); end
      def all_csv_data; get_data_from_files(Lion.all_csv_files); end
      def all_used_csv_keys; all_used_csv_data.map{|row| row.key}; end
      def all_csv_keys; all_csv_data.map{|row| row.key}; end
      def get_from_dir_and_file(dir, file); Lion::CSV.new(filepath_for(dir, file)); end
      def get_from_relative_path(relative_path); Lion::CSV.new(File.join(Rails.root, Lion.csv_base_directory, relative_path)); end
      def get(filepath, save_file_for_future_use=false)
        if save_file_for_future_use
          @@previously_opened_file ||= {}
          return @@previously_opened_file[filepath] if @@previously_opened_file[filepath]
        end
        csv = Lion::CSV.new(filepath)
        if save_file_for_future_use
          @@previously_opened_file[filepath] = csv
        end
        csv
      end
      def parse(string)
        filepath = "/tmp/tmp_csv_" + string.hash.abs.to_s
        tmp_file = File.new(filepath, 'w')
        tmp_file.puts string
        tmp_file.close
        get(filepath)
      end
      def file_from_key(key); Lion.all_csv_files.inject([]){|memo, file| csv = get(file, true); memo << csv if csv.row_for_key(key); memo }.first; end
      
      def make_empty_csv(dir, filename, base_path = Lion.csv_base_directory)
        FileUtils.mkdir_p(File.join(base_path, dir))
        FileUtils.touch(File.join(base_path, dir, filename))
        Lion::CSV.new(File.join(base_path, dir, filename)).save
      end
      
      def empty_row(key, default_translation)
        row_data = []
        Lion::CSV.column_headers.each do |col_head|
          case col_head
          when 'key'
            row_data << key
          when 'status'
            row_data << 'not_approved'
          when Lion.default_locale.to_s
            row_data << default_translation
          else
            row_data << nil
          end
        end
        row_data
      end
      
      def default_options; {:encoding => "`Uâ€™", :headers => true, :force_quotes => true, :skip_blanks => true}; end
      def was_string;             'WAS: ';                                                            end
      def archived_string;        'ARCHIVED: ';                                                       end
      def statuses; %w(not_approved being_approved approved being_translated translated being_verified verified); end
      def status_rankings; ii = 0; h = {}; statuses.each{|s| h[s] = (ii += 1)}; h;     end
      def status_ranking(comparison_status); status_rankings[comparison_status];     end
      def status_after(stat); status_rankings.invert[status_ranking(stat) + 1] || stat; end
      # FIXME: these statuses could be in configs
      def valid_status_values; statuses + ['']; end
      
      # csv column headings
      def locales_in_sort_order_with_default_locale_first; [Lion.default_locale.to_s] + (Lion.supported_locales - [Lion.default_locale.to_sym]).map(&:to_s).sort; end
      def column_headers; %w(key context status comment) + locales_in_sort_order_with_default_locale_first + %w(screenshotable batch test_name) + locales_in_sort_order_with_default_locale_first.map{ |iso| "#{iso}_screenshot" }; end
      def columns_inappropriate_for_unused; %w(screenshotable test_name); end

      # ----------------------------------------- #
      # ------- CSV file loaders/writers -------- #
      # ----------------------------------------- #
      def csv_files_for(directory); Dir.glob("#{Rails.root}/#{Lion.csv_base_directory}/#{directory}/*.csv"); end
      def filepath_for(directory, file); File.join(Rails.root, Lion.csv_base_directory, directory, file); end
      def input_csv; Lion::CSV.get_from_dir_and_file('io', 'input.csv'); end
      def input_csv_keys; input_csv.keys; end
      def output_csv; Lion::CSV.get_from_dir_and_file('io', 'output.csv'); end
      def output_csv_keys; output_csv.keys; end
      def update_output(key, edit_hash); output_csv.update_row_values(key, edit_hash); end
      def columns_safe_to_merge; %w(key context status comment screenshotable batch) + Lion.supported_locales.map(&:to_s); end
      def csv_keys_for(dir); csv_files_for(dir).inject([]){|memo, file| memo += get(file).keys; memo}.uniq.sort; end
      def used_csv_keys; Lion.used_translations_directories.inject([]){|memo, dir| memo + csv_keys_for(dir) }.sort; end
   
    end
    
    private

    def get_csv_from_xls(path, options={})
      begin
        spreadsheet = Spreadsheet.open(path)
        worksheet = spreadsheet.worksheets.first
      rescue
        raise MalformedRequestError, "Dude, something's up with this XLS file"
      end
      starting_row, ending_row, starting_column, ending_column = worksheet.dimensions
      #These give the value for the first unused row/column, so we want to back off by 1
      ending_row -= 1
      ending_column -= 1
      first_row = worksheet.row(starting_row)

      headers = []
      iterate_over_columns(first_row, starting_column, ending_column) do |header|
        headers << header.to_s.strip
      end
      starting_row += 1

      csv_string = FasterCSV.generate do |csv|
        csv << headers
        worksheet.each(starting_row) do |row|
          columns = []
          iterate_over_columns(row, starting_column, ending_column) do |column|
            columns << (column.is_a?(Float) ? column.to_i.to_s : column.to_s)
          end
          #Skip if the row is completely empty
          next if columns.all?{|col| col.blank?}
          csv << columns
        end
      end
      FasterCSV.parse(csv_string, options)
    end

    def iterate_over_columns(row, starting_column, ending_column)
      #This is necessary because a given row *could* have a different number of columns
      #than another row, which would throw an error at a later point in time. So, we use the global
      #column count/range to ensure that each row has the same number of columns
      starting_column.upto(ending_column) do |col_index|
        yield(row[col_index])
      end
    end
    
  end
end
