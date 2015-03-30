# == Schema Information
#
# Table name: coach_contacts
#
# id :integer(4)      not null, primary key
# coach_id       int(11)               NULL                    
# coach_manager  varchar(255)          NULL    
# support_user   varchar(255)          NULL    
# created_at     datetime              NULL    
# updated_at     datetime  



class CoachContact < ActiveRecord::Base
belongs_to :coach, :foreign_key => 'coach_id'
end
