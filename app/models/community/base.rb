module Community
  class Base < ActiveRecord::Base
    #Connect to the Community database
    # FIXME:: Is it going to be activeresource call, or local db. If local DB,
    # where are the db configurations and why do we need it, locally?
    self.abstract_class = true
    establish_connection "community_#{Rails.env}"
  end
end
