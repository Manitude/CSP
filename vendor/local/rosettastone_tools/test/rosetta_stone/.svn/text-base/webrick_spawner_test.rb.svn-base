# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))
require 'rosetta_stone/webrick_spawner'

class RosettaStone::WebrickSpawnerTest < Test::Unit::TestCase

  def test_status_when_not_started
    assert_equal(:Not_started, RosettaStone::WebrickSpawner.status)
    assert_false(RosettaStone::WebrickSpawner.running?)
  end

  def test_status_when_started
    RosettaStone::WebrickSpawner.start(:port => webrick_http_port)
    assert_equal(:Running, RosettaStone::WebrickSpawner.status)
    assert_true(RosettaStone::WebrickSpawner.running?)
    RosettaStone::WebrickSpawner.stop
    assert_false(RosettaStone::WebrickSpawner.running?)
  end

  def test_with_server
    block_ran = false
    assert_false(RosettaStone::WebrickSpawner.running?)
    RosettaStone::WebrickSpawner.with_server(:port => webrick_http_port) do
      block_ran = true
      assert_true(RosettaStone::WebrickSpawner.running?)
    end
    assert_false(RosettaStone::WebrickSpawner.running?)
    assert_true(block_ran)
  end

private

  def webrick_http_port
    # hack to try to get each app using a different port so they don't collide when building in parallel in CI
    @webrick_http_port ||= (Digest::SHA1.hexdigest(Rails.root.to_s).gsub(/[^\d]/, '').to_i.remainder(100) + 3360)
  end
end
