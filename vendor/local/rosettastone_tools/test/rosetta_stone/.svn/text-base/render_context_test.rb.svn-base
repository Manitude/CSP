# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

if defined?(ActionView::Base)
  class RosettaStone::RenderContextTest < Test::Unit::TestCase
    def setup
      mock_view_path!
    end

    def test_rendering_test_template
      assert_equal('[it worked!]', RosettaStone::RenderContext.render(:file => 'test_template', :locals => {:test_string => 'it worked!'}))
    end

  private

    def mock_view_path!
      test_path = File.join(File.dirname(__FILE__), 'render_context_templates')
      if Rails::VERSION::MAJOR >= 3
        ActionController::Base.view_paths = ActionController::Base.view_paths + [test_path]
      else
        Rails::Configuration.any_instance.expects(:view_path).returns(test_path)
      end
    end
  end
end
