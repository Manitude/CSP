# == Schema Information
#
# Table name: roles
#
#  id   :integer(4)      not null, primary key
#  name :string(255)     not null
#

# == Schema Information
#
# Table name: roles
#
#  id   :integer(4)      not null, primary key
#  name :string(255)     not null
#

class Role < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  has_many :roles_tasks
  has_many :tasks,:through => :roles_tasks

end
