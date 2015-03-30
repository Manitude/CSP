# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))
require 'rosetta_stone/execution_context'

class RosettaStone::ExecutionContextTest < Test::Unit::TestCase

  def test_is_passenger_when_it_is
    mock_process_name!('Passenger ApplicationSpawner: /usr/website/baffler/current')
    assert_true(RosettaStone::ExecutionContext.is_passenger?)
  end

  def test_is_passenger_when_it_is_not
    mock_process_name!('/usr/website/app_launcher/current/public/dispatch.fcgi')
    assert_false(RosettaStone::ExecutionContext.is_passenger?)
  end

  def test_is_mod_fcgid_when_it_is
    mock_process_name!('/usr/website/app_launcher/current/public/dispatch.fcgi')
    assert_true(RosettaStone::ExecutionContext.is_mod_fcgid?)
  end

  def test_is_mod_fcgid_when_it_is_not
    mock_process_name!('Passenger ApplicationSpawner: /usr/website/baffler/current')
    assert_false(RosettaStone::ExecutionContext.is_mod_fcgid?)
  end

  def test_is_web_server_with_passenger
    mock_process_name!('Passenger blah')
    assert_true(RosettaStone::ExecutionContext.is_web_server?)
  end

  def test_is_web_server_with_mod_fcgid
    mock_process_name!('blah/dispatch.fcgi')
    assert_true(RosettaStone::ExecutionContext.is_web_server?)
  end

  def test_is_web_server_with_rake
    mock_process_name!('./rake')
    assert_false(RosettaStone::ExecutionContext.is_web_server?)
  end

  def test_is_rake_when_it_is_local_rake
    mock_process_name!('./rake')
    assert_true(RosettaStone::ExecutionContext.is_rake?)
  end

  def test_is_rake_when_it_is_full_path_rake
    mock_process_name!('/some/path/to/rake')
    assert_true(RosettaStone::ExecutionContext.is_rake?)
  end

  def test_is_rake_when_it_is_rake_in_your_path
    mock_process_name!('rake')
    assert_true(RosettaStone::ExecutionContext.is_rake?)
  end

  def test_is_rake_when_it_is_not
    mock_process_name!('brake')
    assert_false(RosettaStone::ExecutionContext.is_rake?)
  end

  def test_is_irb_when_it_is
    mock_process_name!('irb')
    assert_true(RosettaStone::ExecutionContext.is_irb?)
  end

  def test_is_irb_when_it_is_not
    mock_process_name!('rake')
    assert_false(RosettaStone::ExecutionContext.is_irb?)
  end

private

  def mock_process_name!(name)
    RosettaStone::ExecutionContext.stubs(:process_name).returns(name)
  end
end
