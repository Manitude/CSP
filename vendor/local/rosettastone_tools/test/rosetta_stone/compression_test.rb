# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::CompressionTest < Test::Unit::TestCase

  def test_round_trip_of_various_values
    uncompressed_strings.each do |value|
      assert_round_trip(value)
    end
  end

  def test_compression_of_nil
    compressed = nil
    assert_nothing_raised do
      compressed = RosettaStone::Compression.compress(nil)
    end
    assert_equal('', RosettaStone::Compression.decompress(compressed)) # treats things as strings
  end

  def test_decompression_of_uncompressed_strings
    uncompressed_strings.each do |uncompressed_string|
      assert_equal(uncompressed_string, RosettaStone::Compression.decompress(uncompressed_string))
    end
  end

  def test_is_compressed_for_uncompressed_strings
    uncompressed_strings.each do |uncompressed_string|
      assert_false(RosettaStone::Compression.is_compressed?(uncompressed_string))
    end
  end

  def test_is_compressed_for_compressed_strings
    uncompressed_strings.each do |uncompressed_string|
      assert_true(RosettaStone::Compression.is_compressed?(RosettaStone::Compression.compress(uncompressed_string)))
    end
  end

private
  def assert_round_trip(value)
    assert_equal(value, RosettaStone::Compression.decompress(RosettaStone::Compression.compress(value)))
  end

  def uncompressed_strings
    ['', '1', ' ', 'üaçî', 'a' * 10000, '0123456789'.rand(5000)]
  end
end
