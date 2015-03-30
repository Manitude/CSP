class LearnerMapper
  def self.map_attributes(source_user, learner_source_type)
    user_source_type = source_user.class.to_s
    options = {}
    options[:first_name] = source_user.first_name
    options[:last_name] = source_user.last_name
    options[:user_source_type] = user_source_type if learner_source_type != "RsManager::User"
    
    if user_source_type == "Community::User"
      options[:mobile_number] = source_user.mobile_number
      options[:village_id] = source_user.village_id
      options[:email] = source_user.email
    else
      options[:email] = source_user.email_address
      options[:user_name] = source_user.username
    end
    options
  end
end
