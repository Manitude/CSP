# == Schema Information
#
# Table name: resources
#
#  id           :integer(4)      not null, primary key
#  title        :string(255)     
#  description  :text(65535)     
#  size         :integer(4)      
#  content_type :string(255)     
#  filename     :string(255)     
#  db_file_id   :integer(4)      
#  created_at   :datetime        
#  updated_at   :datetime        
#

class Resource < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  has_attachment :storage => :db_file,
    :partition => false,
    :max_size => 10.megabytes,
    :path_prefix => '/public/resources',
    :content_type => ['application/pdf', 'application/msword', 'text/plain', :image, 'application/vnd.ms-excel']

  validates_presence_of :title, :description, :filename
  validates_format_of :title, :with => /^[a-z0-9A-Z_ (\&)-?\/,'%$"@#!~`@^{}\[\]*&]*?$/
  validate :attachment_attributes_valid?, :if => Proc.new {|f| f.filename.to_s != ""}

  def attachment_attributes_valid?
          [:size, :content_type].each do |attr_name|
            enum = attachment_options[attr_name]
            errors.add(:filename, "is invalid ") unless enum.nil? || enum.include?(send(attr_name))
          end
        end

  #to do away with teh complex folder structure
  def partitioned_path(*args)
    #["%04d" % attachment_path_id] + args
    args
  end
end
