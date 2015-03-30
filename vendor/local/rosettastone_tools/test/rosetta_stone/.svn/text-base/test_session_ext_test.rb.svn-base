# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::TestSessionExtTest < Test::Unit::TestCase
  if Rails::VERSION::MAJOR >= 3
    def test_no_functionality
      assert 1
    end
  else
    def test_when_no_session_id_is_set_exists_returns_false
      session = ActionController::TestSession.new
      assert_false session.exists?
    end

    def test_when_session_id_is_set_exists_returns_true
      session = ActionController::TestSession.new
      session.session_id = '10'
      assert_true session.exists?
    end
  end
end
