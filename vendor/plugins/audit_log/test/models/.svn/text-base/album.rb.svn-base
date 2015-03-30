class Album < ActiveRecord::Base
  belongs_to :artist
  attr_accessor :predefined_non_ar_method
  audit_logged :also_log => [:non_ar_method, :predefined_non_ar_method]

  def non_ar_method
    @non_ar_method
  end

  def non_ar_method=(val)
    @non_ar_method = val
  end
end

class PlatinumAlbum < Album
end

class NonTrackableAlbum < ActiveRecord::Base
end