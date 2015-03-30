require File.expand_path('../../../test_helper', __FILE__)

class CspReflexEventsConsumerAgentTest < ActiveSupport::TestCase

	def test_should_process_valid_message_and_create_reflex_activities
		ReflexActivity.stubs(:create).with({:coach_id => create_valid_message["user_guid"], :timestamp => Time.at(create_valid_message["timestamp"]/1000), :event => create_valid_message["matching_event_type"]})
		CspReflexEventsConsumerAgent.new.process(nil, create_valid_message)
	end

	def test_should_not_process_invalid_message_and_create_reflex_activities
		ReflexActivity.expects(:create).with({:coach_id => create_invalid_message["user_guid"], :timestamp => Time.at(create_invalid_message["timestamp"]/1000), :event => create_invalid_message["matching_event_type"]}).never
		CspReflexEventsConsumerAgent.new.process(nil, create_invalid_message)
	end

	def create_valid_message
		{"launch_mode"=>"teacher", "additional_info"=>nil, "activity_name"=>"reflex_studio", "timestamp"=>1341306473516, "level_of_trust"=>"license_server_authenticated", "request_info"=>{"remote_ip"=>"99.16.132.242", "user_agent"=>"Mozilla/5.0 (Windows NT 6.0; rv:13.0) Gecko/20100101 Firefox/13.0.1"}, "server_side_parameters"=>{"level_of_trust"=>"license_server_authenticated", "request_info"=>{"remote_ip"=>"99.16.132.242", "user_agent"=>"Mozilla/5.0 (Windows NT 6.0; rv:13.0) Gecko/20100101 Firefox/13.0.1"}, "bson_object_id"=>"4ff2b66aeb8b3e699a003536", "session_info"=>{"data"=>{}, "id"=>nil}}, "session_guid"=>"SV_9717c046-abf4-40de-b97d-32a97f98af2a", "matching_event_type"=>"coach_initialized", "user_config"=>nil, "user_guid"=>"987", "bson_object_id"=>"4ff2b66aeb8b3e699a003536", "training_session_id"=>nil, "system_info"=>{"os"=>"Windows Vista", "version"=>"WIN 11,3,300,262", "browserType"=>"appName: Netscape , version: 5.0 (Windows)", "microphoneName"=>nil, "playerType"=>"PlugIn", "isDebugger"=>"false"}, "session_info"=>{"data"=>{}, "id"=>nil}, "event"=>"eschool.module.matching.coach", "student_guid"=>"987"}
	end

	def create_invalid_message
		{"launch_mode"=>"teacher", "activity_name"=>"reflex_studio", "additional_info"=>nil, "timestamp"=>1341306473369, "level_of_trust"=>"license_server_authenticated", "server_side_parameters"=>{"level_of_trust"=>"license_server_authenticated", "request_info"=>{"remote_ip"=>"108.48.72.217", "user_agent"=>"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:13.0) Gecko/20100101 Firefox/13.0.1"}, "bson_object_id"=>"4ff2b66bd045163e9100196a", "session_info"=>{"data"=>{}, "id"=>nil}}, "request_info"=>{"remote_ip"=>"108.48.72.217", "user_agent"=>"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:13.0) Gecko/20100101 Firefox/13.0.1"}, "session_guid"=>"CK_057a2f7800b6edb29ff5279ed4dca644", "matching_event_type"=>"coach_video_publish_stop", "user_config"=>nil, "user_guid"=>"823", "bson_object_id"=>"4ff2b66bd045163e9100196a", "training_session_id"=>"4ff26be0ab2c7138d6005470", "system_info"=>{"os"=>"Mac OS 10.7.4", "version"=>"MAC 11,3,300,257", "browserType"=>"appName: Netscape , version: 5.0 (Macintosh)", "microphoneName"=>nil, "playerType"=>"PlugIn", "isDebugger"=>"false"}, "session_info"=>{"data"=>{}, "id"=>nil}, "event"=>"eschool.module.matching.coach", "student_guid"=>"fa0a80b5-b99c-452e-87b0-37a49b04fd77"}
	end
end