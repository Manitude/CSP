# == Schema Information
#
# Table name: ms_draft_data
#
#  id              :integer(4)      not null, primary key
#  data            :binary(16777215 
#  start_of_week   :datetime        
#  lang_identifier :string(255)     
#  created_at      :datetime        
#  updated_at      :datetime        
#  last_changed_by :integer(4)      
#

class MsDraftData < ActiveRecord::Base
  audit_logged
  set_table_name 'ms_draft_data'

  # Open up the data attribute,
  # add the new sessions which were just added,
  # overwrite the ones for the same slot
  def update_data_attribute(new_data)
    new_hash = {}
    villages = Community::Village.all.collect(&:id)
    villages.each do |village|
      new_hash[village] = {
        :create => [],
        :delete => [],
        :cancel => [],
        :edit   => []
      }
    end
    new_hash[0] = { :create => [], :delete => [], :cancel => [], :edit => [] }# village 'none'
    count = 0
    old_data = self.data
    last_updated = self.data && self.updated_at.to_s(:long)
    data = self.data ? Marshal.load(self.data) : new_hash
    new_data.each_value do |crud_hash|
      crud_hash.each do |crud,session_array|
        session_array.each do |session_detail|
          count +=1 if old_data && data.removed_if_contains(session_detail)
          changed_now = session_detail["changed_now"]
          session_detail.delete("changed_now") #We don't want this temporary attribute to enter the db
          data[session_detail["external_village_id"].to_i][crud].push(session_detail) if changed_now
        end
      end
    end


    # Remove from canceled if uncanceled
    data.each_value do |crud_hash|
      crud_hash.each do |crud, session_array|
        if crud == :cancel && session_array.any?
          village_id = session_array.first["external_village_id"].to_i
          data[village_id][crud] = new_data[village_id][crud]
        end
      end
    end

    self.update_attribute(:data, Marshal.dump(data))
    {:sessions_overwritten => count, :last_updated => last_updated}
  end

end
