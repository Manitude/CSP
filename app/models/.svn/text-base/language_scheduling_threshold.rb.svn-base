# == Schema Information
#
# Table name: language_scheduling_threshold
#
# id                               :integer(11)
# language_id                      :integer(11)
# max_assignment                   :integer(11)
# max_grab                         :integer(11)
# hours_prior_to_sesssion_override :integer(11)
# created_at                       :datetime
# updated_at                       :datetime
#
class LanguageSchedulingThreshold < ActiveRecord::Base
  validates_uniqueness_of :language_id
  validates_numericality_of :max_assignment,:less_than_or_equal_to => 50 , :greater_than_or_equal_to => 0 ,:allow_nil => false
  validates_numericality_of :max_grab,:less_than_or_equal_to => 30 , :greater_than_or_equal_to => 0 ,:allow_nil => false
  validates_numericality_of :hours_prior_to_sesssion_override,:less_than_or_equal_to => 12 , :greater_than_or_equal_to => 0 ,:allow_nil => false
  has_one    :language, :class_name => 'Language', :foreign_key => 'language_id'
  self.include_root_in_json = false

  def self.get_hours_prior_to_sesssion_override(language_id)
    lang_threshold = LanguageSchedulingThreshold.find_by_language_id(language_id)
    lang_threshold.hours_prior_to_sesssion_override if lang_threshold
  end

end
