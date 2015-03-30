class Artist < ActiveRecord::Base
  has_many :albums
  audit_logged
end

class AnotherKindaArtist < Artist
  audit_logged :only => :name
end

class SomeKindaArtist < Artist
  audit_logged :except => :year_formed
end