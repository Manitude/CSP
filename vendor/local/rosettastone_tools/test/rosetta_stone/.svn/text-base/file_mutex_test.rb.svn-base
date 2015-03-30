# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::FileMutexTest < Test::Unit::TestCase

  def setup
    mocha_setup # ensure mocha is ready, even for rspec apps
    @mutex = RosettaStone::FileMutex.new('file_mutex_plugin_test')
    @mutex.unlock! # ensure we're clean to begin with
    ensure_tmp_directory_exists!
  end

  def teardown
    mocha_teardown # ensure mocha is cleaned up, even for rspec apps
  end

  def test_locked
    assert_false(@mutex.locked?)
    @mutex.lock!
    assert_true(@mutex.locked?)
    @mutex.unlock!
    assert_false(@mutex.locked?)
  end

  def test_can_expire
    assert_true(@mutex.send(:can_expire?))
    @mutex = RosettaStone::FileMutex.new('file_mutex_plugin_test_2', :expires => false)
    assert_false(@mutex.send(:can_expire?))
    @mutex = RosettaStone::FileMutex.new('file_mutex_plugin_test_2', :expires => true)
    assert_true(@mutex.send(:can_expire?))
  end

  def test_protect_with_just_one
    executed = false
    RosettaStone::FileMutex.protect('file_mutex_plugin_test_3') do
      executed = true
    end
    assert_true(executed)
  end

  def test_protect_embedded
    executed = false
    RosettaStone::FileMutex.protect('file_mutex_plugin_test_4') do
      assert_raises(RosettaStone::FileMutex::Locked) do
        RosettaStone::FileMutex.protect('file_mutex_plugin_test_4') do
          executed = true
        end
      end
    end
    assert_false(executed)
  end

  def test_protect_removes_lock_even_when_yield_raises
    watcher = RosettaStone::FileMutex.new('file_mutex_plugin_test_5')
    assert_raises(RuntimeError) do
      RosettaStone::FileMutex.protect('file_mutex_plugin_test_5') do
        assert_true(watcher.locked?)
        raise
      end
    end
    assert_false(watcher.locked?)
  end

private

  # some old apps (ollcs) have the tmp directory ignored in svn, so
  # let's just try to create the directory if it doesn't exist
  def ensure_tmp_directory_exists!
    tmp_dir = File.join(Rails.root, 'tmp')
    unless File.directory?(tmp_dir)
      require 'fileutils' # why is there not an underscore like file_utils?
      begin
        FileUtils.mkdir(tmp_dir)
      rescue => exception
        raise "tmp dir (#{tmp_dir}) did not exist and could not be created: #{exception}"
      end
    end
  end
end
