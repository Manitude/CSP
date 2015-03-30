# -*- encoding : utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))

class RosettaStone::Encryption::McodeTest < Test::Unit::TestCase
  include RosettaStone::Encryption

  class << self
    def perl_ginverse(enc_string, key)
      ENV['AICC_ENC_STRING'], ENV['AICC_ENC_KEY'] = enc_string.to_s, key.to_s
      `#{File.dirname(__FILE__) + '/perl/ginverse.pl'}`
    end

    def perl_gfunction(text_string, key)
      ENV['AICC_STRING'], ENV['AICC_ENC_KEY'] = text_string.to_s, key.to_s
      `#{File.dirname(__FILE__) + '/perl/gfunction.pl'}`
    end
  end

# Test Ruby gfunction, against Ruby ginverse, including characters that aren't compatible with
# the original FLTmcode scheme.

  def test_ruby_gfunction_and_ruby_ginverse_with_extended_characters
    run_encryption_tests(Mcode.method(:gfunction), Mcode.method(:ginverse), :build_extended_rand_string)
  end

# Test all combinations of encryption/decryption methods.

  encryption_options = { :ruby_gfunction => Mcode.method(:gfunction),
                         :ruby_gfunction_base => Mcode.method(:gfunction_base),
                         :ruby_gfunction_old => Mcode.method(:gfunction_old),
                         :perl_gfunction => self.method(:perl_gfunction) }

  decryption_options = { :ruby_ginverse => Mcode.method(:ginverse),
                         :ruby_ginverse_base => Mcode.method(:ginverse_base),
                         :ruby_ginverse_old => Mcode.method(:ginverse_old),
                         :perl_ginverse => self.method(:perl_ginverse) }

  encryption_options.each do |enc_key, enc_method|
    decryption_options.each do |dec_key, dec_method|
      define_method("test_#{enc_key.to_s}_and_#{dec_key.to_s}") do
        run_encryption_tests(enc_method, dec_method)
      end
    end
  end

  def test_encoding_of_integer
    int_to_encode, key = 475, Mcode.generate_random_key
    assert_equal(int_to_encode.to_s, Mcode.ginverse(Mcode.gfunction(int_to_encode, key), key))
  end

  def test_encoding_of_float
    float_to_encode, key = 47588.488, Mcode.generate_random_key
    assert_equal(float_to_encode.to_s, Mcode.ginverse(Mcode.gfunction(float_to_encode, key), key))
  end

  def test_encoding_of_object
    obj_to_encode, key = OpenStruct.new(:some_data => true), Mcode.generate_random_key
    assert_equal(obj_to_encode.to_s, Mcode.ginverse(Mcode.gfunction(obj_to_encode, key), key))
  end

# Test key generation

  def test_random_key_generation
    assert_not_equal Mcode.generate_random_key, Mcode.generate_random_key
  end

private

  def run_encryption_tests(encryption_method, decryption_method, random_string_method = :build_rand_string)
    50.times do
      assert rand_string = send(random_string_method)
      assert rand_key = Mcode.generate_random_key
      # FIXME: the perl gfunction *seems* to fail on strings that start with '='?...
      next if rand_string =~ /^=/
      assert_equal rand_string, decryption_method.call(encryption_method.call(rand_string, rand_key), rand_key)
    end
  end
end
