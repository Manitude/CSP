require File.join(File.dirname(__FILE__), 'test_helper')

class BafflingApiClientTest < Test::Unit::TestCase

  def test_ping
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(ping_xml).once
    ping_resp = RosettaStone::Baffling::ApiClient.new.ping
    assert_equal({"status" => "200"}, ping_resp)
  end

  def test_details_with_bad_guid
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(unknown_guid_exception_response).once
    assert_raises(RosettaStone::Baffling::UnknownGuidException) do
      RosettaStone::Baffling::ApiClient.new.details('123', 'FRA')
    end
  end

  def test_simple_http_errors_translated_to_baffling_api_client_exception
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).raises(SimpleHTTP::ApiClient::ApiClientError)

    assert_raises(RosettaStone::Baffling::ApiClientError) do
      RosettaStone::Baffling::ApiClient.new.details('123', 'FRA')
    end
  end

  def test_unrecognized_errors_translated_to_baffling_api_client_exception
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(crazy_exception_response).once

    assert_raises(RosettaStone::Baffling::ApiClientError) do
      RosettaStone::Baffling::ApiClient.new.details('123', 'FRA')
    end
  end

  def test_path_scores_for_language_and_level_with_missing_language
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(missing_language_exception_response).once
    assert_raises(RosettaStone::Baffling::MissingLanguageException) do
      RosettaStone::Baffling::ApiClient.new.path_scores_for_language_and_level('123', 'FRA', 3)
    end
  end

  def test_user_game_history
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(user_game_history_xml).once
    user_game_history_xml_response = RosettaStone::Baffling::ApiClient.new.user_game_history('123')
    assert_equal(expected_user_game_history_response, user_game_history_xml_response)
  end

  def test_user_interactions
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(user_interactions_xml).once
    user_interactions_xml_response = RosettaStone::Baffling::ApiClient.new.user_interactions('123')
    assert_equal(expected_user_interactions_response, user_interactions_xml_response)
  end

  def test_chat_history
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(chat_history_xml).once
    chat_history_xml_response = RosettaStone::Baffling::ApiClient.new.chat_history('123')
    assert_equal(expected_chat_history_response, chat_history_xml_response)
  end

  def test_user_invite_history
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(user_invite_history_xml).once
    user_invite_history_xml_response = RosettaStone::Baffling::ApiClient.new.user_invite_history('123')
    assert_equal(expected_user_invite_historyy_response, user_invite_history_xml_response)
  end

  def test_acquaintances_with_no_acquaintances
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(user_xml(0)).once
    acquaintances = RosettaStone::Baffling::ApiClient.new.acquaintances('123')
    assert_equal([], acquaintances)
  end

  def test_acquantainces_with_bad_guid_returns_an_empty_array_despite_exception_from_server
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(unknown_guid_exception_response).once
    result = RosettaStone::Baffling::ApiClient.new.acquaintances('123')
    assert_equal [], result
  end

  def test_acquaintances_with_one_acquaintance
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(user_xml(1)).once
    acquaintances = RosettaStone::Baffling::ApiClient.new.acquaintances('123')
    assert_equal(user_array(1), acquaintances)
  end

  def test_acquaintances_with_two_acquaintances
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(user_xml(2)).once
    acquaintances = RosettaStone::Baffling::ApiClient.new.acquaintances('123')
    assert_equal(user_array(2), acquaintances)
  end

  def test_acquaintances_with_fitty_acquaintances
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(user_xml(50)).once
    acquaintances = RosettaStone::Baffling::ApiClient.new.acquaintances('123')
    assert_equal(user_array(50), acquaintances)
  end

  def test_acquaintances_with_crappy_xml_returned_three_times
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(broken_exception_response).times(3)
    assert_raises(RosettaStone::Baffling::UnableToParseExceptionDetailsException) do
      RosettaStone::Baffling::ApiClient.new.acquaintances('123')
    end
  end

  def test_acquaintances_with_crappy_xml_once_then_good_xml
    RosettaStone::Baffling::ApiClient.any_instance.stubs(:request_with_retry).returns(broken_exception_response).then.returns(user_xml(1))
    acquaintances = RosettaStone::Baffling::ApiClient.new.acquaintances('123')
    assert_equal(user_array(1), acquaintances)
  end

  def test_time_on_languages_with_two_languages
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(time_spent_on_languages_xml).once
    time_spent_on_languages_xml_response = RosettaStone::Baffling::ApiClient.new.time_spent_on_languages('123')
    assert_equal(expected_time_spent_on_languages_response, time_spent_on_languages_xml_response)
  end

  def test_recently_modified_profiles
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(recently_modified_profiles_xml).once
    recently_modified_profiles_xml_response = RosettaStone::Baffling::ApiClient.new.recently_modified_profiles('2009-08-09 01:11:49', '2009-08-15 16:11:49', true, true)
    assert_equal(expected_recently_modified_profiles_response, recently_modified_profiles_xml_response)
  end

  def test_recently_expired_or_created_licenses_with_multiple_license_response
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(recently_expired_or_created_licenses_xml_with_multiple_license_responses).once
    recently_expired_or_created_licenses_xml_response = RosettaStone::Baffling::ApiClient.new.recently_expired_or_created_licenses('2009-10-08 00:00:00', '2009-10-20 00:00:00')
    assert_equal(expected_recently_expired_or_created_licenses_with_multiple_response, recently_expired_or_created_licenses_xml_response)
  end

  #To test if we always get the identifiers as an array even if a single identifier comes in
  def test_recently_expired_or_created_licenses_with_single_license_response
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(recently_expired_or_created_licenses_xml_with_single_license_responses).once
    recently_expired_or_created_licenses_xml_response = RosettaStone::Baffling::ApiClient.new.recently_expired_or_created_licenses('2009-10-08 00:00:00', '2009-10-20 00:00:00')
    assert_equal(expected_recently_expired_or_created_licenses_with_single_response, recently_expired_or_created_licenses_xml_response)
  end

  def test_recently_expired_or_created_licenses_with_no_response
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(recently_expired_or_created_licenses_xml_with_no_license_responses).once
    recently_expired_or_created_licenses_xml_response = RosettaStone::Baffling::ApiClient.new.recently_expired_or_created_licenses('2009-10-08 00:00:00', '2009-10-20 00:00:00')
    assert_equal(expected_recently_expired_or_created_licenses_with_no_response, recently_expired_or_created_licenses_xml_response)
  end

  def test_recently_updated_license_identifiers_with_multiple_guid_response
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(recently_updated_license_identifiers_xml_with_multiple_license_responses).once
    recently_updated_license_identifiers_xml_response = RosettaStone::Baffling::ApiClient.new.recently_updated_license_identifiers('3')
    assert_equal(expected_recently_updated_license_identifiers_with_multiple_response, recently_updated_license_identifiers_xml_response)
  end

  def test_recently_updated_license_identifiers_with_single_guid_response
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(recently_updated_license_identifiers_xml_with_single_license_responses).once
    recently_updated_license_identifiers_xml_response = RosettaStone::Baffling::ApiClient.new.recently_updated_license_identifiers('3')
    assert_equal(expected_recently_updated_license_identifiers_with_single_response, recently_updated_license_identifiers_xml_response)
  end

  def test_recently_updated_license_identifiers_with_no_response
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(recently_updated_license_identifiers_xml_with_no_license_responses).once
    recently_updated_license_identifiers_xml_response = RosettaStone::Baffling::ApiClient.new.recently_updated_license_identifiers('3')
    assert_equal(expected_recently_updated_license_identifiers_with_no_response, recently_updated_license_identifiers_xml_response)
  end

  def test_studio_ping_times_summaries
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(studio_ping_time_summaries_xml).once
    studio_ping_time_summaries_response = RosettaStone::Baffling::ApiClient.new.studio_ping_times_summaries(1,'student', [1])
    assert_equal(expected_studio_ping_time_summaries_response, studio_ping_time_summaries_response)
  end

  def test_studio_ping_time_summaries_for_eschool_session
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(studio_ping_time_summaries_xml).once
    studio_ping_time_summaries_response = RosettaStone::Baffling::ApiClient.new.studio_ping_times_summaries_for_eschool_session(1,[1])
    assert_equal(expected_studio_ping_time_summaries_response, studio_ping_time_summaries_response)
  end

  def test_community_learner_signin_history_with_multiple_response
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(community_learner_signin_history_xml_with_multiple_responses).once
    community_learner_signin_history_xml_response = RosettaStone::Baffling::ApiClient.new.community_learner_signin_history("funny_guid")
    assert_equal(expected_community_learner_signin_history_with_multiple_response, community_learner_signin_history_xml_response)
  end

  def test_community_learner_signin_history_with_single_response
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(community_learner_signin_history_xml_with_single_response).once
    community_learner_signin_history_xml_response = RosettaStone::Baffling::ApiClient.new.community_learner_signin_history("funny_guid")
    assert_equal(expected_community_learner_signin_history_with_single_response, community_learner_signin_history_xml_response)
  end

  def test_community_learner_signin_history_with_no_response
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(community_learner_signin_history_xml_with_no_response).once
    community_learner_signin_history_xml_response = RosettaStone::Baffling::ApiClient.new.community_learner_signin_history("funny_guid")
    assert_equal(expected_community_learner_signin_history_with_no_response, community_learner_signin_history_xml_response)
  end

  def test_community_user_roles_with_no_response
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(community_user_roles_xml_with_no_response).once
    community_user_roles_xml_response = RosettaStone::Baffling::ApiClient.new.community_user_roles('123')
    assert_equal(expected_community_user_roles_with_no_response, community_user_roles_xml_response)
  end

  def test_community_user_roles_with_single_response
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(community_user_roles_xml_with_single_response).once
    community_user_roles_xml_response = RosettaStone::Baffling::ApiClient.new.community_user_roles('123')
    assert_equal(expected_community_user_roles_with_single_response, community_user_roles_xml_response)
  end

  def test_community_user_roles_with_multiple_response
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(community_user_roles_xml_with_multiple_response).once
    community_user_roles_xml_response = RosettaStone::Baffling::ApiClient.new.community_user_roles('123')
    assert_equal(expected_community_user_roles_with_multiple_response, community_user_roles_xml_response)
  end

  def test_community_user_badges_with_multiple_badge_response
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(community_user_badges_xml_with_multiple_badge_response).once
    community_user_badge_xml_response = RosettaStone::Baffling::ApiClient.new.community_user_badges('123')
    assert_equal(expected_community_user_badges_with_multiple_badge_response, community_user_badge_xml_response)
  end

  def test_community_user_badges_with_single_badge_response
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(community_user_badges_xml_with_single_badge_response).once
    community_user_badge_xml_response = RosettaStone::Baffling::ApiClient.new.community_user_badges('123')
    assert_equal(expected_community_user_badges_with_single_badge_response, community_user_badge_xml_response)
  end

  def test_community_user_badges_with_zero_badge_response
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(community_user_badges_xml_with_zero_badge_response).once
    community_user_badge_xml_response = RosettaStone::Baffling::ApiClient.new.community_user_badges('123')
    assert_equal([], community_user_badge_xml_response)
  end

  def test_community_learner_audit_log_with_zero_log_entries
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(community_learner_audit_log_xml_with_zero_log_entries_response).once
    community_learner_audit_log_xml_response = RosettaStone::Baffling::ApiClient.new.community_learner_audit_logs('123')
    assert_equal(expected_community_learner_audit_log_with_zero_entries_response, community_learner_audit_log_xml_response)
  end

  def test_community_learner_audit_log_with_single_log_entry
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(community_learner_audit_log_xml_with_single_log_entry_response).once
    community_learner_audit_log_xml_response = RosettaStone::Baffling::ApiClient.new.community_learner_audit_logs('123')
    assert_equal(expected_community_learner_audit_log_with_single_entry_response, community_learner_audit_log_xml_response)
  end

  def test_community_learner_audit_log_with_multiple_log_entries
    RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(community_learner_audit_log_xml_with_multiple_log_entries_response).once
    community_learner_audit_log_xml_response = RosettaStone::Baffling::ApiClient.new.community_learner_audit_logs('123')
    assert_equal(expected_community_learner_audit_log_with_multiple_entries_response, community_learner_audit_log_xml_response)
  end

  ["multiple", "single", "zero"].each do |response_count|
    define_method "test_social_app_languages_with_#{response_count}_language_response" do
      RosettaStone::Baffling::ApiClient.any_instance.expects(:request_with_retry).returns(send("social_app_languages_xml_with_#{response_count}_response")).once
      community_learner_audit_log_xml_response = RosettaStone::Baffling::ApiClient.new.social_app_languages('123')
      assert_equal(send("expected_social_app_language_with_#{response_count}_response"), community_learner_audit_log_xml_response)
    end
  end

  private

  def ping_xml
    body = '<baffler_ping><status>200</status></baffler_ping>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def user_xml(count)
    body = '<users>'
    count.times do
      body += ' <user>
          <guid>ba4f3565-b208-4915-bc9b-2defcbe645c0</guid>
          <score>45</score>
        </user>'
    end
    body += '</users>'

    OpenStruct.new({"status" => '200', "body" => body})
  end

  def studio_ping_time_summaries_xml
    body = %Q{
      <studio_ping_times_summaries min_minimum="10" max_minimum="10" min_maximum="14" max_maximum="14" average="12.34" ping_count="25">
        <studio_ping_time_summary>
          <eschool_session_id>1</eschool_session_id>
          <average>12.34</average>
          <minimum>10</minimum>
          <maximum>14</maximum>
          <user_type>student</user_type>
          <user_id>1</user_id>
          <ping_count>25</ping_count>
        </studio_ping_time_summary>
      </studio_ping_times_summaries>
    }
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def expected_studio_ping_time_summaries_response
    {
      "min_maximum"=>"14",
      "max_maximum"=>"14",
      "average"=>"12.34",
      "min_minimum"=>"10",
      "max_minimum"=>"10",
      "ping_count"=>"25",
      "studio_ping_time_summary"=>[{
          "maximum"=>"14",
          "ping_count"=>"25",
          "user_type"=>"student",
          "user_id"=>"1",
          "minimum"=>"10",
          "average"=>"12.34",
          "eschool_session_id"=>"1"
        }
      ]
    }
  end
  
  def user_array(count)
    [OpenStruct.new({:score => '45', :guid => 'ba4f3565-b208-4915-bc9b-2defcbe645c0'})]*count
  end

  def user_game_history_xml
    body =
      '<user_game_history>
          <user>
            <guid>f819c05e-1d18-460e-9074-a60b67811a90</guid>
          </user>
          <game_history>
            <participation>
              <gameplay_start_at>1260827347</gameplay_start_at>
              <gameplay_ended_at>1260827369</gameplay_ended_at>
              <invitation_uid>17612248_1260827315677</invitation_uid>
              <game_name>guess_what</game_name>
              <game_version>0.0.0-76731</game_version>
              <game_modality>duo</game_modality>
              <created_at>1260827317</created_at>
              <partner_guid>6dc05fab-d760-4754-acdf-dd4387d9c8b2</partner_guid>
            </participation>
         </game_history>
       </user_game_history>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def user_interactions_xml
    body = 
    '<interactions user_guid="73440009-77d9-4793-8987-2bc1543e69d8">
      <interaction>
        <partner>
          <user_guid>e52a0cd5-a823-4547-8506-189c36710ac2</user_guid>
          <email>tester_1@games.rs</email>
          <preferred_name>Lewis</preferred_name>
          <gender>male</gender>
        </partner>
        <interaction_id>288929</interaction_id>
        <interaction_type>SocialAppInteractionSummary</interaction_type>
        <interaction_count>6</interaction_count>
        <last_interaction_at>1279572929</last_interaction_at>
      </interaction>
    </interactions>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def chat_history_xml
    body =
    '<user_chat_logs>
      <pagination>
        <current_page>1</current_page>
        <total_pages>1</total_pages>
      </pagination>
      <conversation>
        <identifier>324</identifier>
        <type>JabberConversation</type>
        <started_at>0</started_at>
        <conversational_partner>b4dcc6f0-0fdd-47b1-bbe1-5c58e7dd3710</conversational_partner>
        <messages>
          <message>
            <message_text>kdskjakdk</message_text>
            <message_time>1260481265</message_time>
            <sender>21a2ce57-2fdd-47eb-b9b9-873ffacc2a62</sender>
          </message>
        </messages>
      </conversation>
     </user_chat_logs>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def user_invite_history_xml
    body =
    '<user_invitation_history>
      <pagination>
        <current_page>1</current_page>
        <total_pages>1</total_pages>
      </pagination>
      <invitation>
        <created_at>1285782843</created_at>
        <invitation_status>Extended</invitation_status>
        <invitation_uid>496_1285782841881</invitation_uid>
        <game_name>find_the_differences</game_name>
        <game_version>0.0.0-103091</game_version>
        <game_modality>simbio</game_modality>
        </invitation>
     </user_invitation_history>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def time_spent_on_languages_xml
    body = '<languages>
     <language>
        <language_code>ESP</language_code>
        <time_spent>331</time_spent>
      </language>
      <language>
        <language_code>ITA</language_code>
        <time_spent>37</time_spent>
      </language>
    </languages>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def community_user_roles_xml_with_no_response
    body = '<community_user>
    </community_user>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def community_user_roles_xml_with_single_response
    body = '<community_user>
      <role>
        <role_name>software dev</role_name>
        <description>gets 20 badges on sign in.</description>
      </role>
    </community_user>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def community_user_roles_xml_with_multiple_response
    body = '<community_user>
      <role>
        <role_name>Content Reviewer</role_name>
        <description>Ability to review content</description>
      </role>
      <role>
        <role_name>software dev</role_name>
        <description>gets 20 badges on sign in.</description>
      </role>
    </community_user>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def recently_modified_profiles_xml
    body = '<profiles>
    <user>
      <guid>ecb2d32e-f60a-43f6-a7d5-92d42bb31ed2</guid>
      <community_id>343</community_id>
      <email>johndoe@rosettastone.com</email>
      <first_name>John</first_name>
      <last_name>Doe</last_name>
      <preferred_name>JayDee</preferred_name>
      <city></city>
      <state_province></state_province>
      <created_at time_zone= "UTC">Mon Jul 20 15:01:19</created_at>
      <updated_at time_zone= "UTC">Mon Aug 10 16:11:49</updated_at>
    </user>
  </profiles>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def expected_user_game_history_response
    {"game_history"=>
        {"participation"=>
          {"gameplay_start_at"=>"1260827347",
           "created_at"=>"1260827317",
           "invitation_uid"=>"17612248_1260827315677",
           "game_version"=>"0.0.0-76731",
           "game_name"=>"guess_what",
           "partner_guid"=>"6dc05fab-d760-4754-acdf-dd4387d9c8b2",
           "game_modality"=>"duo",
           "gameplay_ended_at"=>"1260827369"}
        },"user"=>{
           "guid"=>"f819c05e-1d18-460e-9074-a60b67811a90"
        }
    }
  end

  def expected_user_interactions_response
    {"interaction"=>
        {"last_interaction_at"=>
          "1279572929",
          "interaction_count"=>"6",
          "interaction_type"=>"SocialAppInteractionSummary",
          "interaction_id"=>"288929",
          "partner"=>
            {"preferred_name"=>"Lewis",
             "gender"=>"male",
             "user_guid"=>"e52a0cd5-a823-4547-8506-189c36710ac2",
             "email"=>"tester_1@games.rs"
            }
         },"user_guid"=>"73440009-77d9-4793-8987-2bc1543e69d8"
    }
  end

  def expected_chat_history_response
    {"conversation"=>
        {"messages"=>
          {"message"=>
            {"sender"=>"21a2ce57-2fdd-47eb-b9b9-873ffacc2a62",        
             "message_time"=>"1260481265",
             "message_text"=>"kdskjakdk"
            }
          },
        "conversational_partner"=>"b4dcc6f0-0fdd-47b1-bbe1-5c58e7dd3710",
        "type"=>"JabberConversation",
        "started_at"=>"0",
        "identifier"=>"324"
      },
      "pagination"=>
        {"total_pages"=>"1", "current_page"=>"1"
      }
     }
  end
  
  def expected_user_invite_historyy_response
    {"invitation"=>   
      {"invitation_uid"=>"496_1285782841881",
       "created_at"=>"1285782843",
       "game_version"=>"0.0.0-103091",
       "game_name"=>"find_the_differences",
       "invitation_status"=>"Extended",
       "game_modality"=>"simbio"
       },
       "pagination"=>
       {"total_pages"=>"1",
        "current_page"=>"1"
       }
     }
  end

  def expected_time_spent_on_languages_response
    {"language"=> [{"language_code"=>"ESP", "time_spent"=>"331"}, {"language_code"=>"ITA", "time_spent"=>"37"}]}
  end

  def expected_recently_modified_profiles_response
    [OpenStruct.new({:email => "johndoe@rosettastone.com", :community_id => "343", :guid => "ecb2d32e-f60a-43f6-a7d5-92d42bb31ed2", :state_province => nil, :updated_at => {"content" => "Mon Aug 10 16:11:49", "time_zone" => "UTC"}, :city => nil, :created_at => {"content" => "Mon Jul 20 15:01:19", "time_zone" => "UTC"}, :last_name => "Doe", :preferred_name => "JayDee", :first_name => "John"})]
  end

  def recently_expired_or_created_licenses_xml_with_multiple_license_responses
    body = '<recently_updated_identifiers untill="2009-10-20 00:00:00" since="2009-10-08 00:00:00">
      <identifier>one@one.com</identifier>
      <identifier>two@two.com</identifier>
    </recently_updated_identifiers>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def recently_expired_or_created_licenses_xml_with_single_license_responses
    body = '<recently_updated_identifiers untill="2009-10-20 00:00:00" since="2009-10-08 00:00:00">
      <identifier>one@one.com</identifier>
    </recently_updated_identifiers>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def recently_expired_or_created_licenses_xml_with_no_license_responses
    body = '<recently_updated_identifiers untill="2009-10-20 00:00:00" since="2009-10-08 00:00:00">
    </recently_updated_identifiers>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def expected_recently_expired_or_created_licenses_with_multiple_response
    {"identifier" => ['one@one.com', 'two@two.com'], "since" => "2009-10-08 00:00:00", "untill" => "2009-10-20 00:00:00"}
  end

  def expected_recently_expired_or_created_licenses_with_single_response
    {"identifier" => ['one@one.com'], "since" => "2009-10-08 00:00:00", "untill" => "2009-10-20 00:00:00"}
  end

  def expected_recently_expired_or_created_licenses_with_no_response
    {"since" => "2009-10-08 00:00:00", "untill" => "2009-10-20 00:00:00"}
  end

  def recently_updated_license_identifiers_xml_with_multiple_license_responses
    body = '<recently_updated_guids last_audit_log_record_id="3">
      <guid>17fdecea-19eb-102c-9376-0015c5afe2a9</guid>
      <guid>4a68d897-2479-42e5-a9a2-84a40ead093b</guid>
    </recently_updated_guids>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def recently_updated_license_identifiers_xml_with_single_license_responses
    body = '<recently_updated_guids last_audit_log_record_id="3">
      <guid>17fdecea-19eb-102c-9376-0015c5afe2a9</guid>
    </recently_updated_guids>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def recently_updated_license_identifiers_xml_with_no_license_responses
    body = '<recently_updated_guids last_audit_log_record_id="3">
    </recently_updated_guids>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def expected_recently_updated_license_identifiers_with_multiple_response
    {"guid" => ['17fdecea-19eb-102c-9376-0015c5afe2a9', '4a68d897-2479-42e5-a9a2-84a40ead093b'], "last_audit_log_record_id" => "3"}
  end

  def expected_recently_updated_license_identifiers_with_single_response
    {"guid" => ['17fdecea-19eb-102c-9376-0015c5afe2a9'], "last_audit_log_record_id" => "3"}
  end

  def expected_recently_updated_license_identifiers_with_no_response
    {"last_audit_log_record_id" => "3"}
  end

  def community_learner_signin_history_xml_with_multiple_responses
    body = '<signin_history>
      <signin>
        <language_identifier>DEU</language_identifier>
        <paid>true</paid>
        <session_start_time>2009-07-10 14:58:42</session_start_time>
        <last_activity_time>2009-07-10 15:00:41</last_activity_time>
        <ip_address>209.145.88.41</ip_address>
        <logout_type>explicit_logout</logout_type>
      </signin>
      <signin>
        <language_identifier>DEU</language_identifier>
        <paid>true</paid>
        <session_start_time>2009-07-09 13:08:32</session_start_time>
        <last_activity_time>2009-07-09 13:33:44</last_activity_time>
        <ip_address>209.145.88.41</ip_address>
        <logout_type>explicit_logout</logout_type>
      </signin>
    </signin_history>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def community_learner_signin_history_xml_with_single_response
    body = '<signin_history>
      <signin>
        <language_identifier>DEU</language_identifier>
        <paid>true</paid>
        <session_start_time>2009-07-10 14:58:42</session_start_time>
        <last_activity_time>2009-07-10 15:00:41</last_activity_time>
        <ip_address>209.145.88.41</ip_address>
        <logout_type>explicit_logout</logout_type>
      </signin>
    </signin_history>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def community_learner_signin_history_xml_with_no_response
    body = '<signin_history>
    </signin_history>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def community_user_badges_xml_with_multiple_badge_response
    body = '<badges user_guid="guid">
  <badge>
    <description>description</description>
    <title>title</title>
    <image_url>some_url</image_url>
    <language_identifier>ESP</language_identifier>
  </badge>
  <badge>
    <description>description</description>
    <title>title</title>
    <image_url>some_url</image_url>
    <language_identifier>ESP</language_identifier>
  </badge>
</badges>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def community_user_badges_xml_with_single_badge_response
    body = '<badges user_guid="guid">
  <badge>
    <description>description</description>
    <title>title</title>
    <image_url>some_url</image_url>
    <language_identifier>ESP</language_identifier>
  </badge>
</badges>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def community_user_badges_xml_with_zero_badge_response
    body = '<badges user_guid="guid">
</badges>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def community_learner_audit_log_xml_with_zero_log_entries_response
    body = '<learner_audit_logs>
    </learner_audit_logs>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def community_learner_audit_log_xml_with_single_log_entry_response
    body = '<learner_audit_logs>
     <log_record>
        <action>update</action>
        <attribute_name>preferred_name</attribute_name>
        <previous_value>John</previous_value>
        <new_value>JayDee</new_value>
        <changed_by>Someone</changed_by>
        <ip_address>2.2.2.2</ip_address>
     </log_record>
    </learner_audit_logs>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def community_learner_audit_log_xml_with_multiple_log_entries_response
    body = '<learner_audit_logs>
     <log_record>
        <action>update</action>
        <attribute_name>preferred_name</attribute_name>
        <previous_value>John</previous_value>
        <new_value>JayDee</new_value>
        <changed_by>Someone</changed_by>
        <ip_address>2.2.2.2</ip_address>
     </log_record>
     <log_record>
        <action>update</action>
        <attribute_name>city</attribute_name>
        <previous_value>Virginia</previous_value>
        <new_value>Las Vegas</new_value>
        <changed_by>Someone Else</changed_by>
        <ip_address>1.1.1.1</ip_address>
     </log_record>
    </learner_audit_logs>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def social_app_languages_xml_with_multiple_response
    body = '<social_app_languages guid="ba4f3565-b208-4915-bc9b-2defcbe645c0">
  <language>ENG</language>
  <language>NED</language>
</social_app_languages>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def social_app_languages_xml_with_single_response
    body = '<social_app_languages guid="ba4f3565-b208-4915-bc9b-2defcbe645c0">
  <language>ENG</language>
</social_app_languages>'
    OpenStruct.new({"status" => '200', "body" => body})
  end


  def social_app_languages_xml_with_zero_response
    body = '<social_app_languages guid="ba4f3565-b208-4915-bc9b-2defcbe645c0">
</social_app_languages>'
    OpenStruct.new({"status" => '200', "body" => body})
  end

  def unknown_guid_exception_response
    body = '<exception class="BafflingApiController::UnknownGuidException">Unknown or no GUID specified.</exception>'
    OpenStruct.new({"status" => '500', "body" => body})
  end

  def crazy_exception_response
    body = '<exception class="BafflingApiController::CrazyException">hmmm</exception>'
    OpenStruct.new({"status" => '500', "body" => body})
  end

  def broken_exception_response
    body = '.'
    OpenStruct.new({"status" => '500', "body" => body})
  end

  def missing_language_exception_response
    body = '<exception class="ApplicationController::MissingLanguageException">No ISO code mapping found.</exception>'
    OpenStruct.new({"status" => '500', "body" => body})
  end

  def expected_community_learner_signin_history_with_multiple_response
    [OpenStruct.new({"last_activity_time"=>"2009-07-10 15:00:41", "paid"=>"true", "logout_type"=>"explicit_logout", "language_identifier"=>"DEU", "session_start_time"=>"2009-07-10 14:58:42", "ip_address"=>"209.145.88.41"}),
      OpenStruct.new({"last_activity_time"=>"2009-07-09 13:33:44", "paid"=>"true", "logout_type"=>"explicit_logout", "language_identifier"=>"DEU", "session_start_time"=>"2009-07-09 13:08:32", "ip_address"=>"209.145.88.41"})]
  end

  def expected_community_learner_signin_history_with_single_response
    [OpenStruct.new({"last_activity_time"=>"2009-07-10 15:00:41", "paid"=>"true", "logout_type"=>"explicit_logout", "language_identifier"=>"DEU", "session_start_time"=>"2009-07-10 14:58:42", "ip_address"=>"209.145.88.41"})]
  end

  def expected_community_learner_signin_history_with_no_response
    []
  end

  def expected_community_user_roles_with_no_response
    []
  end

  def expected_community_user_roles_with_single_response
    [OpenStruct.new({"description"=>"gets 20 badges on sign in.", "role_name"=>"software dev"})]
  end

  def expected_community_user_roles_with_multiple_response
    [OpenStruct.new({"description"=>"Ability to review content", "role_name"=>"Content Reviewer"}),
      OpenStruct.new({"description"=>"gets 20 badges on sign in.", "role_name"=>"software dev"})]
  end

  def expected_community_user_badges_with_multiple_badge_response
    [OpenStruct.new({:language_identifier => "ESP", :image_url => "some_url", :description => "description", :title => "title"}),
      OpenStruct.new({:language_identifier => "ESP", :image_url => "some_url", :description => "description", :title => "title"})]
  end

  def expected_community_user_badges_with_single_badge_response
    [OpenStruct.new({:language_identifier => "ESP", :image_url => "some_url", :description => "description", :title => "title"})]
  end

  def expected_community_learner_audit_log_with_zero_entries_response
    []
  end

  def expected_community_learner_audit_log_with_single_entry_response
    [OpenStruct.new({"action"=>"update", "attribute_name"=>"preferred_name", "previous_value"=>"John",
          "new_value"=>"JayDee", "changed_by"=>"Someone", "ip_address"=>"2.2.2.2"})]
  end

  def expected_community_learner_audit_log_with_multiple_entries_response
    [OpenStruct.new({"action"=>"update", "attribute_name"=>"preferred_name", "previous_value"=>"John",
          "new_value"=>"JayDee", "changed_by"=>"Someone", "ip_address"=>"2.2.2.2"}),
      OpenStruct.new({"action"=>"update", "attribute_name"=>"city", "previous_value"=>"Virginia",
          "new_value"=>"Las Vegas", "changed_by"=>"Someone Else", "ip_address"=>"1.1.1.1"})
    ]
  end

  def expected_social_app_language_with_multiple_response
    ["ENG", "NED"]
  end

  def expected_social_app_language_with_single_response
    ["ENG"]
  end

  def expected_social_app_language_with_zero_response
    []
  end

end
