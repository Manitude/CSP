# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::UUIDHelperTest < Test::Unit::TestCase

  def test_that_it_returns_a_string_that_looks_like_a_uuid
    # don't run this test if the app doesn't have uuidtools gem embedded:
    return unless RosettaStone::UUIDHelper.has_uuidtools?
    uuid = RosettaStone::UUIDHelper.generate
    assert_true(uuid.is_a?(String))
    assert_equal(36, uuid.length)
    10.times do
      assert_true(RosettaStone::UUIDHelper.looks_like_guid?(RosettaStone::UUIDHelper.generate))
    end
  end

  def test_looks_like_guid_when_it_is_not
    [
      nil,
      '',
      'hi',
      'xx9c972d-7dfd-4021-aa50-d7205e708e20', # has X
      '1D2CF291-C772-4983-8BF9-AEC11E045059', # uppercase is not valid to us
      '9c89095b-8a9b-49e5-98d6-d79b5658a9a', # not enough letters
    ].each do |invalid_guid|
      assert_false(RosettaStone::UUIDHelper.looks_like_guid?(invalid_guid), "Expected '#{invalid_guid}' to not look like a guid")
    end
  end

  def test_hexdigest
    return unless RosettaStone::UUIDHelper.has_uuidtools?
    hexdigest_rails_session_id = '0051cbe1a8d1dfebf89af7a833b4d9f1'
    assert_equal '0051cbe1-a8d1-dfeb-f89a-f7a833b4d9f1', RosettaStone::UUIDHelper.from_hexdigest(hexdigest_rails_session_id)
    assert_equal hexdigest_rails_session_id, RosettaStone::UUIDHelper.to_hexdigest(RosettaStone::UUIDHelper.from_hexdigest(hexdigest_rails_session_id))
  end
end
