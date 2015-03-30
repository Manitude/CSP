# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::MemUsageTest < Test::Unit::TestCase

  def test_virtual
    assert virtual = RosettaStone::MemUsage.virtual
    assert_true virtual.is_a?(Integer)
    assert_true virtual > 0
  end

  def test_resident
    assert resident = RosettaStone::MemUsage.resident
    assert_true resident.is_a?(Integer)
    assert_true resident > 0
  end

  def test_garbage_collect
    GC.expects(:start).once
    RosettaStone::MemUsage.garbage_collect!
  end
end
