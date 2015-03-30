require File.dirname(__FILE__) + '/../test_helper'

class CoachControllerTest < ActionController::TestCase
  fixtures :languages, :accounts

  def test_create_proper_coach
    stub_eschool_call_for_profile_creation_with_success
    post :create_coach ,
      :coach => { "user_name"=>"perfectguy",
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
                },
                
      :qualifications => {
                  "0"=>{"max_unit"=>"12", "language_id"=>"#{@japanese.id}"},
                  "1"=>{"max_unit"=>"9", "language_id"=>"#{@spanish_la.id}"}
      }
    assert_equal "Coach was successfully created.", flash[:notice]
    assert_redirected_to create_coach_path
  end

  def test_create_bad_coach_missing_user_name
    #stub_eschool_call_for_profile_creation_with_success
    # No need to stub as it wouldn't go that far
    post :create_coach ,
      :coach => { 
                  "user_name"=>"",
                  "full_name"=>"does it matter",
                  "rs_email"=>"blah@rosettastone.com",
                  "personal_email"=>"blah@perfection.com",
                  "preferred_name"=>"badguy",
                  "primary_country_code"=>"31",
                  "primary_phone"=>"2830581034",
                  "secondary_phone"=>"2830581012",
                  "skype_id"=>"iamimproper",
                  "birth_date(1i)"=>"1951", "birth_date(2i)"=>"8", "birth_date(3i)"=>"9",
                  "hire_date(1i)"=>"2011", "hire_date(2i)"=>"8", "hire_date(3i)"=>"9",
                  "region_id"=>"",
                  "bio"=>"I will NOT be saved successfully"
                },
                
      :qualifications => {
                  "0"=>{"max_unit"=>"12", "language_id"=>"#{@japanese.id}"},
                  "1"=>{"max_unit"=>"9", "language_id"=>"#{@spanish_la.id}"}
      }
       x = Coach.find_by_rs_email("blah@rosettastone.com")
    assert_nil x 
  end

  def test_create_bad_coach_who_tries_multiple_qualifications_of_same_language
    #stub_eschool_call_for_profile_creation_with_success
    # No need to stub as it wouldn't go that far
    post :create_coach ,
      :coach => { "user_name"=>"itmatters",
                  "full_name"=>"does it matter",
                  "rs_email"=>"blah@rosettastone.com",
                  "personal_email"=>"blah@perfection.com",
                  "preferred_name"=>"badguy",
                  "primary_country_code"=>"31",
                  "primary_phone"=>"2830581034",
                  "secondary_phone"=>"2830581012",
                  "skype_id"=>"iamimproper",
                  "birth_date(1i)"=>"1951", "birth_date(2i)"=>"8", "birth_date(3i)"=>"9",
                  "hire_date(1i)"=>"2011", "hire_date(2i)"=>"8", "hire_date(3i)"=>"9",
                  "region_id"=>"",
                  "bio"=>"I will NOT be saved successfully"
                },
                 
      :qualifications => {
                  "0"=>{"max_unit"=>"12", "language_id"=>"#{@japanese.id}"},
                  "1"=>{"max_unit"=>"9", "language_id"=>"#{@japanese.id}"},
                  "2"=>{"max_unit"=>"4", "language_id"=>"#{@spanish_la.id}"}
      }
      x = Coach.find_by_rs_email("blah@rosettastone.com")
    assert_nil x 
  end

  def test_edit_coach_success_response
    stub_eschool_call_for_profile_creation_with_success
    coach = create_a_coach

    post :edit_coach ,:id => coach.id,
      :coach => { "full_name"=>"Coach One",
                  "rs_email"=>"coach1@rosettastone.com",
                  "personal_email"=>"coach1@perfection.com",
                  "preferred_name"=>"Coachie",
                  "primary_phone"=>"2830581034",
                  "primary_country_code"=>"1",
                  "secondary_phone"=>"2830581012",
                  "skype_id"=>"ps",
                  "birth_date(1i)"=>"1951", "birth_date(2i)"=>"8", "birth_date(3i)"=>"9",
                  "hire_date(1i)"=>"2011", "hire_date(2i)"=>"8", "hire_date(3i)"=>"9",
                  "region_id"=>"",
                  "bio"=>"I will be updated successfully"
                },
      :qualifications => {
                  "0"=>{"max_unit"=>"12", "language_id"=>"#{@japanese.id}"},
                  "1"=>{"max_unit"=>"9", "language_id"=>"#{@spanish_la.id}"}
      }
      coach.reload
    assert_equal "Coach One", coach.full_name
    assert_equal "Profile has been updated successfully.", flash[:notice]
    assert_redirected_to view_coach_profiles_path(:coach_id => coach.id)
  end

  def test_edit_coach_with_empty_full_name
    #stub_eschool_call_for_profile_creation_with_success
    # No need to stub as it wouldn't go that far
    coach = create_a_coach
    post :edit_coach ,:id => coach.id,
      :coach => { "full_name"=>"",
                  "rs_email"=>"coach1@rosettastone.com",
                  "personal_email"=>"coach1@perfection.com",
                  "preferred_name"=>"Coachie",
                  "primary_phone"=>"2830581034",
                  "primary_country_code"=>"1",
                  "secondary_phone"=>"2830581012",
                  "skype_id"=>"ps",
                  "birth_date(1i)"=>"1951", "birth_date(2i)"=>"8", "birth_date(3i)"=>"9",
                  "hire_date(1i)"=>"2011", "hire_date(2i)"=>"8", "hire_date(3i)"=>"9",
                  "region_id"=>"",
                  "bio"=>"I will be updated successfully"
                },
      :qualifications => {
                  "0"=>{"max_unit"=>"12", "language_id"=>"#{@japanese.id}"},
                  "1"=>{"max_unit"=>"9", "language_id"=>"#{@spanish_la.id}"}
      }
      x = Coach.find_by_full_name("")
    assert_nil x 
    assert_select "div#errorExplanation" do
      assert_select "h2",:text => "2 errors prohibited this coach from being saved"
      assert_select "li", :count => 2
      assert_select "li", :text => "Full name can&#x27;t be blank"
      assert_select "li", :text => "Full name cannot have numbers or special characters"
    end
    assert_response :success
  end

  def test_edit_coach_who_tries_multiple_qualifications_of_same_language
    #stub_eschool_call_for_profile_creation_with_success
    # No need to stub as it wouldn't go that far
    coach = create_a_coach
    post :edit_coach ,:id => coach.id,
      :coach => { "full_name"=>"Coach One",
                  "rs_email"=>"coach1@rosettastone.com",
                  "personal_email"=>"coach1@perfection.com",
                  "preferred_name"=>"Coachie",
                  "primary_phone"=>"2830581034",
                  "primary_country_code"=>"1",
                  "secondary_phone"=>"2830581012",
                  "skype_id"=>"ps",
                  "birth_date(1i)"=>"1951", "birth_date(2i)"=>"8", "birth_date(3i)"=>"9",
                  "hire_date(1i)"=>"2011", "hire_date(2i)"=>"8", "hire_date(3i)"=>"9",
                  "region_id"=>"",
                  "bio"=>"I will be updated successfully"
                },
      :qualifications => {
                  "0"=>{"max_unit"=> "12", "language_id"=> "#{@japanese.id}"},
                  "1"=>{"max_unit"=> "9", "language_id"=> "#{@japanese.id}"}
      }
      coach.reload
      assert_equal coach.qualifications.count, 1
      assert_response :success

  end

  def test_edit_coach_who_tries_to_add_a_qualification_with_wrong_max_unit
    #stub_eschool_call_for_profile_creation_with_success
    # No need to stub as it wouldn't go that far
    language_with_max_unit_12 = languages(:JPN)
    coach = create_a_coach
    post :edit_coach ,:id => coach.id,
      :coach => { "full_name"=>"Coach One",
                  "rs_email"=>"coach1@rosettastone.com",
                  "personal_email"=>"coach1@perfection.com",
                  "preferred_name"=>"Coachie",
                  "primary_phone"=>"2830581034",
                  "primary_country_code"=>"1",
                  "secondary_phone"=>"2830581012",
                  "skype_id"=>"ps",
                  "birth_date(1i)"=>"1951", "birth_date(2i)"=>"8", "birth_date(3i)"=>"9",
                  "hire_date(1i)"=>"2011", "hire_date(2i)"=>"8", "hire_date(3i)"=>"9",
                  "region_id"=>"",
                  "bio"=>"I will be updated successfully"
                },
      :qualifications => {
                  "0"=>{"max_unit"=> "40", "language_id"=> "#{language_with_max_unit_12.id}"}
      }
      coach.reload

    assert_equal coach.qualifications.count, 0
    assert_select "div#errorExplanation" do
      assert_select "h2",:text => "1 error prohibited this coach from being saved"
      assert_select "li", :count => 1
      assert_select "li", :text => "The maximum unit you selected exceeds the maximum unit offered for Japanese. Please select the correct maximum unit."
    end
    assert_response :success
  end

  def test_edit_coach_when_coach_profile_saves_successfully_in_csp_and_fails_to_save_in_eschool
    stub_eschool_call_for_profile_creation_with_error
    coach = create_a_coach
    post :edit_coach ,:id => coach.id,
      :coach => { "full_name"=>"Coach One",
                  "rs_email"=>"coach1@rosettastone.com",
                  "personal_email"=>"coach1@perfection.com",
                  "preferred_name"=>"Coachie",
                  "primary_phone"=>"2830581034",
                  "primary_country_code"=>"1",
                  "secondary_phone"=>"2830581012",
                  "skype_id"=>"ps",
                  "birth_date(1i)"=>"1951", "birth_date(2i)"=>"8", "birth_date(3i)"=>"9",
                  "hire_date(1i)"=>"2011", "hire_date(2i)"=>"8", "hire_date(3i)"=>"9",
                  "region_id"=>"",
                  "bio"=>"I will be updated successfully"
                },
      :qualifications => {
                  "0"=>{"max_unit"=>"12", "language_id"=>"#{@japanese.id}"},
                  "1"=>{"max_unit"=>"9", "language_id"=>"#{@spanish_la.id}"}
      }
    coach.reload
    assert_nil flash[:notice]
    assert_equal "Coach One", coach.full_name
    assert_response :success
  end

  def test_edit_coach_when_coach_profile_saves_successfully_in_csp_and_eschool_call_raises_an_exception
    Account::Coach.stubs(:update_eschool).raises(Exception)
    coach = create_a_coach
    post :edit_coach ,:id => coach.id,
      :coach => { "full_name"=>"Coach One",
                  "rs_email"=>"coach1@rosettastone.com",
                  "personal_email"=>"coach1@perfection.com",
                  "preferred_name"=>"Coachie",
                  "primary_phone"=>"2830581034",
                  "primary_country_code"=>"1",
                  "secondary_phone"=>"2830581012",
                  "skype_id"=>"ps",
                  "birth_date(1i)"=>"1951", "birth_date(2i)"=>"8", "birth_date(3i)"=>"9",
                  "hire_date(1i)"=>"2011", "hire_date(2i)"=>"8", "hire_date(3i)"=>"9",
                  "region_id"=>"",
                  "bio"=>"I will be updated successfully"
                },
      :qualifications => {
                  "0"=>{"max_unit"=>"12", "language_id"=>"#{@japanese.id}"},
                  "1"=>{"max_unit"=>"9", "language_id"=>"#{@spanish_la.id}"}
      }
    coach.reload
    assert_equal "Coach One", coach.full_name
    assert_nil flash[:notice]
    assert_response :success
  end

  def test_edit_coach_when_wild_card_units_gets_updated_successfully_in_eschool
    stub_eschool_call_for_updating_wildcard_units_with_success
    stub_eschool_call_for_profile_creation_with_success
    language = languages(:language_001)
    coach = create_a_coach
    coach.qualifications.delete_all
    coach.qualifications.create(:language_id => language.id, :max_unit=>10)
    post :edit_coach ,:id => coach.id,
      :coach => { "full_name"=>"Coach One",
                  "rs_email"=>"coach1@rosettastone.com",
                  "personal_email"=>"coach1@perfection.com",
                  "preferred_name"=>"Coachie",
                  "primary_phone"=>"2830581034",
                  "primary_country_code"=>"1",
                  "secondary_phone"=>"2830581012",
                  "skype_id"=>"ps",
                  "birth_date(1i)"=>"1951", "birth_date(2i)"=>"8", "birth_date(3i)"=>"9",
                  "hire_date(1i)"=>"2011", "hire_date(2i)"=>"8", "hire_date(3i)"=>"9",
                  "region_id"=>"",
                  "bio"=>"I will be updated successfully"
                },
      :qualifications => { "0"=>{"max_unit"=>"12", "language_id"=>"#{language.id}"}}
    coach.reload
    assert_equal 12, coach.qualifications.first.max_unit
    assert_equal "Profile has been updated successfully." , flash[:notice]
    assert_redirected_to view_coach_profiles_path(:coach_id => coach.id)
    assert_response :redirect
  end

  def test_edit_coach_when_wild_card_units_gets_updated_for_some_sessions_and_fails_for_others_in_eschool
    stub_eschool_call_for_updating_wildcard_units_with_not_all_wildcards_updated_error
    stub_eschool_call_for_profile_creation_with_success
    language1 = languages(:language_001)
    coach = create_a_coach
    coach.qualifications.delete_all
    coach.qualifications.create(:language_id => language1.id, :max_unit=>10)
    post :edit_coach ,:id => coach.id,
      :coach => { "full_name"=>"Coach One",
                  "rs_email"=>"coach1@rosettastone.com",
                  "personal_email"=>"coach1@perfection.com",
                  "preferred_name"=>"Coachie",
                  "primary_phone"=>"2830581034",
                  "primary_country_code"=>"1",
                  "secondary_phone"=>"2830581012",
                  "skype_id"=>"ps",
                  "birth_date(1i)"=>"1951", "birth_date(2i)"=>"8", "birth_date(3i)"=>"9",
                  "hire_date(1i)"=>"2011", "hire_date(2i)"=>"8", "hire_date(3i)"=>"9",
                  "region_id"=>"",
                  "bio"=>"I will be updated successfully"
                },
      :qualifications => {"0"=>{"max_unit"=>"12", "language_id"=>"#{language1.id}"} }
    coach.reload
    assert_nil flash[:notice]
    assert_equal 12, coach.qualifications.first.max_unit
    assert_response :success
  end

  def test_edit_coach_when_the_api_to_update_wildcard_units_is_not_available
    stub_eschool_call_for_profile_creation_with_success
    Eschool::Session.stubs(:update_wildcard_units_for_eschool_sessions).returns(nil)
    language1 = languages(:language_001)
    coach = create_a_coach
    coach.qualifications.delete_all
    coach.qualifications.create(:language_id => language1.id, :max_unit=>10)
    post :edit_coach ,:id => coach.id,
      :coach => { "full_name"=>"Coach One",
                  "rs_email"=>"coach1@rosettastone.com",
                  "personal_email"=>"coach1@perfection.com",
                  "preferred_name"=>"Coachie",
                  "primary_phone"=>"2830581034",
                  "primary_country_code"=>"1",
                  "secondary_phone"=>"2830581012",
                  "skype_id"=>"ps",
                  "birth_date(1i)"=>"1951", "birth_date(2i)"=>"8", "birth_date(3i)"=>"9",
                  "hire_date(1i)"=>"2011", "hire_date(2i)"=>"8", "hire_date(3i)"=>"9",
                  "region_id"=>"",
                  "bio"=>"I will be updated successfully"
                },
      :qualifications => { "0"=>{"max_unit"=>"12", "language_id"=>"#{language1.id}"} }
    coach.reload
    assert_nil flash[:notice]
    assert_equal 12, coach.qualifications.first.max_unit
    assert_response :success
  end

  def setup
    @japanese = languages(:JPN)
    @spanish_la = languages(:ESP)
    login_as_custom_user(AdGroup.coach_manager, 'hello')
  end

end
