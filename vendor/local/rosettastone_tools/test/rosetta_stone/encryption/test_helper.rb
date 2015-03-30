# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', File.dirname(__FILE__))

class Test::Unit::TestCase

  def mock_key_base_directory!(location = 'test_config')
    RosettaStone::Encryption::Helper.stubs(:config_base_directory).returns(File.join(File.dirname(__FILE__), location))
  end
end
