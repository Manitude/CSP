class Topic < ActiveRecord::Base
	def self.display_filtered_topic(cefrLevel = nil,language = nil,topics = {})
		where("cefr_level = ? and language = ? and removed = 0 and selected = 1", cefrLevel, language.nil? ? nil : Language[language].id).each do |t|
	      topics[t.id] = t.title
	    end
	topics
	end

	def self.fetch_topic_details(topic_id)
    topic = Topic.find(topic_id) if topic_id
    {:title => topic.title, :description => topic.description, :location => topic.cefr_level} if topic
  end
end
