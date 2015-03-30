# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

if defined?(ActionView::Helpers::AssetTagHelper)
  class RosettaStone::SwfPathHelperTest < Test::Unit::TestCase
    include ActionView::Helpers::AssetTagHelper

    def test_methods_include_swf_path
      assert_true(ActionView::Helpers::AssetTagHelper.instance_methods.map(&:to_s).include?('swf_path'))
    end

    # FIXME: I'm a coward. This test breaks Rails 3 and also feels flimsy in Rails 2
    # since we're mixing in the ActionView::Helpers::AssetTagHelper into a class that
    # it would never actually be mixed into in normal operation and it's just by luck
    # that compute_public_path doesn't call any more involved methods.
    #
    # TODO: make this work with Rails 3/more robust. Possible using ActionView::TestCase
    if Rails.version < '3'
      def test_swf_path_with_mocked_controller
        @controller = OpenStruct.new(:protocol => 'http://')
        assert_equal('/swfs/blah.swf', swf_path('blah.swf'))
      end
    end
  end
end
