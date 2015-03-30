module RosettaStone
  module TestSessionExtensions
    def self.included(klass)
      klass.extend(ClassMethods)
      klass.send(:include, InstanceMethods)
    end

    module ClassMethods
    end

    module InstanceMethods
      # For whatever reason, Rails' TestSession class doesn't include this method, even though
      # it should. Returns true if a session has been created, false otherwise.
      def exists?
        session_id.present?
      end
    end
  end
end

current_env = ::Rails.respond_to?(:env) ? ::Rails.env : RAILS_ENV

if Rails::VERSION::MAJOR < 3 && current_env == 'test'
  require 'action_controller/test_process'
  ActionController::TestSession.send(:include, RosettaStone::TestSessionExtensions)
end
