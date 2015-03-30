# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

require File.expand_path('../test_helper', File.dirname(__FILE__))

class Granite::JobTest < ActiveSupport::TestCase

  test 'parsing empty raw message' do
    assert_raises(Granite::Job::MalformedMessage) do
      Granite::Job.parse('')
    end

    assert_raises(Granite::Job::MalformedMessage) do
      Granite::Job.parse(nil)
    end
  end

  test 'make sure job verifies the attributes' do
    assert_raises(Granite::Job::MalformedMessage) do
      Granite::Job.parse({:timestamp => Time.now.to_i, :job_guid => "1223"}.to_json)
    end
    assert_raises(Granite::Job::MalformedMessage) do
      Granite::Job.parse({:timestamp => Time.now.to_i, :payload => "1223"}.to_json)
    end
    assert_raises(Granite::Job::MalformedMessage) do
      Granite::Job.parse({:payload => "ok", :job_guid => "1223"}.to_json)
    end
  end

  test 'job transforms timestamp into a time object' do
    job = Granite::Job.parse(json_job)

    assert job.timestamp.is_a?(Time)
  end

  test 'job transforms invalid timestamp into a Time object at time now' do
    now = Time.now
    Time.stubs(:now).returns(now)
    job = Granite::Job.parse(json_job({:timestamp => 1111111111111111111111111111}))
    assert job.timestamp.is_a?(Time)
    assert_equal now.to_i, job.timestamp.to_i
  end

  test 'job transforms negative timestamp into a Time object at time now' do
    now = Time.now
    Time.stubs(:now).returns(now)
    job = Granite::Job.parse(json_job({:timestamp => -1 }))
    assert job.timestamp.is_a?(Time)
    assert_equal now.to_i, job.timestamp.to_i
  end

  test 'parsing message that is not json raises Granite::Job::MalformedMessage' do
    assert_raises(Granite::Job::MalformedMessage) do
      Granite::Job.parse('asdf')
    end
  end

  test 'parsing message that is valid json but is not a hash raises Granite::Job::MalformedMessage' do
    assert_raises(Granite::Job::MalformedMessage) do
      Granite::Job.parse('[1,2]')
    end
  end

  test 'parsing message that is a valid json hash but does not have the appropriate keys raises Granite::Job::MalformedMessage' do
    assert_raises(Granite::Job::MalformedMessage) do
      Granite::Job.parse('{"1":2}')
    end
  end

  test 'parsing message that is a valid granite job' do
    assert_equal('GOGOGOG', Granite::Job.parse(json_job).payload)
  end

  test 'parsing message that is a valid granite job and compressed' do
    assert_equal('GOGOGOG', Granite::Job.parse(RosettaStone::Compression.compress(json_job)).payload)
  end

  test 'created message has appropriate keys' do
    outgoing_job = Granite::Job.create('wazzup')
    job = Granite::Job.parse(outgoing_job.to_json)
    assert_equal('wazzup', job.payload)
  end

private

  def json_job(options = {})
    {:timestamp => Time.now.to_i, :job_guid => "1223", :payload => "GOGOGOG", :retries => 0, :protocol_version => 1}.to_json
  end

end
