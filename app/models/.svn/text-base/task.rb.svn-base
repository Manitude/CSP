# == Schema Information
#
# Table name: tasks
#
#  id      :integer(4)      not null, primary key
#  name    :string(255)     not null
#  section :string(255)     
#  code    :string(255)     
#

# == Schema Information
#
# Table name: tasks
#
#  id      :integer(4)      not null, primary key
#  name    :string(255)     not null
#  section :string(255)
#

class Task < ActiveRecord::Base
  audit_logged
  has_many :roles_tasks
  has_many :roles,:through => :roles_tasks
end
