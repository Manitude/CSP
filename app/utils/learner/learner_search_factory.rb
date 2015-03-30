class LearnerSearchFactory
  def self.create(params)
    if !params[:fname].blank? || !params[:lname].blank? || !params[:email].blank? || !params[:phone_number].blank? || !params[:username].blank?
      return PrimarySearch.new(params)
    elsif !params[:search_id].blank?
      return AdvancedSearch.new(params[:search_by_which_id], params[:search_id])
    end
  end
end
