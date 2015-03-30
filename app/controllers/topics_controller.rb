class TopicsController < ApplicationController
   layout 'default', :only => [:index]
  # GET /topics
  # GET /topics.xml
  def index
    self.page_title = "Topics"
    @topics = Topic.where("removed = 0").order("selected = 1 desc")
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @topics }
    end
  end

  # GET /topics/new
  # GET /topics/new.xml
  def new
    @topic = Topic.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @topic }
    end
  end

  # POST /topics
  # POST /topics.xml
  def create
    @topic = Topic.new(params[:topic])
    if @topic.save
        flash[:notice] = 'Topic was successfully created.'
    else
        flash[:notice] = 'Something went wrong. Topic is not created. Please try again.'
    end
     redirect_to(:action => 'index')
  end

  # PUT /topics/1
  # PUT /topics/1.xml
  def update
    @topic = Topic.find(params[:id])
      if @topic.update_attributes(params[:topic])
       flash[:notice] = 'Topic was successfully updated.'
      else
        flash[:notice] = 'Something went wrong. Topic is not updated. Please try again.'
      end
      redirect_to(:action => 'index') 

  end

  # GET /topics/1/edit
  def edit
    @topic = Topic.find(params[:id])
  end


  # DELETE /topics/1
  # DELETE /topics/1.xml
  def destroy
    @topic = Topic.find(params[:id])
    if @topic.update_attributes(:removed => true)
      flash[:notice] = 'Topic has been hidden.'
    else
      flash[:notice] = 'Something went wrong. Topic is not hidden. Please try again.'
    end
      redirect_to(:action => 'index') 
  end


  def save_topics
    edited_topics = params[:topics_list]
    Topic.where("id in (?)",edited_topics).each do |topic|
      topic.update_attributes(:selected => !topic.selected)
    end
    render :nothing => true
  end

  # (CSP-916) Method to sync CSP data with Biblio Topics endpoint
  def update_topics
    biblio_topics = Callisto::Base.get_all_topics()
    if biblio_topics  
      count_new , count_update = 0, 0
      biblio_topics.each do |hash|
        lang = Language[TOPICS_LEARNING_LANG_CODE[hash["learningLang"]]].id
        insert_topic ={:guid => hash["id"], :revision_id => hash["revision"], :cefr_level => hash["cefrLevel"], :title => hash["title"], :language => lang, :description => hash["description"], :selected => 1}
        insert_topic.except!(:revision_id) if !hash["revision"]
        topic = Topic.find_by_guid(hash["id"])
        if topic.nil?
          Topic.create(insert_topic)
          count_new += 1
        elsif (topic.revision_id != hash["revision"])
          topic.update_attributes(insert_topic.except(:selected))
          count_update += 1
        end
      end
    flash[:notice] = "AEB Topics have been updated successfully. New: #{count_new}, Updated: #{count_update}"
    else
      flash[:error] = "Sorry, we were unable to update the Topics list. Please try again later."
    end
    redirect_to(:action => 'index')
  end
  
  def fetch_topics
  conditions = []
  lang_identifier = Language[params[:language]].id unless params[:language].empty?
  cefr_level = params[:cefr_level] unless params[:cefr_level] == "All"
  conditions << "language = '#{lang_identifier}'" if lang_identifier
  conditions << "cefr_level = '#{cefr_level}'" if cefr_level
  conditions = conditions.join(" and ")
  if conditions.empty?
      @topics = Topic.where("removed = 0").order("selected = 1 desc")
  else
      conditions << " and removed = 0"
      @topics = Topic.where(conditions).order("selected = 1 desc")
  end

  render(:update){|page| page.replace_html 'topics_list' , :partial => "topics_list.html.erb"}
  end
end
