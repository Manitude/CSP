require File.expand_path('../../../../test_helper', __FILE__)

class PrimarySearchTest < ActiveSupport::TestCase
	test "should search by first name" do
		FactoryGirl.create(:learner, :first_name => 'mohit')
		param = {:fname => 'mohit'}
		result = PrimarySearch.new(param).search
		assert_equal 1, result[:result].length
	end

	test "should search by last name" do
		FactoryGirl.create(:learner, :last_name => 'gadkari')
		param = {:lname => 'gadkari'}
		result = PrimarySearch.new(param).search
		assert_equal 1, result[:result].length
	end

	test "should search by first and last name" do
		FactoryGirl.create(:learner, :first_name => 'mohit',  :last_name => 'gadkari')
		FactoryGirl.create(:learner, :first_name => 'mohias',  :last_name => 'gadkari')
		param = {:lname => 'gadkar', :fname => 'mohit'}
		result = PrimarySearch.new(param).search
		assert_equal 1, result[:result].length
	end

	test "should search by first name and village" do
		FactoryGirl.create(:learner, :last_name => 'gadkari', :village_id => 123)
		FactoryGirl.create(:learner, :last_name => 'gadi', :village_id => 123)
		FactoryGirl.create(:learner, :last_name => 'Jamie', :village_id => 123)
		FactoryGirl.create(:learner, :last_name => 'James', :village_id => 122)

		param = {:lname => 'gad', :village => 123}
		result = PrimarySearch.new(param).search
		assert_equal 2, result[:result].length
		assert_equal 'gadi', result[:result][0].last_name
		assert_equal 'gadkari', result[:result][1].last_name
	end
  
  test "should search learners with no village" do
		FactoryGirl.create(:learner, :last_name => 'gadkari', :village_id => 123)
		FactoryGirl.create(:learner, :last_name => 'gadi', :village_id => 123)
		FactoryGirl.create(:learner, :last_name => 'Jamie')
		FactoryGirl.create(:learner, :last_name => 'James')

		param = {:lname => 'Jamie', :village => '-1'}
		result = PrimarySearch.new(param).search
		assert_equal 1, result[:result].length
		assert_equal 'Jamie', result[:result][0].last_name
	end

	test 'should search by language and first name' do
		learner1 = FactoryGirl.create(:learner, :first_name => 'gadi')
		learner2 = FactoryGirl.create(:learner, :first_name => 'gadkari')
		learner3 = FactoryGirl.create(:learner, :first_name => 'gadstein')
		
		learner1.learner_product_rights[0].update_attribute(:language_identifier, 'ENG')
		learner2.learner_product_rights[0].update_attribute(:language_identifier, 'SPA')
		learner3.learner_product_rights[0].update_attribute(:language_identifier, 'ENG')

		param = {:fname => 'gad', :language => 'ENG'}
		result_hash = PrimarySearch.new(param).search
		result = result_hash[:result]

		assert_equal 2, result.length
		assert_equal 'gadi', result[0].first_name
		assert_equal 'gadstein', result[1].first_name
	end

	test 'should search by advanced english and first name' do
		learner1 = FactoryGirl.create(:learner, :first_name => 'gadi')
		learner2 = FactoryGirl.create(:learner, :first_name => 'gadkari')
		learner3 = FactoryGirl.create(:learner, :first_name => 'gadstein')
		
		learner1.learner_product_rights[0].update_attribute(:language_identifier, 'KLE')
		learner2.learner_product_rights[0].update_attribute(:language_identifier, 'SPA')
		learner3.learner_product_rights[0].update_attribute(:language_identifier, 'JLE')

		param = {:fname => 'gad', :language => 'ADE'}
		result_hash = PrimarySearch.new(param).search
		result = result_hash[:result]

		assert_equal 2, result.length
		assert_equal 'gadi', result[0].first_name
		assert_equal 'gadstein', result[1].first_name
	end

	test 'should search by multiple product rights and first name' do
		learner1 = FactoryGirl.create(:learner, :first_name => 'gadi')
		learner2 = FactoryGirl.create(:learner, :first_name => 'gadkari')
		learner3 = FactoryGirl.create(:learner, :first_name => 'gadstein')
		
		learner1.learner_product_rights[0].update_attribute(:language_identifier, 'SPA')
		learner2.learner_product_rights[0].update_attribute(:language_identifier, 'SPA')
		learner3.learner_product_rights[0].update_attribute(:language_identifier, 'JLE')

		FactoryGirl.create(:learner_product_right, :learner_id => learner1.id, :language_identifier => 'ENG')
		FactoryGirl.create(:learner_product_right, :learner_id => learner1.id, :language_identifier => 'JLE')

		param = {:fname => 'gadi'}
		result_hash = PrimarySearch.new(param).search
		result = result_hash[:result]

		assert_equal 1, result.length
		assert_equal 'gadi', result[0].first_name
		
	end

  test 'should search by email' do
    FactoryGirl.create(:learner, :first_name => 'mohit1', :email => 'mohit@rs.com')
		param = {:email => 'mohit@rs.com'}
		result_hash = PrimarySearch.new(param).search
		result = result_hash[:result]
		assert_equal 1, result.length
		assert_equal 'mohit1', result[0].first_name
  end

  test 'should search by email with contains condition' do
    FactoryGirl.create(:learner, :first_name => 'mohit2', :email => 'mohit@rs.com')
		param = {:email => 'mohit', :search_options_email => 'contains'}
		result_hash = PrimarySearch.new(param).search
		result = result_hash[:result]
		assert_equal 1, result.length
		assert_equal 'mohit2', result[0].first_name
  end

  test 'should search by phone number' do
    FactoryGirl.create(:learner, :first_name => 'mohit3', :mobile_number => '9876543210')
		param = {:phone_number => '9876543210'}
		result_hash = PrimarySearch.new(param).search
		result = result_hash[:result]
		assert_equal 1, result.length
		assert_equal 'mohit3', result[0].first_name
  end
  
  test 'should search by all languages' do
		learner1 = FactoryGirl.create(:learner, :first_name => 'gadi')
		learner2 = FactoryGirl.create(:learner, :first_name => 'gadkari')
		learner3 = FactoryGirl.create(:learner, :first_name => 'gadstein')

		learner1.learner_product_rights[0].update_attribute(:language_identifier, 'ENG')
		learner2.learner_product_rights[0].update_attribute(:language_identifier, 'SPA')
		learner3.learner_product_rights[0].update_attribute(:language_identifier, 'ENG')

		param = {:fname => "gad", :language => 'all'}
		result_hash = PrimarySearch.new(param).search
		result = result_hash[:result]

		assert_equal 3, result.length
		assert_equal 'gadi', result[0].first_name
		assert_equal 'gadkari', result[1].first_name
		assert_equal 'gadstein', result[2].first_name
	end


end