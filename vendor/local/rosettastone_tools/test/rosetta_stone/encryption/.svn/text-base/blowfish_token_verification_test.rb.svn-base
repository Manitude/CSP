# -*- encoding : utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))
require 'rosetta_stone/encryption/blowfish_token_verification'

class RosettaStone::Encryption::BlowfishTokenVerification::TestClass
  include RosettaStone::Encryption::BlowfishTokenVerification

  def make_token(data)
    token(data)
  end
end


class RosettaStone::Encryption::BlowfishTokenVerificationTest < ActiveSupport::TestCase

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
      assert_true(token.length >= char_length + 16, 'Sanity check failed')
      # message length => token length
      # 1 - 7  => 32
      # 8 - 16 => 48
      # ...
      # 1000   => 2032
      assert_true(token.length <= ((((char_length * 2) / 16) + 2) * 16), "Token length was #{token.length} for a message length of #{char_length}")
    end
  end

private

  def assert_round_trip(data)
    assert token = make_token(data)
    assert_not_equal(token, data)
    assert_true(token.is_a?(String))
    assert_equal(data, RosettaStone::Encryption::BlowfishTokenVerification::TestClass.extract_data_from_token(token))
  end

  def make_token(data)
    RosettaStone::Encryption::BlowfishTokenVerification::TestClass.new.make_token(data)
  end

  def assert_cannot_make_token(data)
    assert_raises(ArgumentError) do
      make_token(data)
    end
  end
end
