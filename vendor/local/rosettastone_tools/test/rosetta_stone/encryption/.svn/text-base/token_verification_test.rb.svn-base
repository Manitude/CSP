# -*- encoding : utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))

class RosettaStone::Encryption::TokenVerification::TestClass
  include RosettaStone::Encryption::TokenVerification

  def make_token(data)
    token(data)
  end
end


class RosettaStone::Encryption::TokenVerificationTest < ActiveSupport::TestCase

  def setup
    mock_key_base_directory!
  end

  def test_round_trip_of_token
    ['{}', 'abcdefg', 'x' * 2048].each do |data|
      assert_round_trip(data)
    end
  end

  def test_making_token_with_nil_value_raises
    assert_cannot_make_token(nil)
  end

  def test_making_token_with_blank_value_raises
    assert_cannot_make_token('')
  end

  def test_length_of_tokens
    1.upto(1000) do |char_length|
      message = ('a'..'z').to_a.join.rand(char_length)
      assert token = make_token(message)
      assert_true(token.length >= char_length + 256, 'Sanity check failed')
      # message length => token length
      # 1  - 16 => 320
      # 17 - 32 => 352
      # ...
      # 128     => 544
      # 512     => 1312
      # 1000    => 2304
      # puts "#{char_length}: #{token.length}, #{((((char_length * 2) / 32) + 2) * 32) + 256}"
      assert_true(token.length <= ((((char_length * 2) / 32) + 2) * 32) + 256, "Token length was #{token.length} for a message length of #{char_length}")
    end
  end

  def test_can_override_encryption_key_subdirectory
    RosettaStone::Encryption::TokenVerification::TestClass.token_verification_encryption_key_subdirectory = :overridden
    RosettaStone::Encryption::Helper.expects(:private_key).once.with(:overridden)
    RosettaStone::Encryption::TokenVerification::TestClass.send(:private_key)
    RosettaStone::Encryption::Helper.expects(:public_key).once.with(:overridden)
    RosettaStone::Encryption::TokenVerification::TestClass.send(:public_key)
  ensure
    RosettaStone::Encryption::TokenVerification::TestClass.token_verification_encryption_key_subdirectory = nil
  end

private

  def assert_round_trip(data)
    assert token = make_token(data)
    assert_not_equal(token, data)
    assert_true(token.is_a?(String))
    assert_equal(data, RosettaStone::Encryption::TokenVerification::TestClass.extract_data_from_token(token))
  end

  def make_token(data)
    RosettaStone::Encryption::TokenVerification::TestClass.new.make_token(data)
  end

  def assert_cannot_make_token(data)
    assert_raises(ArgumentError) do
      make_token(data)
    end
  end
end
