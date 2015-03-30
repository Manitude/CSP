module Granite
  module RangedChunkAgentsController
    
    # def self.included
    #   
    #   #something about the view path here?
    #   super
    # end
    
    def index
      @ranged_chunk_agents = Granite::RangedChunkAgent.all
    end

    def new
    end
  
    def create
      @ranged_chunk_agent = Granite::RangedChunkAgent.create(params[:ranged_chunk_agent])
      @ranged_chunk_agent.save!
      redirect_to(:action => :index)
    rescue ActiveRecord::RecordInvalid
      render(:action => :new)
    end
  
    def edit
      @ranged_chunk_agent = Granite::RangedChunkAgent.find params[:id]
    end
  
    def update
      @ranged_chunk_agent = Granite::RangedChunkAgent.find params[:id]
      @ranged_chunk_agent.update_attributes! params[:ranged_chunk_agent]
      redirect_to(:action => :index)
    rescue ActiveRecord::RecordInvalid
      render(:action => :edit)
    end
  
    def show
      @ranged_chunk_agent = Granite::RangedChunkAgent.find params[:id]
    end

    def destroy
      @ranged_chunk_agent = Granite::RangedChunkAgent.find params[:id]
      begin
        @ranged_chunk_agent.destroy
      rescue ActiveRecord::StatementInvalid => mysql_error
        flash[:error] = "Error deleting chunk agent: #{mysql_error}"
        redirect_to(:action => :index)
        return
      end
      redirect_to(:action => :index)
    end
  
    def run
      @ranged_chunk_agent = Granite::RangedChunkAgent.find params[:id]
      if @ranged_chunk_agent.should_run?
        chunks = @ranged_chunk_agent.run 
        flash[:notice] = "Agent #{@ranged_chunk_agent.agent_class} published #{chunks.inspect}"
      else
        flash[:error] = "Agent #{@ranged_chunk_agent.agent_class} should not run. It is either disabled, or has not passed its time interval."
      end
      
      redirect_to(:action => :index)
    end
    
    def toggle_enabled
      @ranged_chunk_agent = Granite::RangedChunkAgent.find params[:id]
      @ranged_chunk_agent.update_attribute(:enabled, !@ranged_chunk_agent.enabled?)
      redirect_to(:action => :index)
    end
    
    def enable_all
      Granite::RangedChunkAgent.all.each { |rca| rca.update_attribute(:enabled, true) }
      redirect_to(:action => :index)
    end
    
    def disable_all
      Granite::RangedChunkAgent.all.each { |rca| rca.update_attribute(:enabled, false) }
      redirect_to(:action => :index)
    end
    
    private

    def render(*args)
      options = args.extract_options!
      options[:template] = "granite/ranged_chunk_agents/#{params[:action]}"
      super(*(args << options))
    end
    
  end
end