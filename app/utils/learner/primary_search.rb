class PrimarySearch
  def initialize(params)
    @params = params
  end

  def search
    @params[:phone_number] ||= ""
    @params[:fname] ||= ""
    @params[:lname] ||= ""
    @params[:email] ||= ""
    @params[:username] ||= ""
    return { :error =>"Invalid Phone Number. Note: Letters, Spaces and special characters are not allowed."} unless @params[:phone_number].match('^[\d-]*$')
    conditions = []
    order = []

    unless @params[:fname].blank?
      conditions << "first_name like '#{value(@params[:fname])}'"
      order << "learners.first_name"
    end

    unless @params[:lname].blank?
      conditions << "last_name like '#{value(@params[:lname])}'"
      order << "learners.last_name"
    end

 
    unless @params[:email].blank?
      conditions << "email like '#{value(@params[:email])}'"
      order << "learners.email"
    end

    unless @params[:username].blank?
      conditions << "user_name like '#{value(@params[:username])}'"
      order << "learners.user_name"
    end

    unless @params[:phone_number].blank?
      conditions << " mobile_number like '#{@params[:phone_number]}%'"
      order << "learners.mobile_number"
    end

    conditions = conditions.join(" and ") + village_condition(@params[:village])
    conditions = conditions + language_condition(@params[:language])
    join = "LEFT OUTER JOIN learner_product_rights on learners.id = learner_product_rights.learner_id"
    columns = 'learners.first_name, learners.last_name, learners.email,learners.guid, learners.village_id, learners.user_name,learners.mobile_number, max(learners.id) as id'
    learners = Learner.where(conditions).joins(join).select(columns).group("learners.id").order(order.join(",")).limit(100)
    {:result => learners}
  end

  def value(attr)
    "%#{attr}%".gsub(/[']/, "''")
  end

  def village_condition(village_id)
    return "" if village_id.blank? || village_id === 'all'
    return " and village_id is null" if village_id.to_i == -1
    " and village_id = #{village_id}"
  end

  def language_condition(language_identifier)
    return "" if language_identifier.blank? || language_identifier === 'all'
    return populate_reflex_languages if language_identifier === 'ADE'
    " and learner_product_rights.language_identifier = '#{language_identifier}'"
  end

  def populate_reflex_languages
    initial_condition = " and learner_product_rights.language_identifier in ("
    condition = initial_condition
    ProductLanguages.reflex_language_codes.each do |language|
        condition += ", " unless condition === initial_condition
        condition += "'#{language.strip}'"
    end
    "#{condition})"
  end

end
