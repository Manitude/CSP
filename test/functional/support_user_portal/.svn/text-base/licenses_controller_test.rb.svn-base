# To change this template, choose Tools | Templates
# and open the template in the editor.

require File.dirname(__FILE__) + '/../../test_helper'
require 'support_user_portal/licenses_controller'
require 'dupe'
require 'ostruct'

class SupportUserPortal::LicensesControllerTest < ActionController::TestCase

  def setup
    login_as_custom_user(AdGroup.support_lead, 'test21')
  end

  def test_check_reason_drop_down_in_add_extensions
    stub_license_server_and_community_for_license_info
    get :show_extension_form, {:license_guid => "ef33d423-d725-45f4-b363-65bca092b1db",:license_identifier => "totale.applauncher@ie7.winxp",:language => "ENG",:version => "3", :pr_guid => "22802d43-549d-44d0-b6a5-70cfd3864b45", :original_end_date => "Sat Jan 01 05:29:00 +0530 2016"}
    assert_response :success

    assert_select 'select[id="reason"]' do
      assert_select 'option[value="Select"][selected="selected"]',  :count => 1
    end
    assert_equal @response.inspect.include?('CASE NUMBER:'),true
  end

  def test_license_info_for_activate_deactivate
    learner = Learner.create({:first_name => "CSP", :last_name => "Content Range", :email => "csp@content.range", :guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef", :user_source_type => "Community::User", :totale => true, :rworld => true, :osub => false, :osub_active => false, :totale_active => false, :enterprise_license_active => false, :parature_customer => false, :previous_license_identifiers => nil, :created_at => "2011-12-01 20:45:05", :updated_at => "2011-12-16 19:24:22"})
    learner.save
    stub_license_server_and_community_for_license_info
    stub_lcdb
    get :license_info,{:license_guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef"}
    assert_response :success
    assert_no_tag 'img', :attributes => {:title => 'Rosetta Stone'}
    assert_no_tag 'img', :attributes => {:id => 'inst_container'}
    assert_no_tag 'input', :attributes => {:id => 'activate_deactivate'}
  end

  def test_show_learner_profile_and_license_information_main_page_content
    learner = Learner.create({:first_name => "CSP", :last_name => "Content Range", :email => "csp@content.range", :guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef", :user_source_type => "Community::User", :totale => true, :rworld => true, :osub => false, :osub_active => false, :totale_active => false, :enterprise_license_active => false, :parature_customer => false, :previous_license_identifiers => nil, :created_at => "2011-12-01 20:45:05", :updated_at => "2011-12-16 19:24:22"})
    learner.save
    stub_license_server_and_community_for_license_info_for_combined_page
    stub_lcdb
    get :show_learner_profile_and_license_information,{:license_guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef"}
    assert_response :success
    assert_select 'img', :attributes => {:title => 'Rosetta Stone'}
    assert_select 'img', :attributes => {:id => 'inst_container'}
    assert_select 'input#activate_deactivate', :count => 1
    activate_deactivate_checkbox = css_select 'input#activate_deactivate'
    assert_equal activate_deactivate_checkbox[0].attributes["checked"],nil 
    assert_select "title", "Customer Success Portal: Learner Profile - CSP Content Range"
    assert_select "div[id=new_search_link]", "New Search"
    assert_select "input[type=button][id=change_password_button]"
  end

  #added by ela starts
  def test_add_or_remove_extension
    
    get :add_or_remove_extension,{:license_guid => "ad6c954a-0c46-4816-813a-5ce3af7f626e",:language => "ENG",:product_version => "3",:license_identifier => "elavarasu.pandiyan3002@gmail.com", :reason => "Other", :other_reason => "Just a credit", :add_time => "true", :solo_consumable_count => "3",:group_consumable_count => "3",:ticket_number => "CSP-999",:add_duration=>"3m" }
    assert_response :redirect
    
  end

  #added by ela ends
  def test_deactivate_reactivate_license_success
    RosettaStone::ActiveLicensing::License.any_instance.stubs(:reactivate).returns(true)
    get :activate_deactivate_license, {:guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef",:active => "false"}
    assert_response :success
    assert_equal true, JSON.parse(@response.body)["isSuccessful"]
    RosettaStone::ActiveLicensing::License.any_instance.stubs(:deactivate).returns(true)
    get :activate_deactivate_license, {:guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef",:active => "true"}
    assert_response :success
    assert_equal true, JSON.parse(@response.body)["isSuccessful"]
  end

  def test_activate_deactivate_license_error
    RosettaStone::ActiveLicensing::License.any_instance.stubs(:reactivate).returns(false)
    get :activate_deactivate_license, {:guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef",:active => "false"}
    assert_response :success
    assert_equal false, JSON.parse(@response.body)["isSuccessful"]
    RosettaStone::ActiveLicensing::License.any_instance.stubs(:deactivate).returns(false)
    get :activate_deactivate_license, {:guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef",:active => "true"}
    assert_response :success
    assert_equal false, JSON.parse(@response.body)["isSuccessful"]
  end

  def test_cal_duration
    assert_equal "2d",SupportUserPortal::LicensesController.new.cal_duration("2d","12/07/11 12:00 AM")
    assert_equal "30d",SupportUserPortal::LicensesController.new.cal_duration("1m","12/07/11 12:00 AM")
    assert_equal "2d",SupportUserPortal::LicensesController.new.cal_duration("12/09/11 12:00 AM","12/07/11 12:00 AM")
  end

  def test_support_conceirge_cannot_activate_deactivate_license
    login_as_support_conceirge_and_create_learner    
    stub_license_server_and_community_for_license_info_for_combined_page
    stub_lcdb
    get :show_learner_profile_and_license_information,{:license_guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef"}
    assert_response :success
    assert_select 'input#activate_deactivate', :count => 1
    activate_deactivate_checkbox = css_select 'input#activate_deactivate'
    assert_equal activate_deactivate_checkbox[0].attributes["disabled"], "disabled"
  end

  def test_support_conceirge_cannot_change_password
    login_as_support_conceirge_and_create_learner
    stub_license_server_and_community_for_license_info_for_combined_page
    stub_lcdb
    get :show_learner_profile_and_license_information,{:license_guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef"}
    assert_response :success
    assert_select 'input#change_password_button', :count => 1
    activate_deactivate_checkbox = css_select 'input#change_password_button'
    assert_equal activate_deactivate_checkbox[0].attributes["disabled"], "disabled"
  end

  def test_support_conceirge_cannot_see_extensions_link
    login_as_support_conceirge_and_create_learner
    stub_license_server_and_community_for_license_info
    stub_lcdb
    get :license_info,{:license_guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef"}
    assert_response :success
    assert_select 'a', :text => "Extensions (2)", :count => 0
    assert_select 'span#extension_0', :count => 1 do
      assert_select 'span', :text => 'Extensions (2)'
    end
  end

  def test_support_conceirge_can_see_audit_log_link
    login_as_support_conceirge_and_create_learner
    stub_license_server_and_community_for_license_info
    stub_lcdb
    get :license_info,{:license_guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef"}
    assert_response :success
    assert_select 'a', :text => "License Information (in LV)", :count => 1
    assert_select 'span#audit_log_0', :count => 1 do
      assert_select 'span', :text => 'License Information (in LV)'
    end
  end

  def test_licenses_hierarchy
    login_as_custom_user(AdGroup.support_concierge_user, 'test22')
    stub_license_server
    get :licenses_hierarchy,{:license_guid => "cceec678-6243-4d8b-afa3-8136995c2106",:family_name => "MT::listerleelaesplevel1learner@rs.com::1337146091"}
    assert_response :success
    assert_tag 'ul',:attributes => {:id => 'org'}
    assert_tag 'div',:attributes => {:id => 'chart'}
    assert_select 'ul#org ul',1
    assert_select 'ul#org li',1
    assert_select 'ul#org ul li',3
  end

  def test_modify_language
    stub_ls_api_method_to_update_lang
    RosettaStone::ActiveLicensing::License.any_instance.stubs(:product_rights).returns([{"product_family"=>"application", "created_at"=> "Wed Nov 30 19:54:58 +0530 2011".to_datetime, "guid"=>"a456e046-4714-4247-a1a9-e58fa7d7b9bf", "unextended_ends_at"=>"Wed Apr 11 19:15:03 +0530 2012".to_datetime, "starts_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "license"=>{"guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "identifier"=>"csp@content.range"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Wed Apr 11 19:15:03 +0530 2012".to_datetime, "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"4", "created_at"=>"1314835200", "guid"=>"f9865fdf-309c-4ec2-938c-3cdcf50d6ed3", "updated_at"=>"1314835200", "activation_id"=>nil, "min_unit"=>"1"}, {"max_unit"=>"8", "created_at"=>"1317427200", "guid"=>"27ad98e9-813e-4379-b882-e270b57df8fe", "updated_at"=>"1317427200", "activation_id"=>nil, "min_unit"=>"5"}, {"max_unit"=>"12", "created_at"=>"1322663808", "guid"=>"fae27ec0-e375-4aeb-a91e-3f89f907dad8", "updated_at"=>"1322663808", "activation_id"=>nil, "min_unit"=>"1"}]}, {"product_family"=>"eschool", "created_at"=>"Wed Nov 30 19:55:13 +0530 2011".to_datetime, "guid"=>"b4ecbdf2-8d4d-48f1-9b4d-b57fa2f91f4d", "unextended_ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "starts_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "license"=>{"guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "identifier"=>"csp@content.range"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"4", "created_at"=>"1314835200", "guid"=>"43425c0b-cbff-43c8-bf14-d6c07f0693f8", "updated_at"=>"1314835200", "activation_id"=>nil, "min_unit"=>"1"}, {"max_unit"=>"8", "created_at"=>"1317427200", "guid"=>"e6a95d93-f8b1-4d93-b2e2-0ba3b660e74e", "updated_at"=>"1317427200", "activation_id"=>nil, "min_unit"=>"5"}, {"max_unit"=>"12", "created_at"=>"1322663822", "guid"=>"43d13237-6c5d-4589-b806-f8bdf97057e8", "updated_at"=>"1322663822", "activation_id"=>nil, "min_unit"=>"1"}]}, {"product_family"=>"premium_community", "created_at"=>"Wed Nov 30 19:55:24 +0530 2011".to_datetime, "guid"=>"11e2d905-3224-4428-94f1-4f10e5b57ea2", "unextended_ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "starts_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "license"=>{"guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "identifier"=>"csp@content.range"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"4", "created_at"=>"1314835200", "guid"=>"9964fb81-13b3-4e6f-858d-3a9c958d28f1", "updated_at"=>"1314835200", "activation_id"=>nil, "min_unit"=>"1"}, {"max_unit"=>"8", "created_at"=>"1317427200", "guid"=>"79e72631-6c92-4b06-b147-9e7cec9873aa", "updated_at"=>"1317427200", "activation_id"=>nil, "min_unit"=>"5"}, {"max_unit"=>"12", "created_at"=>"1322663851", "guid"=>"9a0e8db2-441c-435e-9806-bc46d2c259fa", "updated_at"=>"1322663851", "activation_id"=>nil, "min_unit"=>"1"}]}])
    Eschool::Student.stubs(:cancel_future_sessions).returns(nil)
    SupportUserPortal::LicensesController.any_instance.expects(:create_product_language_log)
    response = post :modify_language, :changed_language => "EBR", :reason => "test", :previous_language => "ESP", :license_guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef"
    assert_response :redirect
    assert_redirected_to(show_learner_profile_and_license_information_path(:license_guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef"))
  end


  def test_create_product_language_log_for_invalid_product_lang_log_with_blank_reason
    SupportUserPortal::LicensesController.any_instance.expects(:current_user).returns(SupportLead.first)
    returned_value = {}
    params = Hash.new
    product_rights_guids_array = ["a456e046-4714-4247-a1a9-e58fa7d7b9bf","b4ecbdf2-8d4d-48f1-9b4d-b57fa2f91f4d","11e2d905-3224-4428-94f1-4f10e5b57ea2"]
    assert_no_difference "ProductLanguageLog.all.size" do
    params[:previous_language] = "ESP"
    params[:changed_language] = "EBR"
    params[:reason] = ""
    params[:license_guid] = "af2190de-fed0-4e93-81ae-b7aebebf8bef"
      returned_value = SupportUserPortal::LicensesController.new.create_product_language_log(update_lang_identifier_response, product_rights_guids_array, params)
    end
    assert_equal returned_value, {:notice => nil, :error => ["Reason can't be blank"]}
  end

  def test_create_product_language_log_for_invalid_product_lang_log_with_blank_new_lang
    SupportUserPortal::LicensesController.any_instance.expects(:current_user).returns(SupportLead.first)
    returned_value = {}
    params = Hash.new
    product_rights_guids_array = ["a456e046-4714-4247-a1a9-e58fa7d7b9bf","b4ecbdf2-8d4d-48f1-9b4d-b57fa2f91f4d","11e2d905-3224-4428-94f1-4f10e5b57ea2"]
    assert_no_difference "ProductLanguageLog.all.size" do
    params[:previous_language] = "ESP"
    params[:changed_language] = ""
    params[:reason] = "test"
    params[:license_guid] = "af2190de-fed0-4e93-81ae-b7aebebf8bef"
    changed_pr_response = update_lang_identifier_response
    changed_pr_response[0][:response][0]["product_identifier"] = ""
      returned_value = SupportUserPortal::LicensesController.new.create_product_language_log(changed_pr_response, product_rights_guids_array, params)
    end
    assert_equal returned_value, {:notice => nil, :error => ["New language can't be blank"]}
  end

  def test_create_product_language_log_for_valid_product_lang_log
    SupportUserPortal::LicensesController.any_instance.expects(:current_user).returns(SupportLead.first)
    returned_value = {}
    params = Hash.new
    product_rights_guids_array = ["a456e046-4714-4247-a1a9-e58fa7d7b9bf","b4ecbdf2-8d4d-48f1-9b4d-b57fa2f91f4d","11e2d905-3224-4428-94f1-4f10e5b57ea2"]
    assert_difference "ProductLanguageLog.all.size" do
    params[:previous_language] = "ESP"
    params[:changed_language] = "EBR"
    params[:reason] = "test"
    params[:license_guid] = "af2190de-fed0-4e93-81ae-b7aebebf8bef"
      returned_value = SupportUserPortal::LicensesController.new.create_product_language_log(update_lang_identifier_response, product_rights_guids_array, params)
    end
    assert_equal returned_value, {:notice => "Language modified successfully.", :error => nil}
  end

  def test_license_server_exception_rescued_in_modify_language
    product_rights_guids_array = ["5fc6bf24-b008-4f28-8608-5157333d5fd9"]
    RosettaStone::ActiveLicensing::License.any_instance.stubs(:product_rights).raises(RosettaStone::ActiveLicensing::CallException.new({:successful_responses => 'license server throws some exception.', :original_exception => "RosettaStone::ActiveLicensing::AvailableProductNotFound"}))
    SupportUserPortal::LicensesController.any_instance.expects(:create_product_language_log).never
    Eschool::Student.stubs(:cancel_future_sessions).returns(nil)
    response = post :modify_language, :product_rights_guids => product_rights_guids_array, :changed_language => "EBR", :reason => "test", :previous_language => "POL", :license_guid => "086ad0e3-1496-4610-84c2-9c25699cc93f"
    assert_response :redirect
    assert_redirected_to(show_learner_profile_and_license_information_path(:license_guid => "086ad0e3-1496-4610-84c2-9c25699cc93f"))
    assert_equal  flash[:error], "Product Identifier not updated in License Server."
  end

  def test_other_exceptions_rescued_in_modify_language
    product_rights_guids_array = ["5fc6bf24-b008-4f28-8608-5157333d5fd9"]
    SupportUserPortal::LicensesController.any_instance.stubs(:license_server_api_call).raises(Exception.new("Not License Server Exception"))
    SupportUserPortal::LicensesController.any_instance.expects(:create_product_language_log).never
    Eschool::Student.stubs(:cancel_future_sessions).returns(nil)
    response = post :modify_language, :product_rights_guids => product_rights_guids_array, :changed_language => "EBR", :reason => "test", :previous_language => "POL", :license_guid => "086ad0e3-1496-4610-84c2-9c25699cc93f"
    assert_response :redirect
    assert_redirected_to(show_learner_profile_and_license_information_path(:license_guid => "086ad0e3-1496-4610-84c2-9c25699cc93f"))
    assert_equal  flash[:error], "Something went wrong. Not able to process langauge modify request."
  end

  def test_license_info_page_to_see_that_modify_language_is_not_seen_for_reflex_community_active_learner
    learner = Learner.create({:first_name => "CSP", :last_name => "Content Range", :email => "csp@content.range", :guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef", :user_source_type => "Community::User", :totale => true, :rworld => true, :osub => false, :osub_active => false, :totale_active => false, :enterprise_license_active => false, :parature_customer => false, :previous_license_identifiers => nil, :created_at => "2011-12-01 20:45:05", :updated_at => "2011-12-16 19:24:22"})
    learner.save
    stub_license_server_and_community_for_reflex_license_info
    get :license_info,{:license_guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef"}
    assert_select 'input#modify_language', :count => 0
  end

  def test_license_info_page_to_see_that_modify_language_is_seen_for_tosub_community_active_learner
    learner = Learner.create({:first_name => "CSP", :last_name => "Content Range", :email => "csp@content.range", :guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef", :user_source_type => "Community::User", :totale => true, :rworld => true, :osub => false, :osub_active => false, :totale_active => false, :enterprise_license_active => false, :parature_customer => false, :previous_license_identifiers => nil, :created_at => "2011-12-01 20:45:05", :updated_at => "2011-12-16 19:24:22"})
    learner.save
    stub_license_server_and_community_for_tosub_license_info_with_one_esp_product
    stub_lcdb
    get :license_info,{:license_guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef"}
    assert_select 'input#modify_language', :count => 1
  end

  def test_license_info_page_to_see_that_modify_language_is_not_seen_for_tosub_institutional_active_learner
    learner = Learner.create({:first_name => "CSP", :last_name => "Content Range", :email => "csp@content.range", :guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef", :user_source_type => "Rs:Manager", :totale => true, :rworld => true, :osub => false, :osub_active => false, :totale_active => false, :enterprise_license_active => false, :parature_customer => false, :previous_license_identifiers => nil, :created_at => "2011-12-01 20:45:05", :updated_at => "2011-12-16 19:24:22"})
    learner.save
    stub_license_server_and_community_for_tosub_license_info_with_one_esp_product
    stub_lcdb
    get :license_info,{:license_guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef"}
    assert_select 'input#modify_language', :count => 0
  end

  def test_license_info_page_to_see_that_modify_language_is_not_seen_for_totale_institutional_active_learner
    learner = Learner.create({:first_name => "CSP", :last_name => "Content Range", :email => "csp@content.range", :guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef", :user_source_type => "Rs:Manager", :totale => true, :rworld => true, :osub => false, :osub_active => false, :totale_active => false, :enterprise_license_active => false, :parature_customer => false, :previous_license_identifiers => nil, :created_at => "2011-12-01 20:45:05", :updated_at => "2011-12-16 19:24:22"})
    learner.save
    stub_license_server_and_community_for_totale_license_info_with_one_esp_product
    stub_lcdb
    get :license_info,{:license_guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef"}
    assert_select 'input#modify_language', :count => 0
  end

  def test_license_info_page_to_see_that_modify_language_is_not_seen_for_totale_community_active_learner
    learner = Learner.create({:first_name => "CSP", :last_name => "Content Range", :email => "csp@content.range", :guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef", :user_source_type => "Community::User", :totale => true, :rworld => true, :osub => false, :osub_active => false, :totale_active => false, :enterprise_license_active => false, :parature_customer => false, :previous_license_identifiers => nil, :created_at => "2011-12-01 20:45:05", :updated_at => "2011-12-16 19:24:22"})
    learner.save
    stub_license_server_and_community_for_totale_license_info_with_one_esp_product
    stub_lcdb
    get :license_info,{:license_guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef"}
    assert_select 'input#modify_language', :count => 0
  end

  def test_license_info_page_to_see_that_modify_language_is_not_seen_for_tosub_community_inactive_learner
    learner = Learner.create({:first_name => "CSP", :last_name => "Content Range", :email => "csp@content.range", :guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef", :user_source_type => "Community::User", :totale => true, :rworld => true, :osub => false, :osub_active => false, :totale_active => false, :enterprise_license_active => false, :parature_customer => false, :previous_license_identifiers => nil, :created_at => "2011-12-01 20:45:05", :updated_at => "2011-12-16 19:24:22"})
    learner.save
    stub_license_server_and_community_for_tosub_inactive_license_info_with_one_esp_product
    stub_lcdb
    get :license_info,{:license_guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef"}
    assert_select 'input#modify_language', :count => 0
  end

  def test_license_info_page_to_see_that_modify_language_is_not_seen_for_concierge_user
    login_as_custom_user(AdGroup.support_concierge_user, 'test21')
    learner = Learner.create({:first_name => "CSP", :last_name => "Content Range", :email => "csp@content.range", :guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef", :user_source_type => "Community::User", :totale => true, :rworld => true, :osub => false, :osub_active => false, :totale_active => false, :enterprise_license_active => false, :parature_customer => false, :previous_license_identifiers => nil, :created_at => "2011-12-01 20:45:05", :updated_at => "2011-12-16 19:24:22"})
    learner.save
    stub_license_server_and_community_for_tosub_license_info_with_one_esp_product
    stub_lcdb
    get :license_info,{:license_guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef"}
    assert_select 'input#modify_language', :count => 0
  end

  def test_calculate_new_end_date
    new_end_date = SupportUserPortal::LicensesController.new.send(:calculate_new_end_date,Time.now.to_date,"1m")
    test_date =  Time.now.to_date+1.month
    assert_equal test_date, new_end_date, "the count of the month should increase by 30 days"
    new_end_date = SupportUserPortal::LicensesController.new.send(:calculate_new_end_date,Time.now.to_date,"1d")
    test_date =  Time.now.to_date+1.day
    assert_equal test_date, new_end_date, "the count of the month should increase by 1 day"
    new_end_date = SupportUserPortal::LicensesController.new.send(:calculate_new_end_date,Time.now.to_date,Time.now.to_date.to_s)
    test_date =  Time.now.to_date
    assert_equal test_date, new_end_date, "it should return the same date"
  end

  def test_end_date_calculation
    response = get :end_date_calculation,{:original_end_date => "09-07-2020", :duration => "1m" }
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "08/09/2020", body["date"]
  end
  
  private

  def stub_license_server_and_community_for_license_info
    RosettaStone::ActiveLicensing::License.any_instance.stubs(:details).returns({"created_at"=>"Wed Nov 30 19:54:29 +0530 2011".to_datetime, "guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "usable"=>true, "demo"=>false, "creation_account_identifier"=>"OSUBs", "creation_account_guid"=>"048f539c-7d13-102d-9b5a-f03c5d1f8336", "identifier"=>"csp@content.range", "test"=>true, "active"=>true})
    RosettaStone::ActiveLicensing::License.any_instance.stubs(:product_rights).returns([{"product_family"=>"application", "created_at"=> "Wed Nov 30 19:54:58 +0530 2011".to_datetime, "guid"=>"a456e046-4714-4247-a1a9-e58fa7d7b9bf", "unextended_ends_at"=>"Wed Apr 11 19:15:03 +0530 2012".to_datetime, "starts_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "license"=>{"guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "identifier"=>"csp@content.range"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Wed Apr 11 19:15:03 +0530 2012".to_datetime, "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"4", "created_at"=>"1314835200", "guid"=>"f9865fdf-309c-4ec2-938c-3cdcf50d6ed3", "updated_at"=>"1314835200", "activation_id"=>nil, "min_unit"=>"1"}, {"max_unit"=>"8", "created_at"=>"1317427200", "guid"=>"27ad98e9-813e-4379-b882-e270b57df8fe", "updated_at"=>"1317427200", "activation_id"=>nil, "min_unit"=>"5"}, {"max_unit"=>"12", "created_at"=>"1322663808", "guid"=>"fae27ec0-e375-4aeb-a91e-3f89f907dad8", "updated_at"=>"1322663808", "activation_id"=>nil, "min_unit"=>"1"}]}, {"product_family"=>"eschool", "created_at"=>"Wed Nov 30 19:55:13 +0530 2011".to_datetime, "guid"=>"b4ecbdf2-8d4d-48f1-9b4d-b57fa2f91f4d", "unextended_ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "starts_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "license"=>{"guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "identifier"=>"csp@content.range"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"4", "created_at"=>"1314835200", "guid"=>"43425c0b-cbff-43c8-bf14-d6c07f0693f8", "updated_at"=>"1314835200", "activation_id"=>nil, "min_unit"=>"1"}, {"max_unit"=>"8", "created_at"=>"1317427200", "guid"=>"e6a95d93-f8b1-4d93-b2e2-0ba3b660e74e", "updated_at"=>"1317427200", "activation_id"=>nil, "min_unit"=>"5"}, {"max_unit"=>"12", "created_at"=>"1322663822", "guid"=>"43d13237-6c5d-4589-b806-f8bdf97057e8", "updated_at"=>"1322663822", "activation_id"=>nil, "min_unit"=>"1"}]}, {"product_family"=>"premium_community", "created_at"=>"Wed Nov 30 19:55:24 +0530 2011".to_datetime, "guid"=>"11e2d905-3224-4428-94f1-4f10e5b57ea2", "unextended_ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "starts_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "license"=>{"guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "identifier"=>"csp@content.range"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"4", "created_at"=>"1314835200", "guid"=>"9964fb81-13b3-4e6f-858d-3a9c958d28f1", "updated_at"=>"1314835200", "activation_id"=>nil, "min_unit"=>"1"}, {"max_unit"=>"8", "created_at"=>"1317427200", "guid"=>"79e72631-6c92-4b06-b147-9e7cec9873aa", "updated_at"=>"1317427200", "activation_id"=>nil, "min_unit"=>"5"}, {"max_unit"=>"12", "created_at"=>"1322663851", "guid"=>"9a0e8db2-441c-435e-9806-bc46d2c259fa", "updated_at"=>"1322663851", "activation_id"=>nil, "min_unit"=>"1"}]}])
    RosettaStone::ActiveLicensing::CreationAccount.any_instance.stubs(:details).returns({"access_ends_at"=>nil, "created_at"=>"Tue May 22 13:53:34 +0530 2007".to_datetime, "guid"=>"048f539c-7d13-102d-9b5a-f03c5d1f8336", "maximum_active_licenses"=>nil, "master_license_guid"=>nil, "demo"=>false, "type"=>"online_subscription", "configuration_ends_at"=>"Thu Jan 01 05:30:00 +0530 2037".to_datetime, "identifier"=>"OSUBs", "test"=>false, "maximum_product_rights_per_license"=>nil})
    RosettaStone::ActiveLicensing::ProductRight.any_instance.stubs(:extensions).returns([{"duration"=>"1m", "created_at"=>"Fri Dec 16 02:53:00 +0530 2011".to_datetime, "guid"=>"75fc8294-f0b6-464c-9105-bfa6fa1cba09", "extended_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "claim_by"=>"Mon Dec 16 02:53:00 +0530 2013".to_datetime, "activation_id"=>"Test"}, {"duration"=>"1m", "created_at"=>"Fri Dec 16 02:55:00 +0530 2011".to_datetime, "guid"=>"e9ffa8fa-b2a3-4f02-b4d7-e6c5d8e05883", "extended_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "claim_by"=>"Mon Dec 16 02:55:00 +0530 2013".to_datetime, "activation_id"=>"test"}])
    user = Dupe.create :user
    language = {"identifier" => 'ESP'}
    Community::User.stubs(:find_by_guid).returns(user)
  end

  def stub_license_server_and_community_for_tosub_license_info_with_one_esp_product
    RosettaStone::ActiveLicensing::License.any_instance.stubs(:details).returns({"created_at"=>"Wed Nov 30 19:54:29 +0530 2011".to_datetime, "guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "usable"=>true, "demo"=>false, "creation_account_identifier"=>"OSUBs", "creation_account_guid"=>"048f539c-7d13-102d-9b5a-f03c5d1f8336", "identifier"=>"csp@content.range", "test"=>true, "active"=>true})
    RosettaStone::ActiveLicensing::License.any_instance.stubs(:product_rights).returns([{"product_family"=>"application", "created_at"=> "Wed Nov 30 19:54:58 +0530 2011".to_datetime, "guid"=>"a456e046-4714-4247-a1a9-e58fa7d7b9bf", "unextended_ends_at"=>"Wed Apr 11 19:15:03 +0530 2012".to_datetime, "starts_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "license"=>{"guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "identifier"=>"csp@content.range"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Wed Apr 11 19:15:03 +0530 2012".to_datetime, "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"12", "created_at"=>"1322663808", "guid"=>"fae27ec0-e375-4aeb-a91e-3f89f907dad8", "updated_at"=>"1322663808", "activation_id"=>nil, "min_unit"=>"1"}]}, 
                                                                                        {"product_family"=>"eschool", "created_at"=>"Wed Nov 30 19:55:13 +0530 2011".to_datetime, "guid"=>"b4ecbdf2-8d4d-48f1-9b4d-b57fa2f91f4d", "unextended_ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "starts_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "license"=>{"guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "identifier"=>"csp@content.range"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"12", "created_at"=>"1322663822", "guid"=>"43d13237-6c5d-4589-b806-f8bdf97057e8", "updated_at"=>"1322663822", "activation_id"=>nil, "min_unit"=>"1"}]},
                                                                                        {"product_family"=>"premium_community", "created_at"=>"Wed Nov 30 19:55:24 +0530 2011".to_datetime, "guid"=>"11e2d905-3224-4428-94f1-4f10e5b57ea2", "unextended_ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "starts_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "license"=>{"guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "identifier"=>"csp@content.range"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"12", "created_at"=>"1322663851", "guid"=>"9a0e8db2-441c-435e-9806-bc46d2c259fa", "updated_at"=>"1322663851", "activation_id"=>nil, "min_unit"=>"1"}]}])
    RosettaStone::ActiveLicensing::CreationAccount.any_instance.stubs(:details).returns({"access_ends_at"=>nil, "created_at"=>"Tue May 22 13:53:34 +0530 2007".to_datetime, "guid"=>"048f539c-7d13-102d-9b5a-f03c5d1f8336", "maximum_active_licenses"=>nil, "master_license_guid"=>nil, "demo"=>false, "type"=>"online_subscription", "configuration_ends_at"=>"Thu Jan 01 05:30:00 +0530 2037".to_datetime, "identifier"=>"OSUBs", "test"=>false, "maximum_product_rights_per_license"=>nil})
    RosettaStone::ActiveLicensing::ProductRight.any_instance.stubs(:extensions).returns([{"duration"=>"1m", "created_at"=>"Fri Dec 16 02:53:00 +0530 2011".to_datetime, "guid"=>"75fc8294-f0b6-464c-9105-bfa6fa1cba09", "extended_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "claim_by"=>"Mon Dec 16 02:53:00 +0530 2013".to_datetime, "activation_id"=>"Test"}, {"duration"=>"1m", "created_at"=>"Fri Dec 16 02:55:00 +0530 2011".to_datetime, "guid"=>"e9ffa8fa-b2a3-4f02-b4d7-e6c5d8e05883", "extended_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "claim_by"=>"Mon Dec 16 02:55:00 +0530 2013".to_datetime, "activation_id"=>"test"}])
    user = Dupe.create :user
    language = {"identifier" => 'ESP'}
    Community::User.stubs(:find_by_guid).returns(user)
  end

  def stub_license_server_and_community_for_totale_license_info_with_one_esp_product
    RosettaStone::ActiveLicensing::License.any_instance.stubs(:details).returns({"created_at"=>"Wed Nov 30 19:54:29 +0530 2011".to_datetime, "guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "usable"=>true, "demo"=>false, "creation_account_identifier"=>"OSUBs", "creation_account_guid"=>"048f539c-7d13-102d-9b5a-f03c5d1f8336", "identifier"=>"csp@content.range", "test"=>true, "active"=>true})
    RosettaStone::ActiveLicensing::License.any_instance.stubs(:product_rights).returns([{"product_family"=>"application", "created_at"=> "Wed Nov 30 19:54:58 +0530 2011".to_datetime, "guid"=>"a456e046-4714-4247-a1a9-e58fa7d7b9bf", "unextended_ends_at"=>"Wed Apr 11 19:15:03 +0530 2012".to_datetime, "starts_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "license"=>{"guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "identifier"=>"csp@content.range"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Wed Apr 11 19:15:03 +0530 2012".to_datetime, "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"12", "created_at"=>"1322663808", "guid"=>"fae27ec0-e375-4aeb-a91e-3f89f907dad8", "updated_at"=>"1322663808", "activation_id"=>nil, "min_unit"=>"1"}]},
                                                                                        {"product_family"=>"eschool", "created_at"=>"Wed Nov 30 19:55:13 +0530 2011".to_datetime, "guid"=>"b4ecbdf2-8d4d-48f1-9b4d-b57fa2f91f4d", "unextended_ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "starts_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "license"=>{"guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "identifier"=>"csp@content.range"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"12", "created_at"=>"1322663822", "guid"=>"43d13237-6c5d-4589-b806-f8bdf97057e8", "updated_at"=>"1322663822", "activation_id"=>nil, "min_unit"=>"1"}]},
                                                                                        {"product_family"=>"premium_community", "created_at"=>"Wed Nov 30 19:55:24 +0530 2011".to_datetime, "guid"=>"11e2d905-3224-4428-94f1-4f10e5b57ea2", "unextended_ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "starts_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "license"=>{"guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "identifier"=>"csp@content.range"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"12", "created_at"=>"1322663851", "guid"=>"9a0e8db2-441c-435e-9806-bc46d2c259fa", "updated_at"=>"1322663851", "activation_id"=>nil, "min_unit"=>"1"}]}])
    RosettaStone::ActiveLicensing::CreationAccount.any_instance.stubs(:details).returns({"access_ends_at"=>nil, "created_at"=>"Tue May 22 13:53:34 +0530 2007".to_datetime, "guid"=>"048f539c-7d13-102d-9b5a-f03c5d1f8336", "maximum_active_licenses"=>nil, "master_license_guid"=>nil, "demo"=>false, "type"=>"family", "configuration_ends_at"=>"Thu Jan 01 05:30:00 +0530 2037".to_datetime, "identifier"=>"OSUBs", "test"=>false, "maximum_product_rights_per_license"=>nil})
    RosettaStone::ActiveLicensing::ProductRight.any_instance.stubs(:extensions).returns([{"duration"=>"1m", "created_at"=>"Fri Dec 16 02:53:00 +0530 2011".to_datetime, "guid"=>"75fc8294-f0b6-464c-9105-bfa6fa1cba09", "extended_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "claim_by"=>"Mon Dec 16 02:53:00 +0530 2013".to_datetime, "activation_id"=>"Test"}, {"duration"=>"1m", "created_at"=>"Fri Dec 16 02:55:00 +0530 2011".to_datetime, "guid"=>"e9ffa8fa-b2a3-4f02-b4d7-e6c5d8e05883", "extended_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "claim_by"=>"Mon Dec 16 02:55:00 +0530 2013".to_datetime, "activation_id"=>"test"}])
    user = Dupe.create :user
    language = {"identifier" => 'ESP'}
    Community::User.stubs(:find_by_guid).returns(user)
  end

  def stub_license_server_and_community_for_tosub_inactive_license_info_with_one_esp_product
    RosettaStone::ActiveLicensing::License.any_instance.stubs(:details).returns({"created_at"=>"Wed Nov 30 19:54:29 +0530 2011".to_datetime, "guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "usable"=>true, "demo"=>false, "creation_account_identifier"=>"OSUBs", "creation_account_guid"=>"048f539c-7d13-102d-9b5a-f03c5d1f8336", "identifier"=>"csp@content.range", "test"=>true, "active"=>false})
    RosettaStone::ActiveLicensing::License.any_instance.stubs(:product_rights).returns([{"product_family"=>"application", "created_at"=> "Wed Nov 30 19:54:58 +0530 2011".to_datetime, "guid"=>"a456e046-4714-4247-a1a9-e58fa7d7b9bf", "unextended_ends_at"=>"Wed Apr 11 19:15:03 +0530 2012".to_datetime, "starts_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "license"=>{"guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "identifier"=>"csp@content.range"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Wed Apr 11 19:15:03 +0530 2012".to_datetime, "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"12", "created_at"=>"1322663808", "guid"=>"fae27ec0-e375-4aeb-a91e-3f89f907dad8", "updated_at"=>"1322663808", "activation_id"=>nil, "min_unit"=>"1"}]},
                                                                                        {"product_family"=>"eschool", "created_at"=>"Wed Nov 30 19:55:13 +0530 2011".to_datetime, "guid"=>"b4ecbdf2-8d4d-48f1-9b4d-b57fa2f91f4d", "unextended_ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "starts_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "license"=>{"guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "identifier"=>"csp@content.range"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"12", "created_at"=>"1322663822", "guid"=>"43d13237-6c5d-4589-b806-f8bdf97057e8", "updated_at"=>"1322663822", "activation_id"=>nil, "min_unit"=>"1"}]},
                                                                                        {"product_family"=>"premium_community", "created_at"=>"Wed Nov 30 19:55:24 +0530 2011".to_datetime, "guid"=>"11e2d905-3224-4428-94f1-4f10e5b57ea2", "unextended_ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "starts_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "license"=>{"guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "identifier"=>"csp@content.range"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"12", "created_at"=>"1322663851", "guid"=>"9a0e8db2-441c-435e-9806-bc46d2c259fa", "updated_at"=>"1322663851", "activation_id"=>nil, "min_unit"=>"1"}]}])
    RosettaStone::ActiveLicensing::CreationAccount.any_instance.stubs(:details).returns({"access_ends_at"=>nil, "created_at"=>"Tue May 22 13:53:34 +0530 2007".to_datetime, "guid"=>"048f539c-7d13-102d-9b5a-f03c5d1f8336", "maximum_active_licenses"=>nil, "master_license_guid"=>nil, "demo"=>false, "type"=>"online_subscription", "configuration_ends_at"=>"Thu Jan 01 05:30:00 +0530 2037".to_datetime, "identifier"=>"OSUBs", "test"=>false, "maximum_product_rights_per_license"=>nil})
    RosettaStone::ActiveLicensing::ProductRight.any_instance.stubs(:extensions).returns([{"duration"=>"1m", "created_at"=>"Fri Dec 16 02:53:00 +0530 2011".to_datetime, "guid"=>"75fc8294-f0b6-464c-9105-bfa6fa1cba09", "extended_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "claim_by"=>"Mon Dec 16 02:53:00 +0530 2013".to_datetime, "activation_id"=>"Test"}, {"duration"=>"1m", "created_at"=>"Fri Dec 16 02:55:00 +0530 2011".to_datetime, "guid"=>"e9ffa8fa-b2a3-4f02-b4d7-e6c5d8e05883", "extended_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "claim_by"=>"Mon Dec 16 02:55:00 +0530 2013".to_datetime, "activation_id"=>"test"}])
    user = Dupe.create :user
    language = {"identifier" => 'ESP'}
    Community::User.stubs(:find_by_guid).returns(user)
  end

   def stub_license_server_and_community_for_reflex_license_info
    RosettaStone::ActiveLicensing::License.any_instance.stubs(:details).returns({"created_at"=>"Wed Nov 30 19:54:29 +0530 2011".to_datetime, "guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "usable"=>true, "demo"=>false, "creation_account_identifier"=>"OSUBs", "creation_account_guid"=>"048f539c-7d13-102d-9b5a-f03c5d1f8336", "identifier"=>"csp@content.range", "test"=>true, "active"=>true})
    RosettaStone::ActiveLicensing::License.any_instance.stubs(:product_rights).returns([{"product_family"=>"lotus", "created_at"=> "Wed Nov 30 19:54:58 +0530 2011".to_datetime, "guid"=>"a456e046-4714-4247-a1a9-e58fa7d7b9bf", "unextended_ends_at"=>"Wed Apr 11 19:15:03 +0530 2012".to_datetime, "starts_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime,
                                                                                        "license"=>{"guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "identifier"=>"csp@content.range"},
                                                                                         "usable"=>true, "product_identifier"=>"JLE", "activation_id"=>nil, "ends_at"=>"Wed Apr 11 19:15:03 +0530 2012".to_datetime, "product_version"=>"3",
                                                                                         "content_ranges"=>[]}])
    RosettaStone::ActiveLicensing::CreationAccount.any_instance.stubs(:details).returns({"access_ends_at"=>nil, "created_at"=>"Tue May 22 13:53:34 +0530 2007".to_datetime, "guid"=>"048f539c-7d13-102d-9b5a-f03c5d1f8336", "maximum_active_licenses"=>nil, "master_license_guid"=>nil, "demo"=>false, "type"=>"online_subscription", "configuration_ends_at"=>"Thu Jan 01 05:30:00 +0530 2037".to_datetime, "identifier"=>"OSUBs", "test"=>false, "maximum_product_rights_per_license"=>nil})
    RosettaStone::ActiveLicensing::ProductRight.any_instance.stubs(:extensions).returns([{"duration"=>"1m", "created_at"=>"Fri Dec 16 02:53:00 +0530 2011".to_datetime, "guid"=>"75fc8294-f0b6-464c-9105-bfa6fa1cba09", "extended_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "claim_by"=>"Mon Dec 16 02:53:00 +0530 2013".to_datetime, "activation_id"=>"Test"}, {"duration"=>"1m", "created_at"=>"Fri Dec 16 02:55:00 +0530 2011".to_datetime, "guid"=>"e9ffa8fa-b2a3-4f02-b4d7-e6c5d8e05883", "extended_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "claim_by"=>"Mon Dec 16 02:55:00 +0530 2013".to_datetime, "activation_id"=>"test"}])
    user = Dupe.create :user
    language = {"identifier" => 'JLE'}
    Community::User.stubs(:find_by_guid).returns(user)
  end

  def stub_license_server_and_community_for_license_info_for_combined_page
    RosettaStone::ActiveLicensing::License.any_instance.stubs(:details).returns({"created_at"=>"Wed Nov 30 19:54:29 +0530 2011".to_datetime, "guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "usable"=>true, "demo"=>false, "creation_account_identifier"=>"OSUBs", "creation_account_guid"=>"048f539c-7d13-102d-9b5a-f03c5d1f8336", "identifier"=>"csp@content.range", "test"=>true, "active"=>true})
    RosettaStone::ActiveLicensing::License.any_instance.stubs(:product_rights).returns([{"product_family"=>"application", "created_at"=> "Wed Nov 30 19:54:58 +0530 2011".to_datetime, "guid"=>"a456e046-4714-4247-a1a9-e58fa7d7b9bf", "unextended_ends_at"=>"Wed Apr 11 19:15:03 +0530 2012".to_datetime, "starts_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "license"=>{"guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "identifier"=>"csp@content.range"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Wed Apr 11 19:15:03 +0530 2012".to_datetime, "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"4", "created_at"=>"1314835200", "guid"=>"f9865fdf-309c-4ec2-938c-3cdcf50d6ed3", "updated_at"=>"1314835200", "activation_id"=>nil, "min_unit"=>"1"}, {"max_unit"=>"8", "created_at"=>"1317427200", "guid"=>"27ad98e9-813e-4379-b882-e270b57df8fe", "updated_at"=>"1317427200", "activation_id"=>nil, "min_unit"=>"5"}, {"max_unit"=>"12", "created_at"=>"1322663808", "guid"=>"fae27ec0-e375-4aeb-a91e-3f89f907dad8", "updated_at"=>"1322663808", "activation_id"=>nil, "min_unit"=>"1"}]}, {"product_family"=>"eschool", "created_at"=>"Wed Nov 30 19:55:13 +0530 2011".to_datetime, "guid"=>"b4ecbdf2-8d4d-48f1-9b4d-b57fa2f91f4d", "unextended_ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "starts_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "license"=>{"guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "identifier"=>"csp@content.range"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"4", "created_at"=>"1314835200", "guid"=>"43425c0b-cbff-43c8-bf14-d6c07f0693f8", "updated_at"=>"1314835200", "activation_id"=>nil, "min_unit"=>"1"}, {"max_unit"=>"8", "created_at"=>"1317427200", "guid"=>"e6a95d93-f8b1-4d93-b2e2-0ba3b660e74e", "updated_at"=>"1317427200", "activation_id"=>nil, "min_unit"=>"5"}, {"max_unit"=>"12", "created_at"=>"1322663822", "guid"=>"43d13237-6c5d-4589-b806-f8bdf97057e8", "updated_at"=>"1322663822", "activation_id"=>nil, "min_unit"=>"1"}]}, {"product_family"=>"premium_community", "created_at"=>"Wed Nov 30 19:55:24 +0530 2011".to_datetime, "guid"=>"11e2d905-3224-4428-94f1-4f10e5b57ea2", "unextended_ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "starts_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "license"=>{"guid"=>"af2190de-fed0-4e93-81ae-b7aebebf8bef", "identifier"=>"csp@content.range"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Wed Apr 11 19:15:04 +0530 2012".to_datetime, "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"4", "created_at"=>"1314835200", "guid"=>"9964fb81-13b3-4e6f-858d-3a9c958d28f1", "updated_at"=>"1314835200", "activation_id"=>nil, "min_unit"=>"1"}, {"max_unit"=>"8", "created_at"=>"1317427200", "guid"=>"79e72631-6c92-4b06-b147-9e7cec9873aa", "updated_at"=>"1317427200", "activation_id"=>nil, "min_unit"=>"5"}, {"max_unit"=>"12", "created_at"=>"1322663851", "guid"=>"9a0e8db2-441c-435e-9806-bc46d2c259fa", "updated_at"=>"1322663851", "activation_id"=>nil, "min_unit"=>"1"}]}])
    RosettaStone::ActiveLicensing::CreationAccount.any_instance.stubs(:details).returns({"access_ends_at"=>nil, "created_at"=>"Tue May 22 13:53:34 +0530 2007".to_datetime, "guid"=>"048f539c-7d13-102d-9b5a-f03c5d1f8336", "maximum_active_licenses"=>nil, "master_license_guid"=>nil, "demo"=>false, "type"=>"online_subscription", "configuration_ends_at"=>"Thu Jan 01 05:30:00 +0530 2037".to_datetime, "identifier"=>"OSUBs", "test"=>false, "maximum_product_rights_per_license"=>nil})
    RosettaStone::ActiveLicensing::ProductRight.any_instance.stubs(:extensions).returns([{"duration"=>"1m", "created_at"=>"Fri Dec 16 02:53:00 +0530 2011".to_datetime, "guid"=>"75fc8294-f0b6-464c-9105-bfa6fa1cba09", "extended_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "claim_by"=>"Mon Dec 16 02:53:00 +0530 2013".to_datetime, "activation_id"=>"Test"}, {"duration"=>"1m", "created_at"=>"Fri Dec 16 02:55:00 +0530 2011".to_datetime, "guid"=>"e9ffa8fa-b2a3-4f02-b4d7-e6c5d8e05883", "extended_at"=>"Fri Dec 16 02:58:16 +0530 2011".to_datetime, "claim_by"=>"Mon Dec 16 02:55:00 +0530 2013".to_datetime, "activation_id"=>"test"}])
  end

  def login_as_support_conceirge_and_create_learner
    login_as_custom_user(AdGroup.support_concierge_user, 'test23')
    FactoryGirl.create(:learner, :guid => "af2190de-fed0-4e93-81ae-b7aebebf8bef")
  end

  def stub_lcdb
    response = mock("response");
    response.stubs(:customer).returns(true)
    SupportUserPortal::LicensesController.any_instance.stubs(:lcdb_get_customer_details).returns(response)
  end
  def stub_license_server
    RosettaStone::ActiveLicensing::License.any_instance.stubs(:product_rights).returns([{"product_family"=>"application", "created_at"=>"Wed May 16 10:58:12 +0530 2012", "guid"=>"55ca663e-ca39-4a9e-a0a0-7e02c506c20f", "unextended_ends_at"=>"Fri Jun 15 10:58:45 +0530 2012", "starts_at"=>"Wed May 16 10:58:45 +0530 2012", "license"=>{"guid"=>"cceec678-6243-4d8b-afa3-8136995c2106", "identifier"=>"listerleelaesplevel1learner@rs.com"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Sun Feb 10 10:58:45 +0530 2013", "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"4", "created_at"=>"1337146092", "guid"=>"acb82516-e34e-43e0-9f96-7a3da5ca8d4e", "updated_at"=>"1337146092", "activation_id"=>"22NN8L-HCN4K-3H6C8-EGDG5-LDY3G7D", "min_unit"=>"1"}]}, {"product_family"=>"eschool", "created_at"=>"Wed May 16 10:58:12 +0530 2012", "guid"=>"34c93597-67f6-4f48-b362-3b1ddb978e3e", "unextended_ends_at"=>"Fri Jun 15 10:58:45 +0530 2012", "starts_at"=>"Wed May 16 10:58:45 +0530 2012", "license"=>{"guid"=>"cceec678-6243-4d8b-afa3-8136995c2106", "identifier"=>"listerleelaesplevel1learner@rs.com"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Sun Feb 10 10:58:45 +0530 2013", "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"4", "created_at"=>"1337146092", "guid"=>"f108a854-8e00-4ea5-ace9-c61735f8e4b8", "updated_at"=>"1337146092", "activation_id"=>"22NN8L-HCN4K-3H6C8-EGDG5-LDY3G7D", "min_unit"=>"1"}]}, {"product_family"=>"premium_community", "created_at"=>"Wed May 16 10:58:12 +0530 2012", "guid"=>"76a70333-f4dc-46b7-a5aa-3e5edfcc9b21", "unextended_ends_at"=>"Fri Jun 15 10:58:45 +0530 2012", "starts_at"=>"Wed May 16 10:58:45 +0530 2012", "license"=>{"guid"=>"cceec678-6243-4d8b-afa3-8136995c2106", "identifier"=>"listerleelaesplevel1learner@rs.com"}, "usable"=>true, "product_identifier"=>"ESP", "activation_id"=>nil, "ends_at"=>"Sun Feb 10 10:58:45 +0530 2013", "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"4", "created_at"=>"1337146092", "guid"=>"02a33a11-fb0e-4b7a-b328-976bcc9c77cf", "updated_at"=>"1337146092", "activation_id"=>"22NN8L-HCN4K-3H6C8-EGDG5-LDY3G7D", "min_unit"=>"1"}]}])
    RosettaStone::ActiveLicensing::Base.any_instance.expects(:multicall).returns([{:method_name=>"find_by_activation_id", :api_category=>"product_right", :response=>[{"product_family"=>"eschool", "created_at"=>"Wed May 16 10:58:12 +0530 2012", "unextended_ends_at"=>"Fri Jun 15 10:58:45 +0530 2012", "guid"=>"34c93597-67f6-4f48-b362-3b1ddb978e3e", "license"=>{"guid"=>"cceec678-6243-4d8b-afa3-8136995c2106", "identifier"=>"listerleelaesplevel1learner@rs.com"}, "starts_at"=>"Wed May 16 10:58:45 +0530 2012", "usable"=>true, "product_identifier"=>"ESP", "ends_at"=>"Sun Feb 10 10:58:45 +0530 2013", "activation_id"=>nil, "content_ranges"=>{"content_range"=>{"max_unit"=>"4", "created_at"=>"1337146092", "guid"=>"f108a854-8e00-4ea5-ace9-c61735f8e4b8", "updated_at"=>"1337146092", "activation_id"=>"22NN8L-HCN4K-3H6C8-EGDG5-LDY3G7D", "min_unit"=>"1"}, "coalesced"=>"false"}, "product_version"=>"3"}, {"product_family"=>"application", "created_at"=>"Wed May 16 10:58:12 +0530 2012", "unextended_ends_at"=>"Fri Jun 15 10:58:45 +0530 2012", "guid"=>"55ca663e-ca39-4a9e-a0a0-7e02c506c20f", "license"=>{"guid"=>"cceec678-6243-4d8b-afa3-8136995c2106", "identifier"=>"listerleelaesplevel1learner@rs.com"}, "starts_at"=>"Wed May 16 10:58:45 +0530 2012", "usable"=>true, "product_identifier"=>"ESP", "ends_at"=>"Sun Feb 10 10:58:45 +0530 2013", "activation_id"=>nil, "content_ranges"=>{"content_range"=>{"max_unit"=>"4", "created_at"=>"1337146092", "guid"=>"acb82516-e34e-43e0-9f96-7a3da5ca8d4e", "updated_at"=>"1337146092", "activation_id"=>"22NN8L-HCN4K-3H6C8-EGDG5-LDY3G7D", "min_unit"=>"1"}, "coalesced"=>"false"}, "product_version"=>"3"}, {"product_family"=>"premium_community", "created_at"=>"Wed May 16 10:58:12 +0530 2012", "unextended_ends_at"=>"Fri Jun 15 10:58:45 +0530 2012", "guid"=>"76a70333-f4dc-46b7-a5aa-3e5edfcc9b21", "license"=>{"guid"=>"cceec678-6243-4d8b-afa3-8136995c2106", "identifier"=>"listerleelaesplevel1learner@rs.com"}, "starts_at"=>"Wed May 16 10:58:45 +0530 2012", "usable"=>true, "product_identifier"=>"ESP", "ends_at"=>"Sun Feb 10 10:58:45 +0530 2013", "activation_id"=>nil, "content_ranges"=>{"content_range"=>{"max_unit"=>"4", "created_at"=>"1337146092", "guid"=>"02a33a11-fb0e-4b7a-b328-976bcc9c77cf", "updated_at"=>"1337146092", "activation_id"=>"22NN8L-HCN4K-3H6C8-EGDG5-LDY3G7D", "min_unit"=>"1"}, "coalesced"=>"false"}, "product_version"=>"3"}, {"product_family"=>"application", "created_at"=>"Wed May 16 12:40:52 +0530 2012", "unextended_ends_at"=>"Fri Jun 15 13:02:14 +0530 2012", "guid"=>"8c8f7fca-3566-4f51-966a-a27b2a40f5a4", "license"=>{"guid"=>"b8daf16e-57fa-4a00-9ae5-6039605618c7", "identifier"=>"listerleelaesplevel1learner@rs.com.kid1"}, "starts_at"=>"Wed May 16 13:02:15 +0530 2012", "usable"=>true, "product_identifier"=>"ESP", "ends_at"=>"Sun Feb 10 13:02:14 +0530 2013", "activation_id"=>nil, "content_ranges"=>{"content_range"=>{"max_unit"=>"4", "created_at"=>"1337152252", "guid"=>"1be07705-51c8-4e9d-befd-a6e35344aa8b", "updated_at"=>"1337152252", "activation_id"=>"22NN8L-HCN4K-3H6C8-EGDG5-LDY3G7D", "min_unit"=>"1"}, "coalesced"=>"false"}, "product_version"=>"3"}, {"product_family"=>"eschool", "created_at"=>"Wed May 16 12:40:52 +0530 2012", "unextended_ends_at"=>"Fri Jun 15 13:02:14 +0530 2012", "guid"=>"425dfecb-6fcd-43ef-b74e-9a4de8abdff3", "license"=>{"guid"=>"b8daf16e-57fa-4a00-9ae5-6039605618c7", "identifier"=>"listerleelaesplevel1learner@rs.com.kid1"}, "starts_at"=>"Wed May 16 13:02:14 +0530 2012", "usable"=>true, "product_identifier"=>"ESP", "ends_at"=>"Sun Feb 10 13:02:14 +0530 2013", "activation_id"=>nil, "content_ranges"=>{"content_range"=>{"max_unit"=>"4", "created_at"=>"1337152252", "guid"=>"511a7ef0-c7c0-4e52-86aa-ab3ffa358964", "updated_at"=>"1337152252", "activation_id"=>"22NN8L-HCN4K-3H6C8-EGDG5-LDY3G7D", "min_unit"=>"1"}, "coalesced"=>"false"}, "product_version"=>"3"}, {"product_family"=>"premium_community", "created_at"=>"Wed May 16 12:40:52 +0530 2012", "unextended_ends_at"=>"Fri Jun 15 13:02:14 +0530 2012", "guid"=>"f5cbda61-cd19-4fba-bb53-12f03a2e3bdb", "license"=>{"guid"=>"b8daf16e-57fa-4a00-9ae5-6039605618c7", "identifier"=>"listerleelaesplevel1learner@rs.com.kid1"}, "starts_at"=>"Wed May 16 13:02:14 +0530 2012", "usable"=>true, "product_identifier"=>"ESP", "ends_at"=>"Sun Feb 10 13:02:14 +0530 2013", "activation_id"=>nil, "content_ranges"=>{"content_range"=>{"max_unit"=>"4", "created_at"=>"1337152252", "guid"=>"3335cfcc-e36d-4b22-8728-ed0c1e46d1e6", "updated_at"=>"1337152252", "activation_id"=>"22NN8L-HCN4K-3H6C8-EGDG5-LDY3G7D", "min_unit"=>"1"}, "coalesced"=>"false"}, "product_version"=>"3"}, {"product_family"=>"application", "created_at"=>"Mon May 21 10:37:46 +0530 2012", "unextended_ends_at"=>"Mon May 21 10:37:46 +0530 2012", "guid"=>"bd43dc74-3467-40d3-88c4-1fc06aba8482", "license"=>{"guid"=>"f9fce669-b50c-4758-ae14-0f2face533f9", "identifier"=>"listerleelaesplevel1learner@rs.com.kid2"}, "starts_at"=>"Mon May 21 10:37:46 +0530 2012", "usable"=>false, "product_identifier"=>"ESP", "ends_at"=>"Mon May 21 10:37:46 +0530 2012", "activation_id"=>nil, "content_ranges"=>{"content_range"=>{"max_unit"=>"4", "created_at"=>"1337576866", "guid"=>"b8c674be-9468-4bce-a413-107b8fefe1ef", "updated_at"=>"1337576866", "activation_id"=>"22NN8L-HCN4K-3H6C8-EGDG5-LDY3G7D", "min_unit"=>"1"}, "coalesced"=>"false"}, "product_version"=>"3"}, {"product_family"=>"eschool", "created_at"=>"Mon May 21 10:37:46 +0530 2012", "unextended_ends_at"=>"Mon May 21 10:37:46 +0530 2012", "guid"=>"7ebc6693-6928-4a95-9d84-9342e8a71370", "license"=>{"guid"=>"f9fce669-b50c-4758-ae14-0f2face533f9", "identifier"=>"listerleelaesplevel1learner@rs.com.kid2"}, "starts_at"=>"Mon May 21 10:37:46 +0530 2012", "usable"=>false, "product_identifier"=>"ESP", "ends_at"=>"Mon May 21 10:37:46 +0530 2012", "activation_id"=>nil, "content_ranges"=>{"content_range"=>{"max_unit"=>"4", "created_at"=>"1337576866", "guid"=>"cddde47e-3e22-443e-a553-1f528db3196d", "updated_at"=>"1337576866", "activation_id"=>"22NN8L-HCN4K-3H6C8-EGDG5-LDY3G7D", "min_unit"=>"1"}, "coalesced"=>"false"}, "product_version"=>"3"}, {"product_family"=>"premium_community", "created_at"=>"Mon May 21 10:37:46 +0530 2012", "unextended_ends_at"=>"Mon May 21 10:37:46 +0530 2012", "guid"=>"856e3a0c-42f0-4322-a8d8-1c985571087a", "license"=>{"guid"=>"f9fce669-b50c-4758-ae14-0f2face533f9", "identifier"=>"listerleelaesplevel1learner@rs.com.kid2"}, "starts_at"=>"Mon May 21 10:37:46 +0530 2012", "usable"=>false, "product_identifier"=>"ESP", "ends_at"=>"Mon May 21 10:37:46 +0530 2012", "activation_id"=>nil, "content_ranges"=>{"content_range"=>{"max_unit"=>"4", "created_at"=>"1337576866", "guid"=>"9580981b-a767-4c18-bcac-2a8373040f96", "updated_at"=>"1337576866", "activation_id"=>"22NN8L-HCN4K-3H6C8-EGDG5-LDY3G7D", "min_unit"=>"1"}, "coalesced"=>"false"}, "product_version"=>"3"}]}])
    RosettaStone::ActiveLicensing::ProductRight.any_instance.stubs(:find_by_activation_id).returns([{"product_family"=>"eschool", "created_at"=>"Wed May 16 10:58:12 +0530 2012", "unextended_ends_at"=>"Fri Jun 15 10:58:45 +0530 2012", "guid"=>"34c93597-67f6-4f48-b362-3b1ddb978e3e", "license"=>{"guid"=>"cceec678-6243-4d8b-afa3-8136995c2106", "identifier"=>"listerleelaesplevel1learner@rs.com"}, "starts_at"=>"Wed May 16 10:58:45 +0530 2012", "usable"=>true, "product_identifier"=>"ESP", "ends_at"=>"Sun Feb 10 10:58:45 +0530 2013", "activation_id"=>nil, "content_ranges"=>{"content_range"=>{"max_unit"=>"4", "created_at"=>"1337146092", "guid"=>"f108a854-8e00-4ea5-ace9-c61735f8e4b8", "updated_at"=>"1337146092", "activation_id"=>"22NN8L-HCN4K-3H6C8-EGDG5-LDY3G7D", "min_unit"=>"1"}, "coalesced"=>"false"}, "product_version"=>"3"}, {"product_family"=>"application", "created_at"=>"Wed May 16 10:58:12 +0530 2012", "unextended_ends_at"=>"Fri Jun 15 10:58:45 +0530 2012", "guid"=>"55ca663e-ca39-4a9e-a0a0-7e02c506c20f", "license"=>{"guid"=>"cceec678-6243-4d8b-afa3-8136995c2106", "identifier"=>"listerleelaesplevel1learner@rs.com"}, "starts_at"=>"Wed May 16 10:58:45 +0530 2012", "usable"=>true, "product_identifier"=>"ESP", "ends_at"=>"Sun Feb 10 10:58:45 +0530 2013", "activation_id"=>nil, "content_ranges"=>{"content_range"=>{"max_unit"=>"4", "created_at"=>"1337146092", "guid"=>"acb82516-e34e-43e0-9f96-7a3da5ca8d4e", "updated_at"=>"1337146092", "activation_id"=>"22NN8L-HCN4K-3H6C8-EGDG5-LDY3G7D", "min_unit"=>"1"}, "coalesced"=>"false"}, "product_version"=>"3"}, {"product_family"=>"premium_community", "created_at"=>"Wed May 16 10:58:12 +0530 2012", "unextended_ends_at"=>"Fri Jun 15 10:58:45 +0530 2012", "guid"=>"76a70333-f4dc-46b7-a5aa-3e5edfcc9b21", "license"=>{"guid"=>"cceec678-6243-4d8b-afa3-8136995c2106", "identifier"=>"listerleelaesplevel1learner@rs.com"}, "starts_at"=>"Wed May 16 10:58:45 +0530 2012", "usable"=>true, "product_identifier"=>"ESP", "ends_at"=>"Sun Feb 10 10:58:45 +0530 2013", "activation_id"=>nil, "content_ranges"=>{"content_range"=>{"max_unit"=>"4", "created_at"=>"1337146092", "guid"=>"02a33a11-fb0e-4b7a-b328-976bcc9c77cf", "updated_at"=>"1337146092", "activation_id"=>"22NN8L-HCN4K-3H6C8-EGDG5-LDY3G7D", "min_unit"=>"1"}, "coalesced"=>"false"}, "product_version"=>"3"}, {"product_family"=>"application", "created_at"=>"Wed May 16 12:40:52 +0530 2012", "unextended_ends_at"=>"Fri Jun 15 13:02:14 +0530 2012", "guid"=>"8c8f7fca-3566-4f51-966a-a27b2a40f5a4", "license"=>{"guid"=>"b8daf16e-57fa-4a00-9ae5-6039605618c7", "identifier"=>"listerleelaesplevel1learner@rs.com.kid1"}, "starts_at"=>"Wed May 16 13:02:15 +0530 2012", "usable"=>true, "product_identifier"=>"ESP", "ends_at"=>"Sun Feb 10 13:02:14 +0530 2013", "activation_id"=>nil, "content_ranges"=>{"content_range"=>{"max_unit"=>"4", "created_at"=>"1337152252", "guid"=>"1be07705-51c8-4e9d-befd-a6e35344aa8b", "updated_at"=>"1337152252", "activation_id"=>"22NN8L-HCN4K-3H6C8-EGDG5-LDY3G7D", "min_unit"=>"1"}, "coalesced"=>"false"}, "product_version"=>"3"}, {"product_family"=>"eschool", "created_at"=>"Wed May 16 12:40:52 +0530 2012", "unextended_ends_at"=>"Fri Jun 15 13:02:14 +0530 2012", "guid"=>"425dfecb-6fcd-43ef-b74e-9a4de8abdff3", "license"=>{"guid"=>"b8daf16e-57fa-4a00-9ae5-6039605618c7", "identifier"=>"listerleelaesplevel1learner@rs.com.kid1"}, "starts_at"=>"Wed May 16 13:02:14 +0530 2012", "usable"=>true, "product_identifier"=>"ESP", "ends_at"=>"Sun Feb 10 13:02:14 +0530 2013", "activation_id"=>nil, "content_ranges"=>{"content_range"=>{"max_unit"=>"4", "created_at"=>"1337152252", "guid"=>"511a7ef0-c7c0-4e52-86aa-ab3ffa358964", "updated_at"=>"1337152252", "activation_id"=>"22NN8L-HCN4K-3H6C8-EGDG5-LDY3G7D", "min_unit"=>"1"}, "coalesced"=>"false"}, "product_version"=>"3"}, {"product_family"=>"premium_community", "created_at"=>"Wed May 16 12:40:52 +0530 2012", "unextended_ends_at"=>"Fri Jun 15 13:02:14 +0530 2012", "guid"=>"f5cbda61-cd19-4fba-bb53-12f03a2e3bdb", "license"=>{"guid"=>"b8daf16e-57fa-4a00-9ae5-6039605618c7", "identifier"=>"listerleelaesplevel1learner@rs.com.kid1"}, "starts_at"=>"Wed May 16 13:02:14 +0530 2012", "usable"=>true, "product_identifier"=>"ESP", "ends_at"=>"Sun Feb 10 13:02:14 +0530 2013", "activation_id"=>nil, "content_ranges"=>{"content_range"=>{"max_unit"=>"4", "created_at"=>"1337152252", "guid"=>"3335cfcc-e36d-4b22-8728-ed0c1e46d1e6", "updated_at"=>"1337152252", "activation_id"=>"22NN8L-HCN4K-3H6C8-EGDG5-LDY3G7D", "min_unit"=>"1"}, "coalesced"=>"false"}, "product_version"=>"3"}, {"product_family"=>"application", "created_at"=>"Mon May 21 10:37:46 +0530 2012", "unextended_ends_at"=>"Mon May 21 10:37:46 +0530 2012", "guid"=>"bd43dc74-3467-40d3-88c4-1fc06aba8482", "license"=>{"guid"=>"f9fce669-b50c-4758-ae14-0f2face533f9", "identifier"=>"listerleelaesplevel1learner@rs.com.kid2"}, "starts_at"=>"Mon May 21 10:37:46 +0530 2012", "usable"=>false, "product_identifier"=>"ESP", "ends_at"=>"Mon May 21 10:37:46 +0530 2012", "activation_id"=>nil, "content_ranges"=>{"content_range"=>{"max_unit"=>"4", "created_at"=>"1337576866", "guid"=>"b8c674be-9468-4bce-a413-107b8fefe1ef", "updated_at"=>"1337576866", "activation_id"=>"22NN8L-HCN4K-3H6C8-EGDG5-LDY3G7D", "min_unit"=>"1"}, "coalesced"=>"false"}, "product_version"=>"3"}, {"product_family"=>"eschool", "created_at"=>"Mon May 21 10:37:46 +0530 2012", "unextended_ends_at"=>"Mon May 21 10:37:46 +0530 2012", "guid"=>"7ebc6693-6928-4a95-9d84-9342e8a71370", "license"=>{"guid"=>"f9fce669-b50c-4758-ae14-0f2face533f9", "identifier"=>"listerleelaesplevel1learner@rs.com.kid2"}, "starts_at"=>"Mon May 21 10:37:46 +0530 2012", "usable"=>false, "product_identifier"=>"ESP", "ends_at"=>"Mon May 21 10:37:46 +0530 2012", "activation_id"=>nil, "content_ranges"=>{"content_range"=>{"max_unit"=>"4", "created_at"=>"1337576866", "guid"=>"cddde47e-3e22-443e-a553-1f528db3196d", "updated_at"=>"1337576866", "activation_id"=>"22NN8L-HCN4K-3H6C8-EGDG5-LDY3G7D", "min_unit"=>"1"}, "coalesced"=>"false"}, "product_version"=>"3"}, {"product_family"=>"premium_community", "created_at"=>"Mon May 21 10:37:46 +0530 2012", "unextended_ends_at"=>"Mon May 21 10:37:46 +0530 2012", "guid"=>"856e3a0c-42f0-4322-a8d8-1c985571087a", "license"=>{"guid"=>"f9fce669-b50c-4758-ae14-0f2face533f9", "identifier"=>"listerleelaesplevel1learner@rs.com.kid2"}, "starts_at"=>"Mon May 21 10:37:46 +0530 2012", "usable"=>false, "product_identifier"=>"ESP", "ends_at"=>"Mon May 21 10:37:46 +0530 2012", "activation_id"=>nil, "content_ranges"=>{"content_range"=>{"max_unit"=>"4", "created_at"=>"1337576866", "guid"=>"9580981b-a767-4c18-bcac-2a8373040f96", "updated_at"=>"1337576866", "activation_id"=>"22NN8L-HCN4K-3H6C8-EGDG5-LDY3G7D", "min_unit"=>"1"}, "coalesced"=>"false"}, "product_version"=>"3"}])
    FactoryGirl.create(:learner,:guid => "cceec678-6243-4d8b-afa3-8136995c2106",:first_name => "suman")
    FactoryGirl.create(:learner,:guid => "b8daf16e-57fa-4a00-9ae5-6039605618c7",:first_name => "suman")
    FactoryGirl.create(:learner,:guid => "f9fce669-b50c-4758-ae14-0f2face533f9",:first_name => "suman")
  end

  def update_lang_identifier_response
    [{:response=> [{"activation_id"=>nil, "usable"=>true, "license"=>{"identifier"=>"cgilbert@pol.com", "guid"=>"086ad0e3-1496-4610-84c2-9c25699cc93f"}, "product_version"=>"3", "product_family"=>"application", "content_ranges"=>{"coalesced"=>"false", "content_range"=>{"updated_at"=>"0", "min_unit"=>"1", "activation_id"=>nil, "max_unit"=>"20", "created_at"=>"0", "guid"=>nil}}, "ends_at"=>"Tue Apr 23 11:08:00 -0400 2013", "starts_at"=>"Mon Apr 23 11:09:04 -0400 2012", "created_at"=>"Mon Apr 23 11:09:04 -0400 2012", "unextended_ends_at"=>"Tue Apr 23 11:08:00 -0400 2013", "guid"=>"5fc6bf24-b008-4f28-8608-5157333d5fd9", "product_identifier"=>"EBR"}]}]
  end

  def update_lang_identifier_response_with_blank_lang
        [{:response=> [{"activation_id"=>nil, "usable"=>true, "license"=>{"identifier"=>"cgilbert@pol.com", "guid"=>"086ad0e3-1496-4610-84c2-9c25699cc93f"}, "product_version"=>"3", "product_family"=>"application", "content_ranges"=>{"coalesced"=>"false", "content_range"=>{"updated_at"=>"0", "min_unit"=>"1", "activation_id"=>nil, "max_unit"=>"20", "created_at"=>"0", "guid"=>nil}}, "ends_at"=>"Tue Apr 23 11:08:00 -0400 2013", "starts_at"=>"Mon Apr 23 11:09:04 -0400 2012", "created_at"=>"Mon Apr 23 11:09:04 -0400 2012", "unextended_ends_at"=>"Tue Apr 23 11:08:00 -0400 2013", "guid"=>"5fc6bf24-b008-4f28-8608-5157333d5fd9", "product_identifier"=>""}]}]
      end

  def stub_ls_api_method_to_update_lang
    RosettaStone::ActiveLicensing::Base.any_instance.expects(:multicall).returns(update_lang_identifier_response)
  end
end
