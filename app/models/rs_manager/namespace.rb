module RsManager
  class Namespace < RsManagerConnection

    include FilterEmail

    has_many :groups, :class_name => "RsManager::Group"
    has_many :users, :class_name => "RsManager::User"

  end
end
