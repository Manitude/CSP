module RsManager
  class Role < RsManagerConnection
    has_many :users, :class_name => "RsManager::User"
    belongs_to :namespace, :class_name => "RsManager::Namespace"
  end
end
