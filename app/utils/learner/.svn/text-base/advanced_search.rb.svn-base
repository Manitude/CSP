class AdvancedSearch
  def initialize(id_type, id)
    @id_type = id_type
    @id = id
  end

  def search
    if !@id.blank?
      case @id_type
      when "activation_id"
        product_rights = RosettaStone::ActiveLicensing::Base.instance.product_right.find_by_activation_id(:activation_id => @id)
        guids = product_rights.collect {|pr| pr["license"]["guid"]}.uniq
        learner = Learner.find_by_guid(guids[0]) if guids.size > 0
      when "product_guid"
        product_right = LearnerProductRight.find_by_product_guid(@id)
        learner = product_right.learner if product_right
      when "license_guid"
        learner = Learner.find_by_guid(@id)
      end
    end
    {:result => [learner].compact}
  end
end
