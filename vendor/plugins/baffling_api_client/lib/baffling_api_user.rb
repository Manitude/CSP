module BafflingApiUser
  
  def self.included(mod)
    mod.send :include, InstanceMethods
    mod.extend(ClassMethods)
  end
  
  attr_writer :baffler_data
  
  REMEMBERED_USER_BONUS = 50*100*1000
  
  
  module ClassMethods
    # FIXME: This is duplicating logic from community in the CurriculumPoint model class.
    def map_curriculum_point(three_part_curriculum_point)
      # this converts {:level => 2, :unit => 1, :lesson => 1 } to {:unit => 5, :lesson => 1} 
      two_part_curriculum_point = {}
      if three_part_curriculum_point['level'].nil? or
        three_part_curriculum_point['unit'].nil? or
        three_part_curriculum_point['lesson'].nil?

        two_part_curriculum_point['unit'] = 0
        two_part_curriculum_point['lesson'] = 0      
      else      
        two_part_curriculum_point['unit'] = 4*(three_part_curriculum_point['level'].to_i-1) + three_part_curriculum_point['unit'].to_i
        two_part_curriculum_point['lesson'] = three_part_curriculum_point['lesson'].to_i
      end

      two_part_curriculum_point    
    end
  
  end
  
  
  module InstanceMethods
  
    def baffler_most_recent_rs3_language_code
      @most_recent_rs3_language_data ||= 
        begin
          RosettaStone::Baffling::ApiClient.new.most_recent_rs3_language(self.guid)
        rescue RosettaStone::Baffling::ApiClientError
          nil
        end
      @most_recent_rs3_language_data && @most_recent_rs3_language_data['language_code']
    end

    def baffler_data(language_code)
      #this will return an empty baffler_data hash if the user is in the baffler 
      #  database but has no data for this lanugage
      #this will return nil if the user does not exist in the baffler database
      @baffler_data = {} unless @baffler_data
      return @baffler_data[language_code] if @baffler_data[language_code]
      value_from_api =
        begin
          RosettaStone::Baffling::ApiClient.new.details(self.guid, language_code)
        rescue RosettaStone::Baffling::ApiClientError
          nil
        end

      @baffler_data[language_code] = value_from_api
    end
    
    def class_readiness(language_code, level, unit)
      @class_readiness = {} unless @class_readiness
      return @class_readiness["#{language_code}#{level}#{unit}"] if @class_readiness["#{language_code}#{level}#{unit}"]
      kpcr = key_path_complete_records_by_level_unit(language_code, level, unit)
      # you're ready if you've completed 3 core lessons
      @class_readiness["#{language_code}#{level}#{unit}"] = (%w[0 1 2] - kpcr.map{|path| path['lesson'] }).empty?
    end
  
    def current_baffler_data
      baffler_data(current_language.identifier)
    end

    def key_path_complete_records_by_level_unit(language_code, level, unit)
      key_path_complete_records(language_code).select { |kpcr| (kpcr["level"].to_i == level.to_i) && (kpcr["unit_index"].to_i == (unit - 1)) }
    end

    def key_path_complete_records(language_code)
      data = baffler_data(language_code)
      key_path_complete_containers = data && data["key_path_complete_records"]
      key_path_completes = key_path_complete_containers && key_path_complete_containers["key_path_complete_record"]
      key_path_completes = [key_path_completes] unless key_path_completes.is_a?(Array)
      key_path_completes = key_path_completes.compact
      key_path_completes
    end
  
    def high_water_mark
      if current_baffler_data
        current_baffler_data['high_water_mark']
      end
    end

    def high_water_mark_string_in_dotted_notation
      hwm = high_water_mark
      return '0.0' unless hwm
      "#{hwm['unit'] || 0}.#{hwm['lesson'] || 0}"
    end

    def total_socapps_time(language_code)
      data = baffler_data(language_code)
      return 0 unless data && data['social_apps'] && data['social_apps']['total']
      data['social_apps']['total']['seconds'].to_i
    end

    def total_rs3_time(language_code)
      data = baffler_data(language_code)
      return 0 if data.nil?
      data['total_rs3_time'].to_i
    end

    def should_interact?(language_code)
      socapps_time, rs3_time = total_socapps_time(language_code), total_rs3_time(language_code)
      return false if (socapps_time == 0) && (rs3_time == 0)
      rs3_time.to_f / (rs3_time + socapps_time) > (RecommendationEngineConfig.first.rs3_time_percentage / 100.0)
    end
  
    def acquaintances
      acquaintances = RosettaStone::Baffling::ApiClient.new.acquaintances(self.guid).map do |api_user|
        user = klass.find_by_guid(api_user.guid) || (raise("ouch, baffler guid not in this app: #{api_user.guid}"))
        user.acquaintance_score = api_user.score.to_i
        user
      end
                
      remembered_users.each do |remembered_user|
        user_in_acquaintance_array = acquaintances.find { |a| a.guid == remembered_user.guid }
      
        if user_in_acquaintance_array
          user_in_acquaintance_array.acquaintance_score = REMEMBERED_USER_BONUS + user_in_acquaintance_array.acquaintance_score
        else
          remembered_user.acquaintance_score = REMEMBERED_USER_BONUS
          acquaintances << remembered_user
        end
      end
    
      acquaintances.sort_by(&:acquaintance_score).reverse    
    end
  
  end
  
end
