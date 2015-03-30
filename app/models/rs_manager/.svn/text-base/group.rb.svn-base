module RsManager
  class Group < RsManagerConnection
    has_many :managements
    has_many :administrators, :through => :managements, :source => :user

  end
end
