# == Schema Information
#
# Table name: levels
#
#  id         :integer(4)      not null, primary key
#  number     :integer(4)      not null
#  created_at :datetime        
#  updated_at :datetime        
#

class Level < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger 
  validates_uniqueness_of :number

  class << self
    def max
      Level.order('number desc').first
    end

    def [](number)
      @all[number]
    end

    def all_sorted
      order(&:number)
    end

    def options(max = MAX_LEVEL_TAUGHT)
      all_sorted.inject([]) {|memo, level| memo << ["L#{level.number}", level.id] if level.number <= max; memo}
    end
  end

  @all = {}
  find(:all).each { |l| @all[l.number] = l }

end
