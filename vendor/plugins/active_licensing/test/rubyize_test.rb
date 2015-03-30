# -*- encoding : utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))

class RosettaStone::ActiveLicensing::RubyizeTest < Test::Unit::TestCase
  def setup
    @hsh = {"hello" => "true", "there_at" => "1175624047", "future_at" => "2524608000", "check" => "false"}
  end

  def test_rubyize_handles_booleans
    assert_equal true, @hsh.rubyize["hello"]
    assert_equal false, @hsh.rubyize["check"]
  end

  def test_rubyize_handles_keys_ending_in_at_as_times
    assert_equal Time.at(@hsh['there_at'].to_i), @hsh.rubyize['there_at']
  end

  def test_rubyize_handles_times_past_2038_as_date_times
    with_utc_timezone do
      assert_equal @hsh['future_at'].to_i, @hsh.rubyize['future_at'].to_i
    end
  end

  def test_rubyize_is_non_destructive
    new_hsh = @hsh.dup
    @hsh.rubyize
    assert_equal new_hsh, @hsh
  end

  def test_rubyize_is_destructive
    new_hsh = @hsh.dup
    @hsh.rubyize!
    assert_not_equal new_hsh, @hsh
  end

  def test_rubyize_with_bang_is_same_as_rubyize
    assert_equal @hsh.rubyize, @hsh.rubyize!
  end

  def test_rubyize_works_on_hashes_with_indifferent_access
    hsh = HashWithIndifferentAccess.new
    assert hsh.respond_to?(:rubyize)
  end

  def test_rubyize_works_on_child_hashes
    time = Time.now.change(:usec => 0)
    hsh = {:name => 'Bob', :details => {:created_at => time.to_i}}
    hsh.rubyize!
    assert_equal time, hsh[:details][:created_at]
  end

end
