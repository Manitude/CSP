require 'rails/all'
Rails.env = "test"

require 'xml/libxml'
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails/test_help'
require File.expand_path('../test_data', __FILE__)
require File.expand_path('../factory_girl_helper', __FILE__)

class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true
  # set_fixture_class :scheduler_metadata => SchedulerMetadata # very important line

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  #fixtures :all

  def assert_include(collection, object, message=nil)
    full_message = build_message(message, "<?> expected to include\n<?>.", collection, object)
    assert_block(full_message) do
      collection.include?(object)
    end
  end
  # Add more helper methods to be used by all tests here...

  # ActiveResource find converts the XML we receive to objects of type Eschool::Coach
  # We need the same behavior for the test cases as well. So use these methods on your XML when you simulate an ActiveRecord GET

  def parse_coaches_xml_to_array_of_objects(xml)
    doc = XML::Parser.string(xml).parse
    coach_objs = []
    doc.find("//teacher").each do |coach|
      coach_objs <<  Eschool::Coach.new(
        :id => coach.find("id")[0].content,
        :external_coach_id =>  coach.find("external_coach_id")[0].content,
        :user_name => coach.find("user_name")[0].content,
        :full_name => coach.find("full_name")[0].content,
        :email => coach.find("email")[0].content,
        :time_zone => coach.find("time_zone")[0].content)
    end
    coach_objs
  end

  def parse_session_xml_to_array_of_objects(xml)
    doc = LibXML::XML::Parser.string(xml).parse
    eschool_session_objs = []
    doc.find("//eschool_session").each do |eschool_session|
      eschool_session_objs <<  Eschool::Session.new(
        :eschool_session_id => eschool_session.find('eschool_session_id')[0].content,
        :language =>  eschool_session.find('language')[0].content,
        :level => eschool_session.find('level')[0].content,
        :unit => eschool_session.find('unit')[0].content,
        :teacher => eschool_session.find('teacher')[0].content,
        :start_time => eschool_session.find('start_time')[0].content,
        :duration_in_seconds => eschool_session.find('duration_in_seconds')[0].content,
        :cancelled => eschool_session.find('cancelled')[0].content,
        :teacher_confirmed => eschool_session.find('teacher_confirmed')[0].content,
        :number_of_seats => eschool_session.find('number_of_seats')[0].content,
        :learners_signed_up => eschool_session.find('learners_signed_up')[0].content,
        :students_attended => eschool_session.find('students_attended')[0].content,
        :wildcard => eschool_session.find('wildcard')[0].content,
        :wildcard_units => eschool_session.find('wildcard_units')[0].content,
        :wildcard_locked => eschool_session.find('wildcard_locked')[0].content,
        :external_village_id => eschool_session.find('external_village_id')[0].content)
    end
    eschool_session_objs
  end

  def parse_xml_to_student_object(xml)
    doc = XML::Parser.string(xml).parse
    eschool_student=[]
    doc.find("//student").each do |es|
      eschool_student << Eschool::Student.new(
        :email=>es.find('email')[0].content,
        :lang_id=>es.find('lang_id')[0].content)
    end
    eschool_student
  end

  def assert_presence_required(object, field)
    # Test that the initial object is valid
    object.valid?
    assert object.valid?

    # Test that it becomes invalid by removing the field
    temp = object.send(field)
    object.send("#{field}=", nil)
    assert !object.valid?
    assert object.errors[field].any?, "Expected an error on validation"

    # Make object valid again
    object.send("#{field}=", temp)
  end

  def parse_session_xml_to_object(xml)
    doc = LibXML::XML::Parser.string(xml).parse
    eschool_session_obj = nil
    learner_details = []
    doc.find("//attendance").each do |learner|

      if learner.find('student_guid')[0]
        learner_details << Eschool::Learner.new(
          :student_email => learner.find('student_email')[0] ? learner.find('student_email')[0].content : nil,
          :student_guid => learner.find('student_guid')[0]? learner.find('student_guid')[0].content : nil,
         #:student_language => learner.find('student_language')[0]? learner.find('student_language')[0].content : nil,
          :student_attended => learner.find('student_attended')[0]? learner.find('student_attended')[0].content : nil,
          :student_time_zone => learner.find('student_time_zone')[0]? learner.find('student_time_zone')[0].content : nil,        
          :audio_input_device => learner.find('audio_input_device')[0]? learner.find('audio_input_device')[0].content : nil,
          :audio_output_device => learner.find('audio_output_device')[0]? learner.find('audio_output_device')[0].content : nil,
          :first_name => learner.find('first_name')[0]? learner.find('first_name')[0].content : nil,
          :last_name => learner.find('last_name')[0]? learner.find('last_name')[0].content : nil,
          :audio_input_device_status => learner.find('audio_input_device_status')[0]? learner.find('audio_input_device_status')[0].content : nil,
          :has_technical_problem => learner.find('has_technical_problem')[0]? learner.find('has_technical_problem')[0].content : nil,
          :preferred_name => learner.find('preferred_name')[0]? learner.find('preferred_name')[0].content : nil,
          :user_agent => learner.find('user_agent')[0]? learner.find('user_agent')[0].content : nil,
          :support_language_iso => learner.find('support_language_iso')[0]? learner.find('support_language_iso')[0].content : nil)
      end
    end
    doc.find("//eschool_session").each do |eschool_session|
      eschool_session_obj =  Eschool::Session.new(
        :eschool_session_id => eschool_session.find('eschool_session_id')[0].content,
        :language =>  eschool_session.find('language')[0].content,
        :level => eschool_session.find('level')[0].content,
        :unit => eschool_session.find('unit')[0].content,
        :lesson => eschool_session.find('lesson')[0].content,
        :teacher => eschool_session.find('teacher')[0].content,
        :start_time => eschool_session.find('start_time')[0].content,
        :duration_in_seconds => eschool_session.find('duration_in_seconds')[0].content,
        :cancelled => eschool_session.find('cancelled')[0].content,
        :number_of_seats => eschool_session.find('number_of_seats')[0].content,
        :learners_signed_up => eschool_session.find('learners_signed_up')[0].content,
        :students_attended => eschool_session.find('students_attended')[0].content,
        :wildcard => eschool_session.find('wildcard')[0].content,
        :wildcard_units => eschool_session.find('wildcard_units')[0].content,
        :wildcard_locked => eschool_session.find('wildcard_locked')[0].content,
        :teacher_confirmed => eschool_session.find('teacher_confirmed')[0].content,
        :launch_session_url  =>eschool_session.find('launch_session_url')[0].content,
        :average_attendance => eschool_session.find('average_attendance')[0].content,
        :external_village_id => eschool_session.find('external_village_id')[0].content,
        :learner_details =>[])

      eschool_session_obj.learner_details = learner_details
    end
    eschool_session_obj
  end

  def parse_xml_to_leaner_object(xml)
    doc = XML::Parser.string(xml).parse
    learner_studio_history = nil
    eschool_session_obj = []
    feed_back_obj = []
    doc.find("//learner").each do |learner|
      learner_studio_history = Eschool::Learner.new(
        :guid =>  learner.find('guid')[0].content,
        :time_zone => learner.find('time_zone')[0].content
      )
    end

    doc.find("//eschool_session").each do |eschool_session|
      if eschool_session.find('language_code')
          eschool_obj = Eschool::Session.new(
          :language_code => eschool_session.find('language_code')[0].content,
          :level  => eschool_session.find('level')[0].content,
          :unit  => eschool_session.find('unit')[0].content,
          :attended  => eschool_session.find('attended')[0].content,
          :cancelled  => eschool_session.find('cancelled')[0].content,
          :technical_issues  => eschool_session.find('technical_issues')[0].content,
          :coach  => eschool_session.find('coach')[0].content,
          :coach_id  => eschool_session.find('coach_id')[0].content,
          :start_time  => eschool_session.find('start_time')[0].content,
          :first_seen_at  => eschool_session.find('first_seen_at')[0].content,
          :last_seen_at  => eschool_session.find('last_seen_at')[0].content,
          :feedbacks => []
        )
        eschool_session.find("//feedback").each do |feedback|
          feed_back_obj <<  Eschool::Session.new(
            :label => feedback.find('label')[0] ? feedback.find('label')[0].content : nil,
            :value  => feedback.find('value')[0] ? feedback.find('value')[0].content : nil,
            :score  => feedback.find('score')[0] ? feedback.find('score')[0].content : nil,
            :notes  => feedback.find('notes')[0] ? feedback.find('notes')[0].content : nil
          )
        end
        eschool_obj.feedbacks = feed_back_obj
        eschool_session_obj << eschool_obj
      end
    end
    learner_studio_history.eschool_sessions = eschool_session_obj
    learner_studio_history
  end

  cattr_accessor :classes_cache
  #class cache for storing already founded classes from models
  @@classes_cache = {}

  def load_user_fixtures(*table_names)
    fixtures = {}
    table_names = table_names.flatten.collect{|t| t.to_s}
    table_names.each do |table_name|
      unless @@classes_cache[table_name].nil?
        klas = @@classes_cache[table_name]
      else
        begin
          #try to find class name from table name
          klas = eval(table_name.classify)
        rescue
          #go to model directory, run through all models and search for table name
          classes = Dir.entries(RAILS_ROOT + "/app/models").select{|d| d.include?(".rb")}.collect{|f| File.basename(f, ".rb").classify}
          klas_names = classes.select{|f| (eval("#{f}.table_name") rescue false)==table_name }
          klas_name = klas_names.blank? ? table_name.classify : klas_names.first
          klas = eval(klas_name)
        end
        @@classes_cache[table_name] = klas
      end
      #load fixture
      fixtures[table_name] = Fixtures.create_fixtures(File.dirname(__FILE__) + "/fixtures", table_name,
        {table_name.to_sym => klas.name}){klas.connection}
    end


    #run through all fixtures and instantiate them
    #fixtures.each_pair do |table_name, fixs|
    #Fixtures.instantiate_fixtures(self, table_name, fixs)
    #end
  end

  def run_time_zone_fn
    ActiveRecord::Base.connection.execute(
      "DROP FUNCTION IF EXISTS fn_GetTimeZone;"
    )

    ActiveRecord::Base.connection.execute(
      "CREATE FUNCTION fn_GetTimeZone (input_date DATETIME) returns varchar(3)
              DETERMINISTIC
              RETURN  CASE  WHEN month(input_date) IN (4,5,6,7,8,9,10) THEN 'EDT'
                            WHEN month(input_date) IN (1,2,12) THEN 'EST'
                            WHEN month(input_date) IN (3) THEN  CASE  WHEN DAY(input_date) >  1 +(7+((8-DAYOFWEEK(input_date - INTERVAL( DAYOFMONTH(input_date) - 1) day)) % 7)) THEN 'EDT'
                                                                      WHEN DAY(input_date) =  1 +(7+((8-DAYOFWEEK(input_date - INTERVAL( DAYOFMONTH(input_date) - 1) day)) % 7)) THEN CASE WHEN TIME(input_date) > '01:59:00' THEN 'EDT' ELSE 'EST' END
                                                                      ELSE 'EST'
                                                                END
                            WHEN month(input_date) IN (11) THEN CASE  WHEN DAY(input_date) <  1 +((8-DAYOFWEEK(input_date - INTERVAL( DAYOFMONTH(input_date) - 1) day))% 7) THEN 'EDT'
                                                                      WHEN DAY(input_date) =  1 +((8-DAYOFWEEK(input_date - INTERVAL( DAYOFMONTH(input_date) - 1) day)) % 7)THEN CASE WHEN TIME(input_date) <= '01:00:00' THEN 'EDT' ELSE 'EST' END
                                                                      ELSE 'EST'
                                                                END
                            ELSE 'EDT'
                     END;"
    )

    run_time_zone_fn_offset
  end

  def run_time_zone_fn_offset
    ActiveRecord::Base.connection.execute(
      "DROP FUNCTION IF EXISTS fn_GetZoneOffset;"
    )
    ActiveRecord::Base.connection.execute(
      "CREATE FUNCTION fn_GetZoneOffset (input_date DATETIME) returns integer
              DETERMINISTIC
              RETURN     CASE     WHEN month(input_date) IN (4,5,6,7,8,9,10) THEN 4
                            WHEN month(input_date) IN (1,2,12) THEN 5
                            WHEN month(input_date) IN (3) THEN     CASE
                                 WHEN DAY(input_date) >  1 +(15-DAYOFWEEK(input_date - INTERVAL( DAYOFMONTH(input_date) - 1) day)) THEN 4
                              WHEN DAY(input_date) =  1 +(15-DAYOFWEEK(input_date - INTERVAL( DAYOFMONTH(input_date) - 1) day)) THEN CASE WHEN TIME(input_date) > '01:59:00' THEN 4 ELSE 5 END
                              ELSE 5
                            END
                            WHEN month(input_date) IN (11) THEN CASE     WHEN DAY(input_date) <  1 +(8-DAYOFWEEK(input_date - INTERVAL( DAYOFMONTH(input_date) - 1) day)) THEN 4
                              WHEN DAY(input_date) =  1 +(8-DAYOFWEEK(input_date - INTERVAL( DAYOFMONTH(input_date) - 1) day)) THEN CASE WHEN TIME(input_date) <= '01:00:00' THEN 4 ELSE 5 END
                              ELSE 5
                            END
                            ELSE 4
                     END;"
      )
  end

  def real_time_lotus_data(waiting_students = 0, avg_learners = 0, coach_status = nil, longest_wait_time = 0, waiting_students_details = nil)
    Eschool::LotusSession.stubs(:waiting_students).returns waiting_students
    Eschool::LotusSession.stubs(:average_learners_waiting_time_sec).returns avg_learners
    Eschool::CoachCurrentStatus.stubs(:current_statuses).returns coach_status
    Locos::Lotus.stubs(:find_learners_in_dts).returns 0
    Eschool::LotusSession.stubs(:longest_waiting_time).returns longest_wait_time
    Locos::Lotus.stubs(:find_active_session_details_by_activity).returns('N/A')
    Eschool::StudentQueue.stubs(:learners_waiting_details).returns(waiting_students_details)
  end

  #  def language_stub_for_creating_session
  #    Coach.stubs(:language).returns "KLE"
  #    qualifications(:psubramanian_qualified_to_teach_arabic)
  #    Qualification.stubs(:language).returns "KLE"
  #  end

  def eschool_sesson_without_learner
    session_xml = <<EOF
    <eschool_session>
      <eschool_session_id>8493</eschool_session_id>
      <language>ESP</language>
      <level>1</level>
      <unit>1</unit>
      <lesson>2</lesson>
      <teacher>jramanathan</teacher>
      <teacher_id>12</teacher_id>
      <start_time time_zone="UTC">2011-01-21 10:00:00</start_time>
      <duration_in_seconds>3600</duration_in_seconds>
      <cancelled>false</cancelled>
      <number_of_seats>4</number_of_seats>
      <learners_signed_up>0</learners_signed_up>
      <students_attended>0</students_attended>
      <wildcard>true</wildcard>
      <wildcard_units>1,2,3,4,5,6,7,8,9,10,11,12</wildcard_units>
      <wildcard_locked>false</wildcard_locked>
      <teacher_confirmed>true</teacher_confirmed>
      <learner_details type="array">
      </learner_details>
      <launch_session_url>
        javascript:launchOnline('http://studio.rosettastone.com/launch?app%5Bcancellation_grace_period_in_seconds%5D=3000&amp;app%5Bclass_definition_url%5D=rsus%3A%2F%2Feschool_en-US_U_01&amp;app%5Beschool_session_id%5D=8492&amp;app%5Bfull_name%5D=coach1&amp;app%5Binstruction_end_time%5D=2011-01-21T05%3A50%3A00-05%3A00&amp;app%5Blaunch_controller_mode%5D=teacher&amp;app%5Broom_password%5D=PoL1kad0ts&amp;app%5Broom_user_name%5D=cocomo-eschool-dev%40rosettastone.com&amp;app%5Bscheduler_api_endpoint%5D=http%3A%2F%2Fstudio.rosettastone.com%2Fapi%2F&amp;app%5Bseconds_before_end_to_show_countdown_timer%5D=300&amp;app%5Bskip_audio_setup%5D=false&amp;app%5Bstart_time%5D=2011-01-21T05%3A00%3A00-05%3A00&amp;app%5Bsystem_recommendations_url%5D=http%3A%2F%2Flaunch.rosettastone.com%2Fen%2Fsystem_recommendations%2Fcommunity&amp;app%5Bteacher_id%5D=182&amp;app%5Bteacher_picture_url%5D=http%3A%2F%2Feschool.rosettastone.com%2Fimages%2Fdefault_teacher_image.jpg&amp;app%5Btime_after_start_to_allow_cancellation_in_seconds%5D=36&amp;app%5Bvideo_quality%5D=100&amp;app%5Bweb_services_access_key%5D=248acbe6a91020199a9b5adb609468316eb3e14eba4c9d628b9625bc1ced0bbfd58b2e8996cab88d3fecd1d914a383ea71fc8cbc7c87c73781bce576609bbb5041765984d29cfa90069b1bb5ca8a98b171acd51d829662f32037062d823d20c80e2b549e6f03b097f3c127774ef015b496d2a7468a3d5802e836d8eaea3ee633')
      </launch_session_url>
      <average_attendance>0.0</average_attendance>
      <external_village_id>8</external_village_id>
    </eschool_session>
EOF

    session = parse_session_xml_to_object(session_xml)

  end

  def eschool_sessions_array_without_learner
    session_xml = <<EOF
    <eschool_sessions>
      <eschool_session>
        <eschool_session_id>123456</eschool_session_id>
        <language>ARA</language>
        <level>1</level>
        <unit>1</unit>
        <lesson>2</lesson>
        <teacher>dutchfellow</teacher>
        <teacher_id>12</teacher_id>
        <start_time time_zone="UTC">2025-06-13 12:00:00</start_time>
        <duration_in_seconds>3600</duration_in_seconds>
        <cancelled>false</cancelled>
        <number_of_seats>4</number_of_seats>
        <learners_signed_up>1</learners_signed_up>
        <students_attended>0</students_attended>
        <wildcard>true</wildcard>
        <wildcard_units>1,2,3,4,5,6,7,8,9,10,11,12</wildcard_units>
        <wildcard_locked>false</wildcard_locked>
        <teacher_confirmed>true</teacher_confirmed>
        <learner_details type="array">
        </learner_details>
        <launch_session_url>
          javascript:launchOnline('http://studio.rosettastone.com/launch?app%5Bcancellation_grace_period_in_seconds%5D=3000&amp;app%5Bclass_definition_url%5D=rsus%3A%2F%2Feschool_en-US_U_01&amp;app%5Beschool_session_id%5D=8492&amp;app%5Bfull_name%5D=coach1&amp;app%5Binstruction_end_time%5D=2011-01-21T05%3A50%3A00-05%3A00&amp;app%5Blaunch_controller_mode%5D=teacher&amp;app%5Broom_password%5D=PoL1kad0ts&amp;app%5Broom_user_name%5D=cocomo-eschool-dev%40rosettastone.com&amp;app%5Bscheduler_api_endpoint%5D=http%3A%2F%2Fstudio.rosettastone.com%2Fapi%2F&amp;app%5Bseconds_before_end_to_show_countdown_timer%5D=300&amp;app%5Bskip_audio_setup%5D=false&amp;app%5Bstart_time%5D=2011-01-21T05%3A00%3A00-05%3A00&amp;app%5Bsystem_recommendations_url%5D=http%3A%2F%2Flaunch.rosettastone.com%2Fen%2Fsystem_recommendations%2Fcommunity&amp;app%5Bteacher_id%5D=182&amp;app%5Bteacher_picture_url%5D=http%3A%2F%2Feschool.rosettastone.com%2Fimages%2Fdefault_teacher_image.jpg&amp;app%5Btime_after_start_to_allow_cancellation_in_seconds%5D=36&amp;app%5Bvideo_quality%5D=100&amp;app%5Bweb_services_access_key%5D=248acbe6a91020199a9b5adb609468316eb3e14eba4c9d628b9625bc1ced0bbfd58b2e8996cab88d3fecd1d914a383ea71fc8cbc7c87c73781bce576609bbb5041765984d29cfa90069b1bb5ca8a98b171acd51d829662f32037062d823d20c80e2b549e6f03b097f3c127774ef015b496d2a7468a3d5802e836d8eaea3ee633')
        </launch_session_url>
        <average_attendance>0.0</average_attendance>
        <external_village_id>8</external_village_id>
      </eschool_session>
   </eschool_sessions>
EOF
    eschool_session_objs = parse_session_xml_to_array_of_objects(session_xml)
  end

  def eschool_sessions_array_for_coach_schedule
    session_xml = <<EOF
    <eschool_sessions>
      <eschool_session>
        <eschool_session_id>1234</eschool_session_id>
        <language>ARA</language>
        <level>1</level>
        <unit>1</unit>
        <lesson>2</lesson>
        <teacher>dutchfellow</teacher>
        <teacher_id>12</teacher_id>
        <start_time time_zone="UTC">2025-06-13 12:00:00</start_time>
        <duration_in_seconds>3600</duration_in_seconds>
        <cancelled>false</cancelled>
        <number_of_seats>4</number_of_seats>
        <learners_signed_up>1</learners_signed_up>
        <students_attended>0</students_attended>
        <wildcard>true</wildcard>
        <wildcard_units>1,2,3,4,5,6,7,8,9,10,11,12</wildcard_units>
        <wildcard_locked>false</wildcard_locked>
        <teacher_confirmed>true</teacher_confirmed>
        <learner_details type="array">
        </learner_details>
        <launch_session_url>
          javascript:launchOnline('http://studio.rosettastone.com/launch?app%5Bcancellation_grace_period_in_seconds%5D=3000&amp;app%5Bclass_definition_url%5D=rsus%3A%2F%2Feschool_en-US_U_01&amp;app%5Beschool_session_id%5D=8492&amp;app%5Bfull_name%5D=coach1&amp;app%5Binstruction_end_time%5D=2011-01-21T05%3A50%3A00-05%3A00&amp;app%5Blaunch_controller_mode%5D=teacher&amp;app%5Broom_password%5D=PoL1kad0ts&amp;app%5Broom_user_name%5D=cocomo-eschool-dev%40rosettastone.com&amp;app%5Bscheduler_api_endpoint%5D=http%3A%2F%2Fstudio.rosettastone.com%2Fapi%2F&amp;app%5Bseconds_before_end_to_show_countdown_timer%5D=300&amp;app%5Bskip_audio_setup%5D=false&amp;app%5Bstart_time%5D=2011-01-21T05%3A00%3A00-05%3A00&amp;app%5Bsystem_recommendations_url%5D=http%3A%2F%2Flaunch.rosettastone.com%2Fen%2Fsystem_recommendations%2Fcommunity&amp;app%5Bteacher_id%5D=182&amp;app%5Bteacher_picture_url%5D=http%3A%2F%2Feschool.rosettastone.com%2Fimages%2Fdefault_teacher_image.jpg&amp;app%5Btime_after_start_to_allow_cancellation_in_seconds%5D=36&amp;app%5Bvideo_quality%5D=100&amp;app%5Bweb_services_access_key%5D=248acbe6a91020199a9b5adb609468316eb3e14eba4c9d628b9625bc1ced0bbfd58b2e8996cab88d3fecd1d914a383ea71fc8cbc7c87c73781bce576609bbb5041765984d29cfa90069b1bb5ca8a98b171acd51d829662f32037062d823d20c80e2b549e6f03b097f3c127774ef015b496d2a7468a3d5802e836d8eaea3ee633')
        </launch_session_url>
        <average_attendance>0.0</average_attendance>
        <external_village_id>8</external_village_id>
      </eschool_session>
   </eschool_sessions>
EOF
    parse_session_xml_to_array_of_objects(session_xml)
  end

  def eschool_session_with_learner
    session_xml_l = <<EOF
    <eschool_session>
      <eschool_session_id>8494</eschool_session_id>
      <language>ESP</language>
      <level>1</level>
      <unit>1</unit>
      <lesson>4</lesson>
      <teacher>jramanathan</teacher>
      <teacher_id>12</teacher_id>
      <start_time time_zone="UTC">2011-01-21 10:00:00</start_time>
      <duration_in_seconds>3600</duration_in_seconds>
      <cancelled>false</cancelled>
      <number_of_seats>4</number_of_seats>
      <learners_signed_up>1</learners_signed_up>
      <students_attended>0</students_attended>
      <wildcard>true</wildcard>
      <wildcard_units>1</wildcard_units>
      <wildcard_locked>true</wildcard_locked>
      <teacher_confirmed>true</teacher_confirmed>
      <learner_details type = "array">
        <attendance>
          <student_time_zone>Eastern Time (US &amp; Canada)</student_time_zone>
          <student_email>1252005165313registration.com</student_email>
          <student_guid>13aaf8b0-9083-4ce0-84e9-f8af6a96ba72</student_guid>
          <student_attended>false</student_attended>
          <user_agent>NA</user_agent>
        </attendance>
      </learner_details>
      <launch_session_url>
        javascript:launchOnline('http://studio.rosettastone.com/launch?app%5Bcancellation_grace_period_in_seconds%5D=3000&amp;app%5Bclass_definition_url%5D=rsus%3A%2F%2Feschool_en-US_U_01&amp;app%5Beschool_session_id%5D=8492&amp;app%5Bfull_name%5D=coach1&amp;app%5Binstruction_end_time%5D=2011-01-21T05%3A50%3A00-05%3A00&amp;app%5Blaunch_controller_mode%5D=teacher&amp;app%5Broom_password%5D=PoL1kad0ts&amp;app%5Broom_user_name%5D=cocomo-eschool-dev%40rosettastone.com&amp;app%5Bscheduler_api_endpoint%5D=http%3A%2F%2Fstudio.rosettastone.com%2Fapi%2F&amp;app%5Bseconds_before_end_to_show_countdown_timer%5D=300&amp;app%5Bskip_audio_setup%5D=false&amp;app%5Bstart_time%5D=2011-01-21T05%3A00%3A00-05%3A00&amp;app%5Bsystem_recommendations_url%5D=http%3A%2F%2Flaunch.rosettastone.com%2Fen%2Fsystem_recommendations%2Fcommunity&amp;app%5Bteacher_id%5D=182&amp;app%5Bteacher_picture_url%5D=http%3A%2F%2Feschool.rosettastone.com%2Fimages%2Fdefault_teacher_image.jpg&amp;app%5Btime_after_start_to_allow_cancellation_in_seconds%5D=36&amp;app%5Bvideo_quality%5D=100&amp;app%5Bweb_services_access_key%5D=248acbe6a91020199a9b5adb609468316eb3e14eba4c9d628b9625bc1ced0bbfd58b2e8996cab88d3fecd1d914a383ea71fc8cbc7c87c73781bce576609bbb5041765984d29cfa90069b1bb5ca8a98b171acd51d829662f32037062d823d20c80e2b549e6f03b097f3c127774ef015b496d2a7468a3d5802e836d8eaea3ee633')
      </launch_session_url>
      <average_attendance>0.0</average_attendance>
      <external_village_id>8</external_village_id>
    </eschool_session>
EOF
    parse_session_xml_to_object(session_xml_l)
  end

  def create_a_coach_and_assign_a_template_to_him
    coach = create_a_coach
    default_options_for_template = {:label => "DeletedTemplate", :effective_start_date => (Time.now + 1.week).to_s(:db), :status => 1, :coach_id => coach.id}
    CoachAvailabilityTemplate.create(default_options_for_template)
    coach
  end

  def create_a_coach
    default_options_for_coach = { "user_name"=>"perfectguy",
      "full_name"=>"Perfect Guy",
      "rs_email"=>"misterperfect@rosettastone.com",
      "personal_email"=>"misterperfect@perfection.com",
      "preferred_name"=>"niceguy",
      "primary_phone"=>"2830581034",
      "primary_country_code"=>"1",
      "secondary_phone"=>"2830581012",
      "skype_id"=>"iamperfect",
      "birth_date(1i)"=>"1951", "birth_date(2i)"=>"8", "birth_date(3i)"=>"9",
      "hire_date(1i)"=>"2011", "hire_date(2i)"=>"8", "hire_date(3i)"=>"9",
      "region_id"=>"",
      "bio"=>"I will be saved successfully"
    }
    Coach.find_all_by_user_name('perfectguy').each(&:delete)
    coach = Coach.create(default_options_for_coach)
    coach.save()
    coach
  end

  def create_template_for_coach(coach)
    default_options_for_template = {:label => "DeletedTemplate", :effective_start_date => (Time.now.utc.beginning_of_week + 1.week).to_s(:db), :status => 1, :coach_id => coach.id}
    FactoryGirl.create(:coach_availability_template, default_options_for_template)
  end

  def create_sessions_for_coach(coach, count=5)
    session_start_time = "2020-08-30 14:00:00 UTC".to_time
    count.times do
      session_default_values = {
        "coach_id" => coach.id,
        "session_start_time" => session_start_time,
        "eschool_session_id" => "345698",
        "cancelled" => "0",
        "language_identifier" => "HEB"
      }
      session = CoachSession.create(session_default_values)
      session.save(:validate => false)
      session_start_time += 1.hour
    end
  end

  def login_as_coach_manager(username = 'vramanan')
    login_as_custom_user(AdGroup.coach_manager, username)
  end

  def login_as_coach
    login_as_custom_user(AdGroup.coach, 'rajkumar')
  end

  def login_as_led_user
    login_as_custom_user(AdGroup.led_user, 'rajkumar')
  end

  def login_as_custom_user(adgroup_type, name)
    if account = Account.find_by_user_name(name)
      account.update_attribute('type', AdGroup.account_type(adgroup_type))
      account.update_attribute('native_language', 'en-US')
    else
      account = FactoryGirl.create(:account, :user_name => name, :full_name => name, :rs_email => "rs_email#{rand(1000).to_s}@rosettastone.com", :type => AdGroup.account_type(adgroup_type))
    end
    if account.type == 'Coach'
      account.update_attribute('created_at', Time.now.utc - 1.day)
      if account.qualifications.blank?
        lang = Language['ARA'] || FactoryGirl.create(:language, :identifier => 'ARA')
        FactoryGirl.create(:qualification, :language => lang, :coach_id => account.id, :max_unit =>10)
      end
    end
    FactoryGirl.create(:support_language) unless SupportLanguage.find_by_language_code(account.native_language)
    user = User.new(name)
    user.groups = [adgroup_type]
    user.time_zone = 'America/New_York'
    user.account_id = account.id
    @request.session[:user] = user
    user.account
  end

  def signed_out_all_users!
    session[:user] =  nil
  end

  def eschool_sessions_with_empty_attribute_values_mock
    stub_everything(:eschool_sessions => [])
  end

  def delete_all_languages_for_test
    Language.delete_all # Delete cascade deletes the qualifications also.
  end

  def create_aria_language(identifier)
    (lang = Language.find_by_identifier(identifier)) ? lang : FactoryGirl.create(:language,:identifier=>identifier,:type=>"AriaLanguage")
  end

  def create_lotus_language()
    (lang = Language.find_by_identifier("KLE")) ? lang : FactoryGirl.create(:language,:identifier=>"KLE",:type=>"ReflexLanguage")
  end

  def create_non_lotus_language(identifier)
     (language = Language.find_by_identifier(identifier) )? language : FactoryGirl.create(:language,:identifier=>identifier,:type=>"TotaleLanguage")
  end

  def create_michelin_language
     (language = Language.find_by_identifier('TMM-MCH-L') )? language : FactoryGirl.create(:language,:identifier=>'TMM-MCH-L',:type=>"TMMMichelinLanguage")
  end

  def calls_send_message(vendor, will_call_it)
    if will_call_it
      Sms.any_instance.stubs("send_#{vendor}_message".to_sym).returns(true)
    else
      Sms.any_instance.expects("send_#{vendor}_message".to_sym).never
    end
  end

  def sms_vendor_enabled(vendor, enabled_or_not)
    App.stubs("enable_#{vendor}").returns(enabled_or_not)
  end

  def create_qualifications(coach_id,language_max_unit_array)
    coach = Coach.find_by_id(coach_id)
    language_max_unit_array.each do |language_max_unit|
      coach.qualifications.create(:language_id => language_max_unit[:language],:max_unit => language_max_unit[:max_unit] )
    end
  end

  def create_coach_with_qualifications(coach = "newcoach", languages = ['ARA', 'CHI', 'ENG'], manager_id= nil)
    if created_coach = Account.find_by_user_name(coach)
       created_coach.update_attribute('type', 'Coach')
       created_coach.update_attribute('native_language', 'en-US')
    else
      created_coach = FactoryGirl.create(:coach, :user_name => coach, :full_name => coach, :rs_email => "#{coach}@rs.com", :lotus_qualified => true)
    end
     created_coach.update_attribute(:manager_id,manager_id) 
    FactoryGirl.create(:support_language) unless SupportLanguage.find_by_language_code(created_coach.native_language)
    languages.each do |language|
      l = Language.find_by_identifier(language)
      is_lotus = (language == 'KLE')
      is_aria = (language == "AUS" || language == "AUK")
      if is_lotus
        type = "ReflexLanguage"
      elsif is_aria
        type = "AriaLanguage"
      else
        type = "TotaleLanguage"
      end
      l = FactoryGirl.create(:language,:identifier => language,:type => type) unless l
      q = created_coach.qualification_for_language(l.id)
      FactoryGirl.create(:qualification, :language_id =>l.id,:coach_id => created_coach.id, :max_unit =>10) unless q 
    end
    created_coach
  end

  def create_recurring_session(coach,date,lang)
    c = coach.recurring_schedules.create(
      :coach_id => coach.id,
      :language_id => lang.id,
      :day_index => date.strftime('%w'),
      :start_time => date.strftime('%H:%M:%S'),
      :recurring_start_date => date,
      :created_at => Time.now.utc)
    c.save(:validate => false)#skipping validations to create for a past slot
    if(c.save(:validate => false)) # create a coach session if recurring schedules is created
      session = coach.coach_sessions.create(
        :coach_id => coach.id,
        :session_start_time => date,
        :language_identifier => lang.identifier,
        :created_at => date,
        :recurring_schedule_id => c.id
      )
      session.save(:validate => false)
    end
    return session
  end

  def create_one_off_session(coach, datetime, lang, ext_village_id = nil)
    session = coach.coach_sessions.create(
      :coach_id => coach.id,
      :session_start_time => datetime,
      :language_identifier => lang.identifier,
      :created_at => datetime,
      :external_village_id => ext_village_id
    )
    session.save(:validate => false)
    session
  end


  def create_recurring_schedule_without_session(coach,date,lang)
    c = coach.recurring_schedules.create(
      :coach_id => coach.id,
      :language_id => lang.id,
      :day_index => date.wday,
      :start_time => date.strftime("%T"),
      :recurring_start_date => date)
    c.save(:validate => false)#skipping validations to create for a past slot
  end

  def create_and_return_recurring_schedule_without_session(coach, date, lang = Language.find_by_identifier("KLE"))
    c = coach.recurring_schedules.create(
      :coach_id => coach.id,
      :language_id => lang.id,
      :day_index => date.strftime('%w'),
      :start_time => date.strftime('%H:%M:%S'),
      :recurring_start_date => date)
    c.save(:validate => false)#skipping validations to create for a past slot
    c
  end

  def create_and_return_scheduler_metadata(lang_identifier)
    FactoryGirl.create(:scheduler_metadata, :lang_identifier => lang_identifier )
  end

  def mock_now(time)
    Time.stubs('now').returns(time)
    assert_equal time, Time.now
  end

  def stub_eschool_call_for_profile_creation_with_success
    response = Net::HTTPOK.new(true,200,"OK")
    Eschool::Coach.stubs(:create_or_update_teacher_profile_with_multiple_qualifications).returns(response)
    read_body = '<?xml version="1.0" encoding="UTF-8"?> <response>   <status>OK</status>   <message>Successfully updated the profile in eSchool.</message> </response> '
    response.stubs(:read_body).returns(read_body)
  end

  def stub_eschool_call_for_profile_creation_with_error
    response = Net::HTTPOK.new(true,200,"OK")
    Eschool::Coach.stubs(:create_or_update_teacher_profile_with_multiple_qualifications).returns(response)
    read_body = '<?xml version="1.0" encoding="UTF-8"?> <response>   <status>ERROR</status>   <message>Profile could not be updated/created in eSchool.</message> </response> '
    response.stubs(:read_body).returns(read_body)
  end

  def stub_eschool_call_for_updating_wildcard_units_with_success
    response = Net::HTTPOK.new(true,200,"OK")
    ExternalHandler::HandleSession.stubs(:update_wildcard_units_for_eschool_sessions).returns(response)
    # Eschool::Session.stubs(:update_wildcard_units_for_eschool_sessions).returns(response)
    read_body = '<?xml version="1.0" encoding="UTF-8"?> <response>   <status>OK</status>   <message>Wild card units successfully updated for scheduled sessions in eSchool.</message> </response> '
    response.stubs(:read_body).returns(read_body)
  end

  def stub_eschool_call_for_updating_wildcard_units_with_not_all_wildcards_updated_error
    response = Net::HTTPOK.new(true,200,"OK")
    ExternalHandler::HandleSession.stubs(:update_wildcard_units_for_eschool_sessions).returns(response)
    # Eschool::Session.stubs(:update_wildcard_units_for_eschool_sessions).returns(response)
    read_body = '<?xml version="1.0" encoding="UTF-8"?> <response>   <status>ERROR</status>   <message>Wild card units failed to update for some of the scheduled sessions in eSchool.</message> </response> '
    response.stubs(:read_body).returns(read_body)
  end

  def stub_eschool_call_for_updating_wildcard_units_with_teacher_not_found_error
    response = Net::HTTPOK.new(true,200,"OK")
    ExternalHandler::HandleSession.stubs(:update_wildcard_units_for_eschool_sessions).returns(response)
    # Eschool::Session.stubs(:update_wildcard_units_for_eschool_sessions).returns(response)
    read_body = '<?xml version="1.0" encoding="UTF-8"?> <response>   <status>ERROR</status>   <message>Wild card units failed to update as teacher was not found in eSchool.</message> </response> '
    response.stubs(:read_body).returns(read_body)
  end

  def stub_eschool_call_for_creating_one_off_session
    response = Net::HTTPOK.new(true,200,"OK")
    ExternalHandler::HandleSession.stubs(:create_sessions).returns(response)
    # Eschool::Session.stubs(:create).returns(response)
    response.stubs(:read_body).returns(eschool_sessions_array_without_learner_body)
  end

  def stub_community_send_user_to_support_chat(message="OK")
    response = Net::HTTPOK.new(true,200,"OK")
    Community::SendUserToSupportChat.stubs(:send_user_to_support_chat).returns(response)
    body = "<response protocol_version='1'>   <message>#{message}</message> </response>"
    response.stubs(:read_body).returns(body)
  end

  def stub_eschool_set_has_technical_problem(resp="OK")
    response = Net::HTTPOK.new(true,200,"OK")
    ExternalHandler::HandleSession.stubs(:set_has_technical_problem).returns(response)
    # Eschool::Session.stubs(:set_has_technical_problem).returns(response)
    body = "<response protocol_version='1'>#{resp}</response>"
    response.stubs(:read_body).returns(body)
  end

  def stub_eschool_call_for_creating_one_off_session_with_custom_params(options)
    response = Net::HTTPOK.new(true,200,"OK")
    ExternalHandler::HandleSession.stubs(:create_sessions).returns(response)
    # Eschool::Session.stubs(:create).returns(response)
    response.stubs(:read_body).returns(eschool_sessions_array_without_learner_body_with_custom_params(options))
  end

  def stub_eschool_call_for_substituting_session_with_custom_params(options)
    response = Net::HTTPOK.new(true,200,"OK")
    ExternalHandler::HandleSession.stubs(:substitute_session).returns(response)
    # Eschool::Session.stubs(:substitute).returns(response)
    response.stubs(:read_body).returns(eschool_sessions_array_without_learner_body_with_custom_params(options))
  end

  def stub_eschool_call_for_bulk_create_sessions_with_custom_params(options)
    response = Net::HTTPOK.new(true,200,"OK")
    ExternalHandler::HandleSession.stubs(:create_sessions).returns(response)
    # Eschool::Session.stubs(:bulk_create_sessions).returns(response)
    response.stubs(:read_body).returns(eschool_sessions_array_without_learner_body_with_custom_params(options))
  end

  def stub_eschool_call_for_bulk_create_sessions_with_strictly_custom_params(options)
    response = Net::HTTPOK.new(true,200,"OK")
    ExternalHandler::HandleSession.stubs(:create_sessions).returns(response)
    # Eschool::Session.stubs(:bulk_create_sessions).returns(response)
    response.stubs(:read_body).returns(eschool_sessions_array_without_learner_body_with_strictly_custom_params(options))
  end

  def stub_eschool_call_for_bulk_edit_sessions_with_custom_params(options)
    response = Net::HTTPOK.new(true,200,"OK")
    ExternalHandler::HandleSession.stubs(:update_sessions).returns([options,response,""])
    # Eschool::Session.stubs(:bulk_edit_sessions).returns(response)
    response.stubs(:read_body).returns(eschool_sessions_array_without_learner_body_with_custom_params(options))
  end

  def stub_eschool_call_for_find_by_id(options)
    ExternalHandler::HandleSession.stubs(:find_session).returns(eschool_session_with_custom_params(options))
    # Eschool::Session.stubs(:find_by_id).returns(eschool_session_with_custom_params(options))
  end

  def stub_eschool_call_for_find_by_ids
    ExternalHandler::HandleSession.stubs(:find_sessions).returns(eschool_sessions_array_without_learner)
    # Eschool::Session.stubs(:find_by_ids).returns(eschool_sessions_array_without_learner)
  end

  def stub_eschool_call_for_coach_schedule
    ExternalHandler::HandleSession.stubs(:find_sessions).returns(eschool_sessions_array_for_coach_schedule)
    # Eschool::Session.stubs(:find_by_ids).returns(eschool_sessions_array_for_coach_schedule)
  end

  def stub_eschool_sub(options)
    ExternalHandler::HandleSession.stubs(:substitute_session).returns(eschool_session_with_custom_params(options))
    # Eschool::Session.stubs(:substitute).returns(eschool_session_with_custom_params(options))
  end

  def eschool_session_with_custom_params(options)
    session_xml_l = eschool_session_xml_with_custom_params(options)
    parse_session_xml_to_object(session_xml_l)
  end

  def eschool_session_xml_with_custom_params(options)
    session_xml_l = <<EOF
    <eschool_session>
      <eschool_session_id>#{options[:eschool_session_id]? options[:eschool_session_id] : 8494}</eschool_session_id>
      <language>#{options[:language]? options[:language] : "ESP"}</language>
      <level>#{options[:level]? options[:level] : "1"}</level>
      <unit>#{options[:unit]? options[:unit] : "1"}</unit>
      <lesson>#{options[:lesson]? options[:lesson] : "4"}</lesson>
      <teacher>#{options[:teacher]? options[:teacher] : "jramanathan"}</teacher>
      <teacher_id>#{options[:teacher_id]}</teacher_id>
      <start_time time_zone="UTC">#{options[:start_time]? options[:start_time] : "2011-01-21 10:00:00"}</start_time>
      <duration_in_seconds>3600</duration_in_seconds>
      <cancelled>#{options[:cancelled]? options[:cancelled] : "false"}</cancelled>
      <number_of_seats>#{options[:number_of_seats]? options[:number_of_seats] : 4}</number_of_seats>
      <learners_signed_up>#{options[:learners_signed_up]? options[:learners_signed_up] : "1"}</learners_signed_up>
      <students_attended>#{options[:students_attended]? options[:students_attended] : "0"}</students_attended>
      <wildcard>#{options[:wildcard]? options[:wildcard] : "true"}</wildcard>
      <wildcard_units>#{options[:wildcard_units]? options[:wildcard_units] : "1"}</wildcard_units>
      <wildcard_locked>#{options[:wildcard_locked]? options[:wildcard_locked] : "true"}</wildcard_locked>
      <teacher_confirmed>#{options[:teacher_confirmed]}</teacher_confirmed>
      <learner_details type = "array">
        <attendance>
          <student_email>1252005165313registration.com</student_email>
          <student_guid>13aaf8b0-9083-4ce0-84e9-f8af6a96ba72</student_guid>
          <student_attended>false</student_attended>
          <audio_input_device>#{options[:audio_input_device] || ''}</audio_input_device>
          <audio_output_device></audio_output_device>
          <first_name>Braga</first_name>
          <last_name>Braga</last_name>
          #{get_preferred_name_tag(options[:preferred_name])}
          <support_language_iso>#{options[:support_language_iso]}</support_language_iso>
          <audio_input_device_status>green</audio_input_device_status>
          <has_technical_problem>false</has_technical_problem>
          <user_agent>#{options[:user_agent]? options[:user_agent] : 'NA'}</user_agent>
        </attendance>
      </learner_details>
      <launch_session_url>
        javascript:launchOnline('http://studio.rosettastone.com/launch?app%5Bcancellation_grace_period_in_seconds%5D=3000&amp;app%5Bclass_definition_url%5D=rsus%3A%2F%2Feschool_en-US_U_01&amp;app%5Beschool_session_id%5D=8492&amp;app%5Bfull_name%5D=coach1&amp;app%5Binstruction_end_time%5D=2011-01-21T05%3A50%3A00-05%3A00&amp;app%5Blaunch_controller_mode%5D=teacher&amp;app%5Broom_password%5D=PoL1kad0ts&amp;app%5Broom_user_name%5D=cocomo-eschool-dev%40rosettastone.com&amp;app%5Bscheduler_api_endpoint%5D=http%3A%2F%2Fstudio.rosettastone.com%2Fapi%2F&amp;app%5Bseconds_before_end_to_show_countdown_timer%5D=300&amp;app%5Bskip_audio_setup%5D=false&amp;app%5Bstart_time%5D=2011-01-21T05%3A00%3A00-05%3A00&amp;app%5Bsystem_recommendations_url%5D=http%3A%2F%2Flaunch.rosettastone.com%2Fen%2Fsystem_recommendations%2Fcommunity&amp;app%5Bteacher_id%5D=182&amp;app%5Bteacher_picture_url%5D=http%3A%2F%2Feschool.rosettastone.com%2Fimages%2Fdefault_teacher_image.jpg&amp;app%5Btime_after_start_to_allow_cancellation_in_seconds%5D=36&amp;app%5Bvideo_quality%5D=100&amp;app%5Bweb_services_access_key%5D=248acbe6a91020199a9b5adb609468316eb3e14eba4c9d628b9625bc1ced0bbfd58b2e8996cab88d3fecd1d914a383ea71fc8cbc7c87c73781bce576609bbb5041765984d29cfa90069b1bb5ca8a98b171acd51d829662f32037062d823d20c80e2b549e6f03b097f3c127774ef015b496d2a7468a3d5802e836d8eaea3ee633')
      </launch_session_url>
      <average_attendance>0.0</average_attendance>
      <external_village_id>8</external_village_id>
    </eschool_session>
EOF
    session_xml_l
  end

  def eschool_sessions_array_without_learner_body
    session_xml_l = <<ESCHOOL_SESSION
    <?xml version='1.0' encoding='UTF-8'?>
<eschool_sessions type='array'>
      <eschool_session>
        <eschool_session_id>123456</eschool_session_id>
        <language>ARA</language>
        <level>1</level>
        <unit>1</unit>
        <lesson>4</lesson>
        <teacher>rramesh</teacher>
        <teacher_id>#{Account.find_by_user_name("rramesh").id}</teacher_id>
        <start_time time_zone="UTC">2025-06-13 12:00:00</start_time>
        <duration_in_seconds>3600</duration_in_seconds>
        <cancelled>false</cancelled>
        <number_of_seats>4</number_of_seats>
        <learners_signed_up>1</learners_signed_up>
        <students_attended>0</students_attended>
        <wildcard>true</wildcard>
        <wildcard_units>1,2,3,4,5,6,7,8,9,10,11,12</wildcard_units>
        <wildcard_locked>false</wildcard_locked>
        <teacher_confirmed>true</teacher_confirmed>
        <learner_details type="array">
        </learner_details>
        <launch_session_url>
          javascript:launchOnline('http://studio.rosettastone.com/launch?app%5Bcancellation_grace_period_in_seconds%5D=3000&amp;app%5Bclass_definition_url%5D=rsus%3A%2F%2Feschool_en-US_U_01&amp;app%5Beschool_session_id%5D=8492&amp;app%5Bfull_name%5D=coach1&amp;app%5Binstruction_end_time%5D=2011-01-21T05%3A50%3A00-05%3A00&amp;app%5Blaunch_controller_mode%5D=teacher&amp;app%5Broom_password%5D=PoL1kad0ts&amp;app%5Broom_user_name%5D=cocomo-eschool-dev%40rosettastone.com&amp;app%5Bscheduler_api_endpoint%5D=http%3A%2F%2Fstudio.rosettastone.com%2Fapi%2F&amp;app%5Bseconds_before_end_to_show_countdown_timer%5D=300&amp;app%5Bskip_audio_setup%5D=false&amp;app%5Bstart_time%5D=2011-01-21T05%3A00%3A00-05%3A00&amp;app%5Bsystem_recommendations_url%5D=http%3A%2F%2Flaunch.rosettastone.com%2Fen%2Fsystem_recommendations%2Fcommunity&amp;app%5Bteacher_id%5D=182&amp;app%5Bteacher_picture_url%5D=http%3A%2F%2Feschool.rosettastone.com%2Fimages%2Fdefault_teacher_image.jpg&amp;app%5Btime_after_start_to_allow_cancellation_in_seconds%5D=36&amp;app%5Bvideo_quality%5D=100&amp;app%5Bweb_services_access_key%5D=248acbe6a91020199a9b5adb609468316eb3e14eba4c9d628b9625bc1ced0bbfd58b2e8996cab88d3fecd1d914a383ea71fc8cbc7c87c73781bce576609bbb5041765984d29cfa90069b1bb5ca8a98b171acd51d829662f32037062d823d20c80e2b549e6f03b097f3c127774ef015b496d2a7468a3d5802e836d8eaea3ee633')
        </launch_session_url>
        <average_attendance>0.0</average_attendance>
        <external_village_id>8</external_village_id>
      </eschool_session>
   </eschool_sessions>
ESCHOOL_SESSION
 session_xml_l.lstrip
  end

  def eschool_sessions_array_without_learner_body_with_custom_params(options)
    <<ESCHOOL_SESSION
    <?xml version='1.0' encoding='UTF-8'?>
<eschool_sessions type='array'>
      <eschool_session>
        <eschool_session_id>#{options[:eschool_session_id]? options[:eschool_session_id] : 12356}</eschool_session_id>
        <language>ARA</language>
        <level>1</level>
        <unit>1</unit>
        <lesson>4</lesson>
        <teacher>#{options[:teacher]? options[:teacher] : "rramesh"}</teacher>
        <teacher_id>#{options[:teacher_id]? options[:teacher_id] : Account.find_by_user_name("rramesh").id}</teacher_id>
        <start_time time_zone="UTC">#{options[:start_time]? options[:start_time] :"2025-06-13 12:00:00"}</start_time>
        <duration_in_seconds>3600</duration_in_seconds>
        <cancelled>false</cancelled>
        <number_of_seats>4</number_of_seats>
        <learners_signed_up>#{options[:learners_signed_up]? options[:learners_signed_up] : 1}</learners_signed_up>
        <students_attended>0</students_attended>
        <wildcard>#{options[:wildcard]? options[:wildcard] : true}</wildcard>
        <wildcard_units>1,2,3,4,5,6,7,8,9,10,11,12</wildcard_units>
        <wildcard_locked>false</wildcard_locked>
        <teacher_confirmed>true</teacher_confirmed>
        <learner_details type="array">
        </learner_details>
        <launch_session_url>
          javascript:launchOnline('http://studio.rosettastone.com/launch?app%5Bcancellation_grace_period_in_seconds%5D=3000&amp;app%5Bclass_definition_url%5D=rsus%3A%2F%2Feschool_en-US_U_01&amp;app%5Beschool_session_id%5D=8492&amp;app%5Bfull_name%5D=coach1&amp;app%5Binstruction_end_time%5D=2011-01-21T05%3A50%3A00-05%3A00&amp;app%5Blaunch_controller_mode%5D=teacher&amp;app%5Broom_password%5D=PoL1kad0ts&amp;app%5Broom_user_name%5D=cocomo-eschool-dev%40rosettastone.com&amp;app%5Bscheduler_api_endpoint%5D=http%3A%2F%2Fstudio.rosettastone.com%2Fapi%2F&amp;app%5Bseconds_before_end_to_show_countdown_timer%5D=300&amp;app%5Bskip_audio_setup%5D=false&amp;app%5Bstart_time%5D=2011-01-21T05%3A00%3A00-05%3A00&amp;app%5Bsystem_recommendations_url%5D=http%3A%2F%2Flaunch.rosettastone.com%2Fen%2Fsystem_recommendations%2Fcommunity&amp;app%5Bteacher_id%5D=182&amp;app%5Bteacher_picture_url%5D=http%3A%2F%2Feschool.rosettastone.com%2Fimages%2Fdefault_teacher_image.jpg&amp;app%5Btime_after_start_to_allow_cancellation_in_seconds%5D=36&amp;app%5Bvideo_quality%5D=100&amp;app%5Bweb_services_access_key%5D=248acbe6a91020199a9b5adb609468316eb3e14eba4c9d628b9625bc1ced0bbfd58b2e8996cab88d3fecd1d914a383ea71fc8cbc7c87c73781bce576609bbb5041765984d29cfa90069b1bb5ca8a98b171acd51d829662f32037062d823d20c80e2b549e6f03b097f3c127774ef015b496d2a7468a3d5802e836d8eaea3ee633')
        </launch_session_url>
        <average_attendance>0.0</average_attendance>
        <external_village_id>8</external_village_id>
      </eschool_session>
   </eschool_sessions>
ESCHOOL_SESSION
  end

    def eschool_sessions_array_without_learner_body_with_strictly_custom_params(options)
    <<ESCHOOL_SESSION
    <?xml version='1.0' encoding='UTF-8'?>
<eschool_sessions type='array'>
      <eschool_session>
        <eschool_session_id>#{options[:eschool_session_id]}</eschool_session_id>
        <language>ARA</language>
        <level>1</level>
        <unit>1</unit>
        <lesson>4</lesson>
        <teacher>#{options[:teacher]}</teacher>
        <teacher_id>#{options[:teacher_id]}</teacher_id>
        <start_time time_zone="UTC">#{options[:start_time]}</start_time>
        <duration_in_seconds>3600</duration_in_seconds>
        <cancelled>false</cancelled>
        <number_of_seats>4</number_of_seats>
        <learners_signed_up>1</learners_signed_up>
        <students_attended>0</students_attended>
        <wildcard>true</wildcard>
        <wildcard_units>1,2,3,4,5,6,7,8,9,10,11,12</wildcard_units>
        <wildcard_locked>false</wildcard_locked>
        <teacher_confirmed>true</teacher_confirmed>
        <learner_details type="array">
        </learner_details>
        <launch_session_url>
          javascript:launchOnline('http://studio.rosettastone.com/launch?app%5Bcancellation_grace_period_in_seconds%5D=3000&amp;app%5Bclass_definition_url%5D=rsus%3A%2F%2Feschool_en-US_U_01&amp;app%5Beschool_session_id%5D=8492&amp;app%5Bfull_name%5D=coach1&amp;app%5Binstruction_end_time%5D=2011-01-21T05%3A50%3A00-05%3A00&amp;app%5Blaunch_controller_mode%5D=teacher&amp;app%5Broom_password%5D=PoL1kad0ts&amp;app%5Broom_user_name%5D=cocomo-eschool-dev%40rosettastone.com&amp;app%5Bscheduler_api_endpoint%5D=http%3A%2F%2Fstudio.rosettastone.com%2Fapi%2F&amp;app%5Bseconds_before_end_to_show_countdown_timer%5D=300&amp;app%5Bskip_audio_setup%5D=false&amp;app%5Bstart_time%5D=2011-01-21T05%3A00%3A00-05%3A00&amp;app%5Bsystem_recommendations_url%5D=http%3A%2F%2Flaunch.rosettastone.com%2Fen%2Fsystem_recommendations%2Fcommunity&amp;app%5Bteacher_id%5D=182&amp;app%5Bteacher_picture_url%5D=http%3A%2F%2Feschool.rosettastone.com%2Fimages%2Fdefault_teacher_image.jpg&amp;app%5Btime_after_start_to_allow_cancellation_in_seconds%5D=36&amp;app%5Bvideo_quality%5D=100&amp;app%5Bweb_services_access_key%5D=248acbe6a91020199a9b5adb609468316eb3e14eba4c9d628b9625bc1ced0bbfd58b2e8996cab88d3fecd1d914a383ea71fc8cbc7c87c73781bce576609bbb5041765984d29cfa90069b1bb5ca8a98b171acd51d829662f32037062d823d20c80e2b549e6f03b097f3c127774ef015b496d2a7468a3d5802e836d8eaea3ee633')
        </launch_session_url>
        <average_attendance>0.0</average_attendance>
        <external_village_id>8</external_village_id>
      </eschool_session>
   </eschool_sessions>
ESCHOOL_SESSION
  end

  def stub_ldap_authentication_for_coach(user_assigned = nil)
    user = user_assigned ? user_assigned : login_as_custom_user(AdGroup.coach, 'coach')
    User.stubs(:authenticate).returns user #Simulate a success authentication
    Coach.any_instance.stubs(:qualifications).returns [Qualification.first]
  end

  def stub_ldap_authentication_for_coach_manager
    user = login_as_custom_user(AdGroup.coach_manager, 'coachman')
    User.stubs(:authenticate).returns @request.session[:user] #Simulate a success authentication
  end

  def stub_ldap_authentication_for_support_user
    user = login_as_custom_user(AdGroup.support_user, 'supportUser')
    User.stubs(:authenticate).returns @request.session[:user] #Simulate a success authentication
  end

  def stub_ldap_authentication_for_support_lead
    user = login_as_custom_user(AdGroup.support_lead, 'supportLead')
    User.stubs(:authenticate).returns @request.session[:user] #Simulate a success authentication
  end
  def create_recurring_schedule_without_session(coach,date,lang)
    c = coach.recurring_schedules.create(
      :coach_id => coach.id,
      :language_id => lang.id,
      :day_index => date.strftime('%w'),
      :start_time => date.strftime('%H:%M:%S'),
      :recurring_start_date => date)
    c.save(:validate => false)#skipping validations to create for a past slot
  end

  def learner_studio_history_without_sessions(options)
    leaner_xml_l = <<LEARNER
  <learner>
    <guid> #{ options[:guid] ? options[:guid] : "9d9d0609-5701-4f35-9fdb-9c8c1022293c"}</guid>
    <time_zone>#{ options[:time_zone] ? options[:time_zone] : "Central Time (US &amp; Canada)"}</time_zone>
    <eschool_sessions type="array">
    </eschool_sessions>
  </learner>
LEARNER
    parse_xml_to_leaner_object(leaner_xml_l)
  end

  def learner_studio_history_with_one_session_no_feedback(options)
    leaner_xml_l = <<LEARNER
  <learner>
    <guid>#{options[:guid] ? options[:guid] : "9d9d0609-5701-4f35-9fdb-9c8c1022293c"}</guid>
    <time_zone>#{options[:time_zone] ? options[:time_zone] : "Central Time (US &amp; Canada)"}</time_zone>
    <eschool_sessions type="array">
      <eschool_session>
        <language_code>#{options[:language_code] ? options[:language_code] : "ESP"}</language_code>
        <coach_id>#{options[:coach] ? options[:coach].id : accounts(:ARA_scheduled_coach).id}</coach_id>
        <coach>#{options[:coach] ? options[:coach].full_name : accounts(:ARA_scheduled_coach).full_name}</coach>
        <last_seen_at>#{options[:datetime] ? options[:datetime] + 50.minutes : "2011-11-01 06:50:06 -0400"}</last_seen_at>
        <first_seen_at>#{options[:datetime] ? options[:datetime] + 2.minutes : "2011-11-01 06:02:06 -0400"}</first_seen_at>
        <level>"4"</level>
        <unit>"2"</unit>
        <lesson>4</lesson>
        <attended> true </attended>
        <cancelled>#{options[:canceled] ? options[:canceled] : false}</cancelled>
        <technical_issues>#{options[:technical_issues] ? options[:technical_issues] : false}</technical_issues>
        <start_time>#{options[:datetime] ? options[:datetime] : "2011-11-01 06:00:00 -0400" }</start_time>
      <feedbacks type ="array">
      </feedbacks>
      </eschool_session>
    </eschool_sessions>
  </learner>
LEARNER
    parse_xml_to_leaner_object(leaner_xml_l)
  end

  def learner_studio_history_with_one_session_and_feedback(options)
    leaner_xml_l = <<LEARNER
  <learner>
    <guid>#{options[:guid] ? options[:guid] : "9d9d0609-5701-4f35-9fdb-9c8c1022293c"}</guid>
    <time_zone>#{options[:time_zone] ? options[:time_zone] : "Central Time (US &amp; Canada)"}</time_zone>
    <eschool_sessions type="array">
      <eschool_session>
        <language_code>#{options[:language_code] ? options[:language_code] : "ESP"}</language_code>
        <coach_id>#{options[:coach] ? options[:coach].id : accounts(:ARA_scheduled_coach).id}</coach_id>
        <coach>#{options[:coach] ? options[:coach].full_name : accounts(:ARA_scheduled_coach).full_name}</coach>
        <last_seen_at>#{options[:datetime] ? options[:datetime] + 50.minutes : "2011-11-01 06:50:06 -0400"}</last_seen_at>
        <first_seen_at>#{options[:datetime] ? options[:datetime] + 2.minutes : "2011-11-01 06:02:06 -0400"}</first_seen_at>
        <level>"4"</level>
        <unit>"2"</unit>
        <lesson>4</lesson>
        <attended> true </attended>
        <cancelled>#{options[:canceled] ? options[:canceled] : false}</cancelled>
        <technical_issues>#{options[:technical_issues] ? options[:technical_issues] : false}</technical_issues>
        <start_time>#{options[:datetime] ? options[:datetime] : "2011-11-01 06:00:00 -0400" }</start_time>
        <feedbacks type ="array">
          <feedback>
              <label>Overall comments or recommendations for the learner</label>
              <value>n/a</value>
              <score>4</score>
              <notes>Very good learner!</notes>
            </feedback>
            <feedback>
              <label>Should we follow up with this Learner?</label>
              <value>NO</value>
              <score>n/a</score>
              <notes></notes>
            </feedback>
            <feedback>
              <label>Preparation</label>
              <value>n/a</value>
              <score>4</score>
              <notes></notes>
            </feedback>
            <feedback>
              <label>Participation</label>
              <value>n/a</value>
              <score>4</score>
              <notes></notes>
            </feedback>
            <feedback>
              <label>Comprehension</label>
              <value>n/a</value>
              <score>4</score>
              <notes></notes>
            </feedback>
             <feedback>
              <label>Production</label>
              <score>4</score>
              <value>n/a</value>
              <notes></notes>
            </feedback>
        </feedbacks>
      </eschool_session>
    </eschool_sessions>
  </learner>
LEARNER
    parse_xml_to_leaner_object(leaner_xml_l)
  end

  def get_preferred_name_tag(preferred_name)
    preferred_name.blank? ? "" : ("<preferred_name>" + preferred_name + "</preferred_name>")
  end

  def create_substituion_within(time, language = "KLE")
    CoachSession.any_instance.stubs(:eschool_session).returns nil
    CoachSession.any_instance.stubs(:send_email_to_coaches_and_coach_managers).returns nil # Since this method is called as a separate thread, this method has to be stubbed
    sample_coach = Coach.first
    sample_coach = FactoryGirl.create(:account, :type => 'Coach') if sample_coach.nil?
    coach_session_in_x_hr = FactoryGirl.create(:coach_session, :coach_id => nil, :session_start_time => TimeUtils.current_slot + time, :language_identifier => language, :eschool_session_id => get_unique_eschool_session_id,:type => "ConfirmedSession")
    FactoryGirl.create(:substitution, :grabber_coach_id => nil, :grabbed=>0, :cancelled=>0, :coach_session_id => coach_session_in_x_hr.id, :coach_id => sample_coach.id)
  end

  def get_unique_eschool_session_id
    begin
      eschool_session_id = SubSequence.next
      return eschool_session_id if CoachSession.find_by_eschool_session_id(eschool_session_id).nil?
    end while true
  end
  
end
