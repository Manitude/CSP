require File.dirname(__FILE__) + '/../test_helper'
require 'coach_roster_controller'
require 'sub_sequence'

class CoachRosterControllerTest < ActionController::TestCase

def setup
    login_as_custom_user(AdGroup.coach_manager, 'hello')
end

def test_default_coach_roster
    member1 = FactoryGirl.create(:management_team_member, :name => "Preethi" ,:hide => false,:email =>"preethi.baskar@listertechnologies.com", :position => 1)
    member2 = FactoryGirl.create(:management_team_member, :name => "pbaskar" ,:hide => true,:email =>"preethibaskar@listertechnologies.com", :position => 2)
    get :coach_roster
    assert_response :success
    assert_true response.body.include?("Preethi")
    assert_false response.body.include?("pbaskar")
end

def test_coach_roster_with_language_and_region
    member1 = FactoryGirl.create(:management_team_member, :name => "Preethi" ,:hide => false,:email =>"preethi.baskar@listertechnologies.com", :position => 1)
    member2 = FactoryGirl.create(:management_team_member, :name => "pbaskar" ,:hide => true,:email =>"preethibaskar@listertechnologies.com", :position => 2)
    coach = create_coach_with_qualifications
    get :coach_roster, :language => "ARA"
    assert_response :success
    assert_true response.body.include?("newcoach")
    assert_true response.body.include?("Preethi")
    assert_false response.body.include?("pbaskar")

end

def test_edit_management_team
    member1 = FactoryGirl.create(:management_team_member, :name => "Preethi" ,:hide => false,:email =>"preethi.baskar@listertechnologies.com", :position => 1)
    member2 = FactoryGirl.create(:management_team_member, :name => "pbaskar" ,:hide => true,:email =>"preethibaskar@listertechnologies.com", :position => 2)
    get :edit_management_team
    assert_response :success
    assert_true response.body.include?("Preethi")
    assert_true response.body.include?("pbaskar")
end

def test_management_team_form
    member = FactoryGirl.create(:management_team_member, :name => "Preethi" ,:hide => false,:email =>"preethi.baskar@listertechnologies.com", :position => 1)
    get :management_team_form , :member_id => member.id
    assert_response :success

end

 def test_hide_member
 	member = FactoryGirl.create(:management_team_member, :name => "Preethi" ,:hide => false,:email =>"preethi.baskar@listertechnologies.com")
 	member.save
    params = {:member_id => member.id, :hide => "true"}
    get :hide_member , params
    assert_response :success
 end

 def test_delete_member
    member = FactoryGirl.create(:management_team_member, :name => "Preethi" ,:hide => false,:email =>"preethi.baskar@listertechnologies.com")
    get :delete_member , :member_id => member.id
    assert_response :success
 end

 def test_save_member_details
     member = FactoryGirl.create(:management_team_member, :name => "Preethi" ,:hide => false,:email =>"preethi.baskar@listertechnologies.com")
     member.save
     post :save_member_details , :remove_profile_picture => "true" , :member_id => member.id
     assert_response :success
     params = {:management_team_member => {:name => 'pbaskar', :hide => 'false', :email =>"preethi.baskar@listertechnologies.com"}}
     post :save_member_details , params
     assert_response :success
 end

 def test_save_order_of_members
    member1 = FactoryGirl.create(:management_team_member, :name => "Preethi" ,:hide => false,:email =>"preethi.baskar@listertechnologies.com")
    member2 = FactoryGirl.create(:management_team_member, :name => "pbaskar" ,:hide => true,:email =>"preethibaskar@listertechnologies.com", :position => 2)
    new_order = [member1.id,member2.id]
    get :save_order_of_members , :new_order => new_order
    assert_response :success

 end

 def test_export_coach_list_as_csv
    member1 = FactoryGirl.create(:management_team_member, :name => "Preethi" ,:hide => false,:email =>"preethi.baskar@listertechnologies.com")
    member2 = FactoryGirl.create(:management_team_member, :name => "pbaskar" ,:hide => true,:email =>"preethibaskar@listertechnologies.com", :position => 2)
    coach = create_coach_with_qualifications
    post :export_coach_list_as_csv, :language => "ARA"
    assert_response :success
 end

 def test_export_mgmt_list_as_csv
    member1 = FactoryGirl.create(:management_team_member, :name => "Preethi" ,:hide => false,:email =>"preethi.baskar@listertechnologies.com")
    member2 = FactoryGirl.create(:management_team_member, :name => "pbaskar" ,:hide => false,:email =>"preethibaskar@listertechnologies.com", :position => 2)
    post :export_mgmt_list_as_csv
    assert_response :success
 end

end
