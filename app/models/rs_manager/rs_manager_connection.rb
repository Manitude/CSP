module RsManager
  class RsManagerConnection < ActiveRecord::Base
    self.abstract_class = true
    establish_connection "rs_manager_#{Rails.env}"
  end
end
RsManager::RsManagerConnection.store_full_sti_class = false