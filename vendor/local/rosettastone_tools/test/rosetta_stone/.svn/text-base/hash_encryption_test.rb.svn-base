# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::HashEncryptionTest < Test::Unit::TestCase

  def test_encryption_decryption_round_trip
    50.times do
      hash = {:license_name => build_extended_rand_string(255), :timestamp => Time.now.to_i}
      assert_equal hash, RosettaStone::HashEncryption.decrypt(RosettaStone::HashEncryption.encrypt(hash))
    end
  end

  def test_length_of_the_generated_url
    hash = {:license_name => 'a' * 255, :timestamp => Time.now.to_i}
    encrypted = RosettaStone::HashEncryption.encrypt(hash)
    assert encrypted.length < 512
  end
end
