# -*- encoding : utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))
require 'zlib'

class RosettaStone::Encryption::AesTest < Test::Unit::TestCase
  include RosettaStone::Encryption

  def setup
    mock_key_base_directory!
  end

  def test_encrypt_and_decrypt
    (1..200).each do |i|
      message = tale_of_two_cities[0..-i]
      assert_round_trip(message)
    end
  end

  def test_encrypting_blank_value
    assert_raises(ArgumentError) do
      RosettaStone::Encryption::Aes.encrypt('', encryption_key)
    end
  end

  def test_encrypting_nil_value
    assert_raises(ArgumentError) do
      RosettaStone::Encryption::Aes.encrypt(nil, encryption_key)
    end
  end

  def test_decrypting_blank_value
    assert_raises(ArgumentError) do
      RosettaStone::Encryption::Aes.decrypt('', encryption_key)
    end
  end

  def test_decrypting_nil_value
    assert_raises(ArgumentError) do
      RosettaStone::Encryption::Aes.decrypt(nil, encryption_key)
    end
  end

  def test_round_tripping_binary_data
    binary_data = Zlib::Deflate.deflate(tale_of_two_cities)
    assert_round_trip(binary_data)
  end

  # def test_encrypting_a_string_that_ends_with_null
  #   message = "Ending on null\000"
  #   assert_round_trip(message)
  # end

private
  def assert_round_trip(test_message)
    ok_go = RosettaStone::Encryption::Aes.encrypt(test_message, encryption_key)
    back_on_it = RosettaStone::Encryption::Aes.decrypt(ok_go, encryption_key)
    assert_equal test_message, back_on_it
  end

  def tale_of_two_cities
<<-DICKENS
It was the best of times,
it was the worst of times,
it was the age of wisdom,
it was the age of foolishness,
it was the epoch of belief,
it was the epoch of incredulity,
it was the season of Light,
it was the season of Darkness,
it was the spring of hope,
it was the winter of despair.
DICKENS
  end

  def encryption_key
    Helper.sha256(Helper.public_key)
  end
end
