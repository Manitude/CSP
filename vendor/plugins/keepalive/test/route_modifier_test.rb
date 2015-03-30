require File.expand_path('test_helper', File.dirname(__FILE__))
require 'route_modifier'

class RosettaStone::KeepAlive::RouteModifierTest < Test::Unit::TestCase

  def test_route_modifier_raises_on_bad_path
    assert_raise(RuntimeError) { RosettaStone::KeepAlive::RouteModifier.new('/tmp/nowhere_and_nothing') }
  end

  def test_bad_routes_file_raises
    modifier = RosettaStone::KeepAlive::RouteModifier.new(route_file(:bad_routes))
    assert_raise(RuntimeError) { modifier.modified_route_file }
  end
  
  def test_route_modifier_modifies_a_standard_file
    modify_route_file(:standard)
  end

  def test_route_modifier_modifies_a_slightly_odd_file
    modify_route_file(:slightly_odd)
  end

  def test_route_modifier_modifies_a_screwy_file
    modify_route_file(:oddest)
  end
  
private
  
  def modify_route_file(file_name)
    original_contents = File.read(route_file(file_name))
    modifier = RosettaStone::KeepAlive::RouteModifier.new(route_file(file_name))
    # before we save, assert that keepalive is actually in there now
    assert_potential_file_has_keepalive(modifier)
    assert modifier.save!
    assert_saved_file_has_keepalive(file_name)
    check_syntax(file_name)
    reverted = modifier.revert!
    reverted_contents = File.read(route_file(file_name))
    assert_equal original_contents, reverted_contents
  ensure
    modifier.revert! unless reverted
  end
  
  def route_file(name)
    File.expand_path("#{File.dirname(__FILE__)}/routes_files/#{name}.rb")
  end
  
  def assert_saved_file_has_keepalive(route_file_name)
    contents = File.read(route_file(route_file_name))
    assert contents =~ /keepalive/
  end
  
  def assert_potential_file_has_keepalive(modifier)
    assert modifier.modified_route_file =~ /keepalive/
  end
  
  def check_syntax(file_name)
    file = route_file(file_name)
    syntax_check_results = `/usr/bin/env ruby -c #{file}`
    assert syntax_check_results == "Syntax OK\n"
  end
  
end
