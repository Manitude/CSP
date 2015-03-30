class LionController < ApplicationController

  def index
    @allow_excel_export = has_excel_export_capabilities?
  end

  def export
    if request.post? && params.has_key?('keys') && params['keys'].is_a?(Hash)
      next_batch_number = Lion::Query.next_batch_number
      assign_batch_number = params['assign_batch_number']
      #Use the output file as an example - makes it easy to get the right order of the columns, etc.
      output_csv = Lion::CSV.get_from_dir_and_file('io', 'output.csv')
      desired_keys = Set.new(params['keys'].keys)
      Lion::CSV.all_csv_data.select{|data| desired_keys.include?(data['key'])}.each do |current_row|
        current_row['batch'] = next_batch_number if assign_batch_number
        output_csv.add_or_update_row(current_row, false)
      end
      output_file_base = "output"
      if assign_batch_number
        output_file_base << "_#{next_batch_number}"
      end

      if params.has_key?('xls_export') && has_excel_export_capabilities?
        book = Spreadsheet::Workbook.new
        sheet = book.create_worksheet
        sheet.name = "Translations"
        output_csv.csv_table.to_a.each_with_index do |row, index|
          sheet.row(index).concat(row)
        end

        workbook = StringIO.new
        book.write(workbook)
        workbook.rewind
        send_data(workbook.read, :disposition=>'attachment', :type=>"application/vnd.ms-excel", :filename=>"#{output_file_base}.xls")
      else
        send_data(output_csv.csv_table.to_csv, :disposition=>'attachment', :type=>'text/csv', :filename=>"#{output_file_base}.csv")
      end
    else
      flash[:error] = "You must specify a key to export."
      redirect_to lion_index_path
    end
  end

  def show
    @entry = nil
    if params.has_key?('key')
      filepath = Lion::Query.find_file_for_key(params[:key])
      if filepath.present?
        @entry = Lion::CSV.get(filepath).rows.detect{|row| row.key == params[:key]}
      else
        flash[:error] = "Key #{params[:key]} was not found in any translation file"
      end
    else
      flash[:error] = "Missing key parameter"
    end
  end


  private
  def has_excel_export_capabilities?
    begin
      require 'spreadsheet'
    rescue MissingSourceFile
      return false
    end
    true
  end
end
