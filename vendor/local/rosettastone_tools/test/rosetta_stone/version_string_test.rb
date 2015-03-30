# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::VersionStringTest < Test::Unit::TestCase
  include RosettaStone

  def test_creation
    [
      [VersionString.new(1,2,3), 'Array'],
      [VersionString.new(:major => 1, :minor => 2, :patch_level => 3), 'Symbol Hash'],
      [VersionString.new('major' => 1, 'minor' => 2, 'patch_level' => 3), 'String Hash'],
    ].each do |v, type|
      assert_equal(1, v.major, "major should equal 1 for #{type}")
      assert_equal(2, v.minor, "minor should equal 2 for #{type}")
      assert_equal(3, v.patch_level, "patch_level should equal 3 for #{type}")
    end
  end

  def test_equality
    first, second = VersionString.new(1, 1, 2), VersionString.new(1, 1, 2)
    assert_equal first, second
  end

  def test_greater_than
    versions_with_first_greater_than_last.each do |versions|
      first, second = VersionString.new(*versions.first), VersionString.new(*versions.last)
      assert first > second
    end
  end

  def test_less_than
    versions_with_first_greater_than_last.each do |versions|
      first, second = VersionString.new(*versions.first), VersionString.new(*versions.last)
      assert !(first < second)
    end
  end

  def test_respond_to
    v = VersionString.new(1,1,2)
    assert_true(v.respond_to?(:major))
    assert_true(v.respond_to?(:patch_level))
    assert_true(v.respond_to?(:inspect))
    assert_false(v.respond_to?(:sugar))
  end

  def test_to_hash
    v = VersionString.new(1,2,3)
    assert_equal({:major => 1, :minor => 2, :patch_level => 3}, v.to_hash)
  end

  def test_to_s
    v = VersionString.new(1,2,3)
    assert_equal('1.2.3', v.to_s)
  end

  def test_rails_version_string
    assert_not_nil(RosettaStone::RailsVersionString)
    assert_equal(RosettaStone::VersionString.new(*Rails.version.split('.')), RosettaStone::RailsVersionString)
  end

private

  def versions_with_first_greater_than_last
    [[%w[1 0 20], %w[1 0 2]], [%w[0 1 0], %w[0 0 50]], [%w[5 1 2], %w[1 100 200]], [%w[2 1 30], %w[2 1 25]]]
  end
end
