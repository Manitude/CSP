class CsvGenerator

  def initialize(header = [], content_array = [])
    @header = header
    @content_array = content_array
  end

  def to_csv
    FasterCSV.generate(:col_sep => ",") do |csv|
      csv << @header unless @header.blank?
      @content_array.each do |content|
        csv << content
      end
    end
  end

end