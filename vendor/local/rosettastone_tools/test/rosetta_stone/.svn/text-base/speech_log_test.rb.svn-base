# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::SpeechLogTest < Test::Unit::TestCase

  if defined?(Eve) && defined?(MongoMapper) && defined?(MongoMapper::Document)

    def test_find_in_event
      event_id = mock_event_find_one({
        'path' => {
          'to' => {
            'log' => 'speech_log_xml'
          }
        }
      })
      mock_instance = 'mock_instance'
      RosettaStone::SpeechLog.expects(:new).with('speech_log_xml').returns(mock_instance)
      assert_equal mock_instance, RosettaStone::SpeechLog.find_in_event(event_id, 'path.to.log')
    end

    def test_find_in_event_when_event_is_not_found
      event_id = mock_event_find_one(nil)
      error = assert_raises(RosettaStone::SpeechLog::SpeechLogEventNotFound) do
        RosettaStone::SpeechLog.find_in_event(event_id, 'path.to.log')
      end
      assert_equal "No event found for `#{event_id}`", error.message
    end

    def test_find_in_event_when_no_speech_log_is_found_in_the_event
      event_id = mock_event_find_one({})
      error = assert_raises(RosettaStone::SpeechLog::SpeechLogNotFound) do
        RosettaStone::SpeechLog.find_in_event(event_id, 'path.to.log')
      end
      assert_equal "No speech log found at `path.to.log` in event `#{event_id}`", error.message
    end

    def mock_event_find_one(return_value)
      event_id = BSON::ObjectId.new
      # I don't know why the "collection.class.any_instance" is necessary. I guess collection returns a different instance every time?
      Eve::MongoMapper::Event.collection.class.any_instance.expects(:find_one).with({'_id' => event_id}, {:fields => 'path.to.log'}).returns(return_value)
      event_id
    end

  end

  def test_that_there_should_be_some_more_tests_here
  end

end
