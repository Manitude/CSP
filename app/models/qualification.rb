# == Schema Information
#
# Table name: qualifications
#
#  id          :integer(4)      not null, primary key
#  coach_id    :integer(4)      
#  language_id :integer(4)      
#  max_unit    :integer(4)      
#  created_at  :datetime        
#  updated_at  :datetime        
#

class Qualification < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  belongs_to :coach, :class_name => 'Coach', :foreign_key => 'coach_id'
  belongs_to :manager, :class_name => 'CoachManager', :foreign_key => 'coach_id'
  belongs_to :language
  belongs_to :dialect
  delegate :identifier, :to => :language
  validates_foreign_key_presence :language
  validate :must_be_a_valid_max_unit
  validate :must_be_a_unique_language
  validate :must_have_correct_max_unit

  def max_level
     Level.find_by_number((max_unit / UNITS_PER_LEVEL.to_f).ceil)
  end

  def units_label
    return '0' if max_unit && max_unit.zero?
    return "N/A" if self.language.is_lotus? || self.language.is_aria? || self.language.is_tmm?
    return (1..max_unit).to_a.join(', ') if max_unit < 3
    "1..#{max_unit}"
  end

  def update_max_unit(new_max_unit)
    if update_attributes(:max_unit => new_max_unit)
      res = ExternalHandler::HandleSession.update_wildcard_units_for_eschool_sessions(TotaleLanguage.first, {:qualification => self})
      if res
        res = REXML::Document.new res.read_body
        errors.add(:base, res.elements.to_a( "//message" ).first.text) unless res.elements.to_a( "//status" ).first.text == 'OK'
      else
        errors.add(:base, "There is some problem with eschool. Please try after sometime.")
      end
    end
  end
  
  def levels
    Level.all_sorted.collect { |lvl| lvl.number if lvl.number <= max_level.number }.compact
  end

  def levels_label
    levels.join(', ')
  end

  def language_label
    self.language.display_name
  end

  def label
    language_label + ' - units : ' + units_label
  end

  private

  def must_be_a_unique_language
    condition = "max_unit IS#{coach ? " NOT " : " "}NULL and id != ? and coach_id = ? and language_id = ?"
    qualifications = Qualification.where([condition, id.to_i, coach_id, language_id])
    errors.add(:language, 'has already been taken.') unless qualifications.blank?
  end

  def must_be_a_valid_max_unit
    return true if language.nil? || manager
    unless UNITS_COLLECTION.dup.unshift(0).include?(max_unit) && max_unit <= language.max_unit
      errors.add(:base, "The maximum unit you selected exceeds the maximum unit offered for #{language.display_name}. Please select the correct maximum unit.")
    end
  end

  def must_have_correct_max_unit
    # For coaches, there must be a max_unit.
    errors.add(:max_unit, "must be greater than zero for coach.") if coach && max_unit.to_i.zero?
    # For managers, max_unit must be NULL
    errors.add(:max_unit, "must be blank for manager.") if manager && !max_unit.nil?
  end

end
