# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::ArrayExtensionsTest < Test::Unit::TestCase

  def test_deep_freeze
    a = [
      [1, 2]
    ].deep_freeze

    assert_raises(expected_error_on_modifying_frozen_array) do
      a << 0
    end

    assert_raises(expected_error_on_modifying_frozen_array) do
      a[0] << 3
    end
  end

  def test_median
    # assert_equal 2, [3,2,1,0,4].median
    #     assert_equal 1.5, [3,2,0,1].median
    assert_equal 0.75, [0.3, 0.7, 0.8, 0.9].median
    assert_equal 0.75, [0.7, 0.3, 0.9, 0.8].median
    error = assert_raises(RuntimeError) do
      [].median
    end
    assert_equal "Can't find median of empty array", error.message
  end

  def test_shuffle_is_on_array
    assert_true [].respond_to?(:shuffle)
    assert_true [].respond_to?(:shuffle!)
    assert_equal 3, [1,2,3].shuffle.size
  end

  def test_pluck_uniq
    assert_equal 1, [{:a => 1}, {:a => 1}].pluck_uniq { |element| element[:a] }
    assert_equal nil, [{:a => 1}, {:a => 1}].pluck_uniq { |element| element[:b] }
    assert_raises(RuntimeError) do
      [{:a => 1}, {:a => 2}].pluck_uniq { |element| element[:a] }
    end
    assert_raises(RuntimeError) do
      [{:a => 1}, {}].pluck_uniq { |element| element[:a] }
    end
  end

  def test_fetch_uniq
    assert_equal 1, [{:a => 1}, {:a => 1}].fetch_uniq { |element| element[:a] }
    assert_raises(RuntimeError) do
      [{:a => 1}, {:a => 1}].fetch_uniq { |element| element[:b] }
    end
    assert_raises(RuntimeError) do
      [{:a => 1}, {:a => 2}].fetch_uniq { |element| element[:a] }
    end
    assert_raises(RuntimeError) do
      [{:a => 1}, {}].fetch_uniq { |element| element[:a] }
    end
  end

  protected

  def expected_error_on_modifying_frozen_array
    RUBY_VERSION.match(/^1\.9\./) ? RuntimeError : TypeError
  end

end
