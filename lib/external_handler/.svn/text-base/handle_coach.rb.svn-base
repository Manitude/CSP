module ExternalHandler

  class HandleCoach
    class << self

      def create_or_update_coach(coach, action)
        @coach=coach
        update_callisto(action) if action && @coach.is_aria?
        update_saas if @coach.errors.blank?
        if @coach.is_totale?
          update_eschool
        end
      end

      def update_saas
        @coach.update_attribute(:coach_guid, RosettaStone::UUIDHelper.generate) if @coach.coach_guid.blank?
        connection_types = @coach.languages.collect { |l| l.connection_type }.compact.uniq
        connection_types.each do |connection_type|
          res = SuperSaas::Coach.create_or_update(@coach,connection_type)
          @coach.errors.add(:base, "There is some problem with supersaas. Please try after sometime.") unless res && ["201", "200"].include?(res.code)
        end
      end

      def update_callisto(action)
        @coach.update_attribute(:coach_guid, RosettaStone::UUIDHelper.generate) if @coach.coach_guid.blank?
        res = Callisto::Base.create_or_update_coach_in_callisto(action, @coach, @coach.aria_language)
        @coach.errors.add(:base, "There is some problem with callisto. Please try after sometime.") if res[0] == "error"
      end

      def update_eschool
        res = Eschool::Coach.create_or_update_teacher_profile_with_multiple_qualifications(@coach)
        if res
          res = REXML::Document.new res.read_body
          @coach.errors.add(:base, res.elements.to_a("//message").first.text) unless res.elements.to_a("//status").first.text == 'OK'
        else
          @coach.errors.add(:base, "There is some problem with eschool. Please try after sometime.")
        end
      end

    end
  end
end