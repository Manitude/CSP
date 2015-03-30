# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::UriExtTest < Test::Unit::TestCase
  VALID_AND_FULLY_SPECIFIED_URIS = %w(http://something https://something/ http://something/blah?false=true http://localhost:3000/test http://127.0.0.1:80)

  def test_valid_uri
    VALID_AND_FULLY_SPECIFIED_URIS.each do |valid_uri|
      assert_true(URI.valid?(valid_uri))
    end
    ['en/us', '/en/us', 'hi', '?hi=true'].each do |valid_uri|
      assert_true(URI.valid?(valid_uri))
    end
  end

  def test_invalid_uri
    invalid_uris = [nil, false, 1, 'hi hi']
    invalid_uris << :something if !RUBY_VERSION.match(/^1\.9\./)
    invalid_uris.each do |not_a_uri|
      assert_false(URI.valid?(not_a_uri), "Expected #{not_a_uri.inspect} to not be considered a valid URI")
    end
  end

  def test_valid_and_fully_specified_in_the_negative_cases
    [nil, '', 'hi', 'http:/hello', :something, false, 1, 'http:||hi|', 'en/us', '/en/us', '?hi=true'].each do |not_a_full_uri|
      assert_false(URI.valid_and_fully_specified?(not_a_full_uri), "Expected #{not_a_full_uri.inspect} to not be considered valid_and_fully_specified?")
    end
  end

  def test_valid_and_fully_specified_in_the_positive_cases
    VALID_AND_FULLY_SPECIFIED_URIS.each do |full_uri|
      assert_true(URI.valid_and_fully_specified?(full_uri), "Expected #{full_uri.inspect} to be considered valid_and_fully_specified?")
    end
  end
end
