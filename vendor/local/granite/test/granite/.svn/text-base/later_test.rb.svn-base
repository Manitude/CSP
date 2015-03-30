# -*- coding: utf-8 -*-
# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

require File.expand_path('../test_helper', File.dirname(__FILE__))

class Granite::LaterTest < ActiveSupport::TestCase

  class Producer
    
  end

  def setup
  end

  def teardown
    if Granite::Configuration.all_settings['later_implementation'] == 'mongo_mapper'
      Granite::Later::MongoMapperLaterMessage.collection.remove
    end
  end

  if Granite::Configuration.all_settings['later_implementation'] == 'mongo_mapper'
    
    test "test_scheduling_later_messages_with_mongo_mapper" do
      messages = setup_three_messages_for_later
      Time.stubs(:now).returns(Time.at(3))
      Producer.expects(:publish).with(messages[1], {})
      Producer.expects(:publish).with(messages[2], {})
      Producer.expects(:publish).with(messages[4], {}).never
      assert_equal 3, Granite::Later::MongoMapperLaterMessage.count
      Granite::Later.publish_overdue_messages      
      assert_equal 1, Granite::Later::MongoMapperLaterMessage.count
    end
    
    test "test_unscheduling_later_messages_with_mongo_mapper" do
      messages = setup_three_messages_for_later
      Granite::Later.unschedule('identifier 1')
      Time.stubs(:now).returns(Time.at(3))
      Producer.expects(:publish).with(messages[1], {}).never
      Producer.expects(:publish).with(messages[2], {})
      Producer.expects(:publish).with(messages[4], {}).never
      assert_equal 2, Granite::Later::MongoMapperLaterMessage.count
      Granite::Later.publish_overdue_messages      
      assert_equal 1, Granite::Later::MongoMapperLaterMessage.count
    end
    
    test "test_rescheduling_later_messages_with_mongo_mapper" do
      messages = setup_three_messages_for_later
      Granite::Later.schedule('identifier 1', Time.at(5), Producer, {'my_name_is' => 1})
      Time.stubs(:now).returns(Time.at(3))
      Producer.expects(:publish).with(messages[1], {}).never
      Producer.expects(:publish).with(messages[2], {})
      Producer.expects(:publish).with(messages[4], {}).never
      assert_equal 3, Granite::Later::MongoMapperLaterMessage.count
      Granite::Later.publish_overdue_messages      
      assert_equal 2, Granite::Later::MongoMapperLaterMessage.count
    end
    
    test "test_publish_options_with_mongo_mapper" do
      message = {'my' => 'message'}
      publish_options = {:key => 'routing_key'} # key has to be a symbol
      Granite::Later.schedule(
        "identifier", 
        Time.at(0), 
        Producer, 
        message,
        publish_options
      )
      Producer.expects(:publish).with(message, publish_options)
      Granite::Later.publish_overdue_messages
    end
    
  end
  
  def setup_three_messages_for_later
    messages = {}
    [1,2,4].each do |i| 
      messages[i] = {'my_name_is' => i}
      Granite::Later.schedule(
        "identifier #{i}", 
        Time.at(i), 
        Producer, 
        messages[i]
      )
    end
    messages
  end
  
end