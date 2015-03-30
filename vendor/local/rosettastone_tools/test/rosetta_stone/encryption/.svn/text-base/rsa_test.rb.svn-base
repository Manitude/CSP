# -*- encoding : utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))
require 'digest/sha1'

class RosettaStone::Encryption::RsaTest < Test::Unit::TestCase
  include RosettaStone::Encryption

  def setup
    mocha_setup # ensure mocha is ready, even for rspec apps
    mock_key_base_directory!
  end

  def teardown
    mocha_teardown # ensure mocha is cleaned up, even for rspec apps
  end

  def test_nil_is_ok
    assert_nothing_raised do
      RosettaStone::Encryption::Rsa.sign(nil)
    end
  end

  def test_response_is_a_string
    assert RosettaStone::Encryption::Rsa.sign('asdf').is_a?(String)
  end

  def test_sign_accepts_an_integer_but_unsign_returns_a_string
    number = rand(100000)
    assert_equal(number.to_s, RosettaStone::Encryption::Rsa.unsign(RosettaStone::Encryption::Rsa.sign(number)))
  end

  # this length is based on the sample key
  def test_length_of_signed_sha
    100.times do
      assert_equal 256, RosettaStone::Encryption::Rsa.sign(random_sha).size
    end
  end

  def test_round_trip
    100.times do
      sha = random_sha
      assert_equal sha, RosettaStone::Encryption::Rsa.unsign(RosettaStone::Encryption::Rsa.sign(sha))
    end
  end

  def test_supports_specifying_key_for_signing
    # using Mocha::Mockery instead of just mock() here because mock() is something else
    # if rspec is installed in the app
    mock_encryptor = Mocha::Mockery.instance.named_mock('encryptor') do
      expects(:private_encrypt).returns('')
    end
    OpenSSL::PKey::RSA.expects(:new).with('test_key').returns(mock_encryptor)
    Rsa.sign(random_sha, 'test_key')
  end

  def test_supports_specifying_key_for_unsigning
    # using Mocha::Mockery instead of just mock() here because mock() is something else
    # if rspec is installed in the app
    mock_decryptor = Mocha::Mockery.instance.named_mock('decryptor') do
      expects(:public_decrypt).returns('')
    end
    OpenSSL::PKey::RSA.expects(:new).with('test_key').returns(mock_decryptor)
    Rsa.unsign(random_sha, 'test_key')
  end

private
  def random_sha
    Digest::SHA1.hexdigest(rand(10000).to_s).to_s
  end
end
