class Hash
  def removed_if_contains(session_detail)
    removed = false
    self.each do |village_id, crud_hash| # for all villages
      crud_hash.each do |crud, session_array| # for each of create, edit, delete and cancel
        session_array.each do |sess|
          if session_detail['changed_now'] && sess["coach_id"] == session_detail["coach_id"] && sess["start_time"] == session_detail["start_time"]
            removed = true
            self[village_id][crud].delete(sess)
          end
        end
      end
    end
    removed
  end
end
