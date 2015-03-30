require File.expand_path('../../test_helper', __FILE__)
require 'ostruct'

class LearnerTest < ActiveSupport::TestCase

  # test "check for user source types" do
  #   Learner.any_instance.stubs(:user_source).returns(Community::User.new)
  #   learner = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
  #   assert learner.community_user?
  #   assert !learner.viper_user?
  #   assert_send([learner,:community_user?])
  #   assert !learner.enterprise_user?
  # end

  def test_get_unusable_product_rights
    Learner.any_instance.stubs(:get_all_product_rights).returns([{'usable'=>false}, {'usable' => true}])
    assert_equal [{"usable"=>false}], Learner.new.get_unusable_product_rights
  end
  def test_get_usable_product_rights
    Learner.any_instance.stubs(:get_all_product_rights).returns([{'usable'=>false}, {'usable' => true},{'usable' => true}])
    assert_equal [{"usable"=>true},{"usable"=>true}], Learner.new.get_usable_product_rights
  end

  def test_all_user_product_rights
    Learner.any_instance.stubs(:get_all_product_rights).returns([{"product_identifier"=>"GRK"},{"product_identifier"=>"ENG"},{"product_identifier"=>"GRK"}])
    assert_equal ["GRK", "ENG"], Learner.new.all_user_product_rights
  end

  def test_has_totale_license_for_all
    Learner.any_instance.stubs(:all_product_rights).returns([{"product_identifier"=>"GRK"},{"product_identifier"=>"ENG"},{"product_identifier"=>"GRK"}])
    assert(true, Learner.new.has_totale_license_for_all?("GRK"))
    assert(true, Learner.new.has_totale_license_for_all?("ESP"))
  end

  def test_totale_languages_along_with_expired_lisences
    Learner.any_instance.stubs(:all_product_rights).returns([{"product_identifier"=>"GRK"},{"product_identifier"=>"ENG"},{"product_identifier"=>"GRK"}])
    Learner.any_instance.stubs(:get_all_product_rights).returns([{"product_identifier"=>"GRK","usable"=>true},{"product_identifier"=>"ENG","usable"=>true},{"product_identifier"=>"GRK","usable"=>true}])
    assert(true,!(Learner.new.totale_languages_along_with_expired_lisences.blank?))
  end

  # test "update profile info for new learner" do
  #   Community::User.delete_all
  #   RsManager::User.delete_all
  #   community_user = FactoryGirl.create(:community_user)
  #   viper_user     = FactoryGirl.create(:viper_user)
  #   assert_learner_details(community_user, viper_user)
  # end

  # test "update profile info for existing learner" do
  #   Community::User.delete_all
  #   RsManager::User.delete_all
  #   community_user = FactoryGirl.create(:community_user)
  #   viper_user = FactoryGirl.create(:viper_user)
  #   community_learner = FactoryGirl.create(:learner, :user_source_type => "Community::User",  :guid => community_user.guid)
  #   viper_learner = FactoryGirl.create(:learner, :user_source_type => "RsManager::User", :guid => viper_user.guid)
  #   assert_not_equal(community_user.first_name, community_learner.first_name)
  #   assert_not_equal(viper_user.first_name, viper_learner.first_name)
  #   assert_not_equal(community_user.last_name, community_learner.last_name)
  #   assert_not_equal(viper_user.last_name, viper_learner.last_name)
  #   assert_not_equal(community_user.email, community_learner.email)
  #   assert_not_equal(viper_user.email_address, viper_learner.email)
  #   assert_learner_details(community_user, viper_user)
  # end

  test "remove duplication of records with viper as latest" do
    guid = "aaaaa-bbbbb"
    FactoryGirl.create(:learner, :email => "community@rs.com", :user_source_type => "Community::User", :guid => guid)
    sleep(1)
    FactoryGirl.create(:learner, :email => "viper@rs.com", :user_source_type => "RsManager::User", :guid => guid)
    learners = Learner.find_all_by_guid(guid)
    assert_equal(2, learners.size)
    Learner.remove_duplication_of_records
    learners = Learner.find_all_by_guid(guid)
    assert_equal(1, learners.size)
    assert_equal("RsManager::User", learners[0].user_source_type)
    assert_equal("viper@rs.com", learners[0].email)
  end

  test "remove duplication of records with community as latest" do
    guid = "aaaaa-bbbbb"
    FactoryGirl.create(:learner, :email => "viper@rs.com", :user_source_type => "RsManager::User", :guid => guid)
    sleep(1)
    FactoryGirl.create(:learner, :email => "community@rs.com", :user_source_type => "Community::User", :guid => guid)
    learners = Learner.find_all_by_guid(guid)
    assert_equal(2, learners.size)
    Learner.remove_duplication_of_records
    learners = Learner.find_all_by_guid(guid)
    assert_equal(1, learners.size)
    assert_equal("RsManager::User", learners[0].user_source_type)
    assert_equal("community@rs.com", learners[0].email)
  end

  # test "initial population of village id" do
  #   user = FactoryGirl.create(:community_user, :guid => '1111111111', :village_id => 123)
  #   learner = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
  #   assert_nil(learner.village_id)
  #   Learner.initial_population_of_village_id
  #   learner.reload
  #   assert_equal(user.village_id, learner.village_id)
  # end

  # test "update profile rights" do
  #   LicenseServer::ProductRight.delete_all
  #   LicenseServer::Product.delete_all
  #   LicenseServer::License.delete_all
  #   license = FactoryGirl.create(:license, :guid => '1111111111')
  #   product = FactoryGirl.create(:product, :identifier => 'ARA')
  #   FactoryGirl.create(:product_right, :license_id => license.id, :product_id => product.id, :guid => '2222222222222', :activation_id => 'aaa-bbb-ccc')
  #   learner = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
  #   assert_equal(1, learner.learner_product_rights.size)
  #   Learner.update_product_rights_detail
  #   learner.learner_product_rights.reload
  #   assert_equal(2, learner.learner_product_rights.size)
  #   assert_equal('ARA',learner.learner_product_rights[1].language_identifier)
  #   assert_equal('2222222222222',learner.learner_product_rights[1].product_guid)
  #   assert_equal('aaa-bbb-ccc',learner.learner_product_rights[1].activation_id)
  # end

  def test_whether_empty_string_returnd_if_first_name_is_null
    learner1 = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111', :first_name => nil)
    assert_equal "", learner1.first_name
    learner2 = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
    assert_equal "first", learner2.first_name
  end

  def test_whether_empty_string_returnd_if_last_name_is_null
    learner1 = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111', :last_name => nil)
    assert_equal "", learner1.last_name
    learner2 = FactoryGirl.create(:learner, :user_source_type => "Community::User", :guid => '1111111111')
    assert_equal "last", learner2.last_name
  end

  def test_is_grandfathered
    product_hash = Learner.is_grandfathered([{"product_family"=>"eschool_one_on_one_sessions", "created_at"=>"Mon Aug 13 17:41:15 -0400 2012", "guid"=>"afc4eb3c-5efa-49c6-8695-3a3448f2f8a4", "unextended_ends_at"=>"Thu Aug 13 17:41:15 -0400 2015", "starts_at"=>"Mon Aug 13 17:41:15 -0400 2012", "license"=>{"guid"=>"98306c23-fa03-48e5-bbbe-543b0ed110e6", "identifier"=>"mcorns_all@test.test"}, "usable"=>true, "product_identifier"=>"VIE", "activation_id"=>nil, "ends_at"=>"Thu Aug 13 17:41:15 -0400 2015", "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"0", "created_at"=>"0", "guid"=>nil, "updated_at"=>"0", "activation_id"=>nil, "min_unit"=>"0"}]},{"product_family"=>"eschool_group_sessions", "created_at"=>"Mon Aug 13 17:41:14 -0400 2012", "guid"=>"5be823d4-97de-4964-b56e-91c3d063e05b", "unextended_ends_at"=>"Thu Aug 13 17:41:14 -0400 2015", "starts_at"=>"Mon Aug 13 17:41:14 -0400 2012", "license"=>{"guid"=>"98306c23-fa03-48e5-bbbe-543b0ed110e6", "identifier"=>"mcorns_all@test.test"}, "usable"=>true, "product_identifier"=>"TGL", "activatieon_id"=>nil, "ends_at"=>"Thu Aug 13 17:41:14 -0400 2015", "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"0", "created_at"=>"0", "guid"=>nil, "updated_at"=>"0", "activation_id"=>nil, "min_unit"=>"0"}]},{"product_family"=>"language_switching", "created_at"=>"Mon Aug 13 17:41:13 -0400 2012", "guid"=>"04b9ad34-ce73-4c3e-804a-0c88983acfa3", "unextended_ends_at"=>"Thu Aug 13 17:41:13 -0400 2015", "starts_at"=>"Mon Aug 13 17:41:13 -0400 2012", "license"=>{"guid"=>"98306c23-fa03-48e5-bbbe-543b0ed110e6", "identifier"=>"mcorns_all@test.test"}, "usable"=>true, "product_identifier"=>"TGL", "activation_id"=>nil, "ends_at"=>"Thu Aug 13 17:41:13 -0400 2015", "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"12", "created_at"=>"0", "guid"=>nil, "updated_at"=>"0", "activation_id"=>nil, "min_unit"=>"1"}]},{"product_family"=>"eschool_one_on_one_sessions", "created_at"=>"Mon Aug 13 17:41:15 -0400 2012", "guid"=>"ab80fd40-abd7-45ea-b93b-55c56df5c356", "unextended_ends_at"=>"Thu Aug 13 17:41:15 -0400 2015", "starts_at"=>"Mon Aug 13 17:41:15 -0400 2012", "license"=>{"guid"=>"98306c23-fa03-48e5-bbbe-543b0ed110e6", "identifier"=>"mcorns_all@test.test"}, "usable"=>true, "product_identifier"=>"TGL", "activation_id"=>nil, "ends_at"=>"Thu Aug 13 17:41:15 -0400 2015", "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"0", "created_at"=>"0", "guid"=>nil, "updated_at"=>"0", "activation_id"=>nil, "min_unit"=>"0"}]}])
    assert_equal false, product_hash["TGL"], "false since TGL language has eshool_group_session product rights"
    assert_equal true, product_hash["VIE"], "true since VIE language doesn't have eshool_group_session product rights"
  end

  def test_add_to_session
    stub_multicall
    product_hash = Learner.add_to_session([{"product_family"=>"application", "created_at"=>"Thu Jun 07 09:37:16 -0400 2012", "guid"=>"5f5fc9ee-8aef-42f9-8e94-939459f9079e", "unextended_ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "starts_at"=>"Thu Jun 07 09:37:16 -0400 2012", "license"=>{"guid"=>"26c1a790-4f34-44ae-9c46-1bf764a552cc", "identifier"=>"user.1@room.service"}, "usable"=>true, "product_identifier"=>"ENG", "activation_id"=>nil, "ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"20", "created_at"=>"0", "guid"=>nil, "updated_at"=>"0", "activation_id"=>nil, "min_unit"=>"1"}]},{"product_family"=>"eschool", "created_at"=>"Thu Jun 07 09:37:21 -0400 2012", "guid"=>"e9dd132f-12d1-421d-9aaa-f978d2283cdb", "unextended_ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "starts_at"=>"Thu Jun 07 09:37:21 -0400 2012", "license"=>{"guid"=>"26c1a790-4f34-44ae-9c46-1bf764a552cc", "identifier"=>"user.1@room.service"}, "usable"=>true, "product_identifier"=>"ENG", "activation_id"=>nil, "ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"20", "created_at"=>"0", "guid"=>nil, "updated_at"=>"0", "activation_id"=>nil, "min_unit"=>"1"}]},{"product_family"=>"premium_community", "created_at"=>"Thu Jun 07 09:37:23 -0400 2012", "guid"=>"15980d68-5688-4258-8b67-0ac13f46f36c", "unextended_ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "starts_at"=>"Thu Jun 07 09:37:23 -0400 2012", "license"=>{"guid"=>"26c1a790-4f34-44ae-9c46-1bf764a552cc", "identifier"=>"user.1@room.service"}, "usable"=>true, "product_identifier"=>"ENG", "activation_id"=>nil, "ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"20", "created_at"=>"0", "guid"=>nil, "updated_at"=>"0", "activation_id"=>nil, "min_unit"=>"1"}]},{"product_family"=>"lotus", "created_at"=>"Thu Jun 07 09:37:29 -0400 2012", "guid"=>"f8bd207e-48b7-4747-afb0-e6a93a87ce99", "unextended_ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "starts_at"=>"Thu Jun 07 09:37:29 -0400 2012", "license"=>{"guid"=>"26c1a790-4f34-44ae-9c46-1bf764a552cc", "identifier"=>"user.1@room.service"}, "usable"=>true, "product_identifier"=>"KLE", "activation_id"=>nil, "ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "product_version"=>"1", "content_ranges"=>[{"max_unit"=>"0", "created_at"=>"0", "guid"=>nil, "updated_at"=>"0", "activation_id"=>nil, "min_unit"=>"0"}]},{"product_family"=>"eschool_one_on_one_sessions", "created_at"=>"Tue Aug 21 10:10:26 -0400 2012", "guid"=>"d0682c6a-8254-4430-a75b-8bb180136e65", "unextended_ends_at"=>"Sat Sep 21 10:10:00 -0400 2013", "starts_at"=>"Tue Aug 21 10:14:02 -0400 2012", "license"=>{"guid"=>"26c1a790-4f34-44ae-9c46-1bf764a552cc", "identifier"=>"user.1@room.service"}, "usable"=>true, "product_identifier"=>"ARA", "activation_id"=>nil, "ends_at"=>"Mon Oct 21 10:10:00 -0400 2013", "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"0", "created_at"=>"0", "guid"=>nil, "updated_at"=>"0", "activation_id"=>nil, "min_unit"=>"0"}]}])
    assert_equal true,product_hash["d0682c6a-8254-4430-a75b-8bb180136e65"], "true since this product right has consumables"
  end

  def test_construct_add_to_session
    stub_multicall
    final_hash = Learner.construct_add_to_session([{"product_family"=>"application", "created_at"=>"Thu Jun 07 09:37:16 -0400 2012", "guid"=>"5f5fc9ee-8aef-42f9-8e94-939459f9079e", "unextended_ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "starts_at"=>"Thu Jun 07 09:37:16 -0400 2012", "license"=>{"guid"=>"26c1a790-4f34-44ae-9c46-1bf764a552cc", "identifier"=>"user.1@room.service"}, "usable"=>true, "product_identifier"=>"ENG", "activation_id"=>nil, "ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"20", "created_at"=>"0", "guid"=>nil, "updated_at"=>"0", "activation_id"=>nil, "min_unit"=>"1"}]},{"product_family"=>"eschool", "created_at"=>"Thu Jun 07 09:37:21 -0400 2012", "guid"=>"e9dd132f-12d1-421d-9aaa-f978d2283cdb", "unextended_ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "starts_at"=>"Thu Jun 07 09:37:21 -0400 2012", "license"=>{"guid"=>"26c1a790-4f34-44ae-9c46-1bf764a552cc", "identifier"=>"user.1@room.service"}, "usable"=>true, "product_identifier"=>"ENG", "activation_id"=>nil, "ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"20", "created_at"=>"0", "guid"=>nil, "updated_at"=>"0", "activation_id"=>nil, "min_unit"=>"1"}]},{"product_family"=>"premium_community", "created_at"=>"Thu Jun 07 09:37:23 -0400 2012", "guid"=>"15980d68-5688-4258-8b67-0ac13f46f36c", "unextended_ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "starts_at"=>"Thu Jun 07 09:37:23 -0400 2012", "license"=>{"guid"=>"26c1a790-4f34-44ae-9c46-1bf764a552cc", "identifier"=>"user.1@room.service"}, "usable"=>true, "product_identifier"=>"ENG", "activation_id"=>nil, "ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"20", "created_at"=>"0", "guid"=>nil, "updated_at"=>"0", "activation_id"=>nil, "min_unit"=>"1"}]},{"product_family"=>"lotus", "created_at"=>"Thu Jun 07 09:37:29 -0400 2012", "guid"=>"f8bd207e-48b7-4747-afb0-e6a93a87ce99", "unextended_ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "starts_at"=>"Thu Jun 07 09:37:29 -0400 2012", "license"=>{"guid"=>"26c1a790-4f34-44ae-9c46-1bf764a552cc", "identifier"=>"user.1@room.service"}, "usable"=>true, "product_identifier"=>"KLE", "activation_id"=>nil, "ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "product_version"=>"1", "content_ranges"=>[{"max_unit"=>"0", "created_at"=>"0", "guid"=>nil, "updated_at"=>"0", "activation_id"=>nil, "min_unit"=>"0"}]},{"product_family"=>"eschool_one_on_one_sessions", "created_at"=>"Tue Aug 21 10:10:26 -0400 2012", "guid"=>"d0682c6a-8254-4430-a75b-8bb180136e65", "unextended_ends_at"=>"Sat Sep 21 10:10:00 -0400 2013", "starts_at"=>"Tue Aug 21 10:14:02 -0400 2012", "license"=>{"guid"=>"26c1a790-4f34-44ae-9c46-1bf764a552cc", "identifier"=>"user.1@room.service"}, "usable"=>true, "product_identifier"=>"ARA", "activation_id"=>nil, "ends_at"=>"Mon Oct 21 10:10:00 -0400 2013", "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"0", "created_at"=>"0", "guid"=>nil, "updated_at"=>"0", "activation_id"=>nil, "min_unit"=>"0"}]},{"product_family"=>"eschool_group_sessions","created_at"=>"Tue Aug 21 10:10:26 -0400 2012", "guid"=>"d0682c6a-8254-4430-a75b-8bb180136e6644","usable"=>true,"product_identifier"=>"GER"},{"product_family"=>"eschool","created_at"=>"Tue Aug 21 10:10:26 -0400 2012", "guid"=>"d0682c6a-8254-4430-a75b-8bb180136e6678","usable"=>true,"product_identifier"=>"GER"}],nil)
    assert_equal false,final_hash["KLE"], "For lotus it should be always disabled"
    assert_equal true,final_hash["ENG"], "For Eng it should be enabled since eschool studio is active and no eschool group product rights"
    assert_equal false,final_hash["ARA"], "For ARA  it should be disabled since eschool studio is not present"
    assert_equal false,final_hash["GER"], "For GER  it should be disabled since eschool studio is present and eschool group session is present but without any consumables"
  end

  def test_construct_add_to_session_with_language
    stub_multicall2
    final_hash = Learner.construct_add_to_session([{"product_family"=>"application", "created_at"=>"Thu Jun 07 09:37:16 -0400 2012", "guid"=>"5f5fc9ee-8aef-42f9-8e94-939459f9079e", "unextended_ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "starts_at"=>"Thu Jun 07 09:37:16 -0400 2012", "license"=>{"guid"=>"26c1a790-4f34-44ae-9c46-1bf764a552cc", "identifier"=>"user.1@room.service"}, "usable"=>true, "product_identifier"=>"ENG", "activation_id"=>nil, "ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"20", "created_at"=>"0", "guid"=>nil, "updated_at"=>"0", "activation_id"=>nil, "min_unit"=>"1"}]},{"product_family"=>"eschool", "created_at"=>"Thu Jun 07 09:37:21 -0400 2012", "guid"=>"e9dd132f-12d1-421d-9aaa-f978d2283cdb", "unextended_ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "starts_at"=>"Thu Jun 07 09:37:21 -0400 2012", "license"=>{"guid"=>"26c1a790-4f34-44ae-9c46-1bf764a552cc", "identifier"=>"user.1@room.service"}, "usable"=>true, "product_identifier"=>"ENG", "activation_id"=>nil, "ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"20", "created_at"=>"0", "guid"=>nil, "updated_at"=>"0", "activation_id"=>nil, "min_unit"=>"1"}]},{"product_family"=>"premium_community", "created_at"=>"Thu Jun 07 09:37:23 -0400 2012", "guid"=>"15980d68-5688-4258-8b67-0ac13f46f36c", "unextended_ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "starts_at"=>"Thu Jun 07 09:37:23 -0400 2012", "license"=>{"guid"=>"26c1a790-4f34-44ae-9c46-1bf764a552cc", "identifier"=>"user.1@room.service"}, "usable"=>true, "product_identifier"=>"ENG", "activation_id"=>nil, "ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"20", "created_at"=>"0", "guid"=>nil, "updated_at"=>"0", "activation_id"=>nil, "min_unit"=>"1"}]},{"product_family"=>"lotus", "created_at"=>"Thu Jun 07 09:37:29 -0400 2012", "guid"=>"f8bd207e-48b7-4747-afb0-e6a93a87ce99", "unextended_ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "starts_at"=>"Thu Jun 07 09:37:29 -0400 2012", "license"=>{"guid"=>"26c1a790-4f34-44ae-9c46-1bf764a552cc", "identifier"=>"user.1@room.service"}, "usable"=>true, "product_identifier"=>"KLE", "activation_id"=>nil, "ends_at"=>"Sun Dec 31 18:59:00 -0500 2017", "product_version"=>"1", "content_ranges"=>[{"max_unit"=>"0", "created_at"=>"0", "guid"=>nil, "updated_at"=>"0", "activation_id"=>nil, "min_unit"=>"0"}]},{"product_family"=>"eschool_one_on_one_sessions", "created_at"=>"Tue Aug 21 10:10:26 -0400 2012", "guid"=>"d0682c6a-8254-4430-a75b-8bb180136e65", "unextended_ends_at"=>"Sat Sep 21 10:10:00 -0400 2013", "starts_at"=>"Tue Aug 21 10:14:02 -0400 2012", "license"=>{"guid"=>"26c1a790-4f34-44ae-9c46-1bf764a552cc", "identifier"=>"user.1@room.service"}, "usable"=>true, "product_identifier"=>"ARA", "activation_id"=>nil, "ends_at"=>"Mon Oct 21 10:10:00 -0400 2013", "product_version"=>"3", "content_ranges"=>[{"max_unit"=>"0", "created_at"=>"0", "guid"=>nil, "updated_at"=>"0", "activation_id"=>nil, "min_unit"=>"0"}]},{"product_family"=>"eschool_group_sessions","created_at"=>"Tue Aug 21 10:10:26 -0400 2012", "guid"=>"d0682c6a-8254-4430-a75b-8bb180136e6644","usable"=>true,"product_identifier"=>"GER"},{"product_family"=>"eschool","created_at"=>"Tue Aug 21 10:10:26 -0400 2012", "guid"=>"d0682c6a-8254-4430-a75b-8bb180136e6678","usable"=>true,"product_identifier"=>"GER"}],"GER")
    assert_nil final_hash["KLE"], "For lotus it should be always disabled"
    assert_nil final_hash["ENG"], "For Eng it should be enabled since eschool studio is active and no eschool group product rights"
    assert_nil final_hash["ARA"], "For ARA  it should be disabled since eschool studio is not present"
    assert_equal false,final_hash["GER"], "For GER  it should be disabled since eschool studio is present and eschool group session is present but without any consumables"
  end
  private

  def stub_multicall
    #RosettaStone::ActiveLicensing::Base.any_instance.expects(:multicall).returns([{:api_category=>"product_right", :response=>[{"pooler"=>{"guid"=>"d0682c6a-8254-4430-a75b-8bb180136e65", "type"=>"ProductRight"}, "remaining_rollover_count"=>nil, "expires_at"=>nil, "created_at"=>"Tue Aug 21 10:10:52 -0400 2012", "guid"=>"cb0f78a9-7e84-47c9-af88-964faddb9d88", "starts_at"=>nil, "usable"=>true, "activation_id"=>"BBOBOBOBOBOBO", "consumed_at"=>nil, "consumed"=>false}, {"pooler"=>{"guid"=>"d0682c6a-8254-4430-a75b-8bb180136e65", "type"=>"ProductRight"}, "remaining_rollover_count"=>nil, "expires_at"=>nil, "created_at"=>"Tue Aug 21 10:12:43 -0400 2012", "guid"=>"24d84785-88f6-471c-a23a-eb1d0f22ea0e", "starts_at"=>nil, "usable"=>true, "activation_id"=>"kjhvkjhvkv", "consumed_at"=>nil, "consumed"=>false}], :method_name=>"consumables"}]);
    RosettaStone::ActiveLicensing::Base.any_instance.expects(:multicall).returns([{:api_category=>"product_right", :response=>[{"expires_at"=>"Mon Oct 21 10:10:00 -0400 2013", "guid"=>"cb0f78a9-7e84-47c9-af88-964faddb9d88", "starts_at"=>"Tue Aug 21 10:10:52 -0400 2012"}, {"expires_at"=>"Mon Oct 21 10:10:00 -0400 2013", "guid"=>"24d84785-88f6-471c-a23a-eb1d0f22ea0e", "starts_at"=>"Tue Aug 21 10:12:43 -0400 2012"}], :method_name=>"projected_consumables"},{:api_category=>"product_right", :response=>[], :method_name=>"projected_consumables"}])
  end
  def stub_multicall2
    RosettaStone::ActiveLicensing::Base.any_instance.expects(:multicall).returns([{:api_category=>"product_right", :response=>[], :method_name=>"projected_consumables"}])
  end
  def assert_learner_details(community_user, viper_user)
    Learner.update_profile_info
    community_learner = Learner.find_by_guid(community_user.guid)
    viper_learner = Learner.find_by_guid(viper_user.guid)
    assert_equal(community_user.first_name, community_learner.first_name)
    assert_equal(viper_user.first_name, viper_learner.first_name)
    assert_equal(community_user.last_name, community_learner.last_name)
    assert_equal(viper_user.last_name, viper_learner.last_name)
    assert_equal(community_user.email, community_learner.email)
    assert_equal(viper_user.email_address, viper_learner.email)
    assert_equal(community_user.mobile_number, community_learner.mobile_number)
    assert_nil(viper_learner.mobile_number)
    assert_equal(community_user.village_id, community_learner.village_id)
    assert_nil(viper_learner.village_id)
    assert_equal(community_user.class.to_s, community_learner.user_source_type)
    assert_equal(viper_user.class.to_s, viper_learner.user_source_type)
  end
end
