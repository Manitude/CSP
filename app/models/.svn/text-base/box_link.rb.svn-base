class BoxLink < ActiveRecord::Base
	# id		integer
	# title		string
	# url		string


	validates :title, :presence => true, :uniqueness => true
	validates :url, :presence => true, :uniqueness => true
	validates_format_of :url, :with => /^(https:\/\/app.box.com\/embed_widget|http:\/\/app.box.com\/embed_widget|https:\/\/rosettastone.app.box.com\/embed_widget|http:\/\/rosettastone.app.box.com\/embed_widget)/ , :message => "should be a valid box.com widget url."
end
