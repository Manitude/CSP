# == Schema Information
#
# Table name: roles_tasks
#
#  id      :integer(4)      not null, primary key
#  role_id :integer(4)      not null
#  task_id :integer(4)      not null
#  read    :boolean(1)      
#  write   :boolean(1)      
#

# == Schema Information
#
# Table name: roles_tasks
#
#  id      :integer(4)      not null, primary key
#  role_id :integer(4)      not null
#  task_id :integer(4)      not null
#  read    :boolean(1)
#  write   :boolean(1)
#

class RolesTask < ActiveRecord::Base
  audit_logged
  belongs_to :role
  belongs_to :task
end
