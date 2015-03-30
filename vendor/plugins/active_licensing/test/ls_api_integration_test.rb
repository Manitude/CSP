# -*- encoding : utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))

# NOTE: this test file starts up the license server using webrick and uses active licensing
# to send actual LS API requests.
#
# These tests ONLY execute when these plugin tests are run within the license_server rails app.
class RosettaStone::ActiveLicensing::LsApiIntegrationTest < ActiveSupport::TestCase

  # note: a little janky but should be reliable
  def self.this_is_license_server?
    !!defined?(Api::ProductRightApiController)
  end

  if this_is_license_server?
    WEBRICK_PORT = 3339

    # load some base data into the LS test DB (products & bundles):
    require 'test/test_helper'
    fixtures :products, :product_bundles, :product_matchers, :product_bundle_configs

    def setup
      EndsAtProjector.stubs(:enqueue_recalculation_for_granite?).returns(false) # don't use granite for tests
      App.stubs(:tps_access_validation_enabled).returns(false)
      RosettaStone::ActiveLicensing.allow_real_api_calls_in_test_mode!
      mock_configuration!
    end

    def teardown
      RosettaStone::ActiveLicensing.stop_allowing_real_api_calls_in_test_mode!
      reset_unique_entities!
    end

    def test_integration_with_license_server
      RosettaStone::WebrickSpawner.with_server(:port => WEBRICK_PORT) do
        # make us a creation account
        ls_api.creation_account.add({
          :type => 'online_subscription',
          :creation_account => unique_creation_account_name,
          :password => 'unique_password',
        })
        assert_current_active_license_count(0)

        # make us a license
        ls_api.license.add({:creation_account => unique_creation_account_name, :license => unique_license_name, :password => 'password1'})
        response = ls_api.license.details(:license => unique_license_name)
        @guid = response['guid']
        assert_current_active_license_count(1)

        assert_authenticates(:license => unique_license_name, :password => 'password1')
        assert_authenticates(:guid => @guid, :password => 'password1')

        token1 = get_token

        response = assert_authenticate_with_token(token1)
        assert response['license']
        assert_equal @guid, response['license']['guid']

        ls_api.license.change_password(:guid => @guid, :password => 'password2')

        assert_authenticates(:license => unique_license_name, :password => 'password2')
        assert_authenticates(:guid => @guid, :password => 'password2')
        assert_authenticates({:license => unique_license_name, :password => 'password1'}, false)
        response = assert_authenticates({:guid => @guid, :password => 'password1'}, false)
        assert response['license']
        assert_equal @guid, response['license']['guid']

        response = assert_authenticate_with_token(token1, false)
        assert response['license']
        assert_equal @guid, response['license']['guid']
        token2 = get_token
        assert_authenticate_with_token(token2)

        assert_raises(RosettaStone::ActiveLicensing::BrokenTokenException) do
          ls_api.license.authenticate_with_token(:token => 'blah')
        end
      end
    end

    def test_product_pool_integration
      RosettaStone::WebrickSpawner.with_server(:port => WEBRICK_PORT) do
        # make us a creation account
        ls_api.creation_account.add({
          :type => 'pooled',
          :creation_account => unique_creation_account_name,
          :password => 'unique_password',
        })

        ca_details = ls_api.creation_account.details(:creation_account => unique_creation_account_name)
        assert_equal('pooled', ca_details['type'])

        no_pools = ls_api.creation_account.product_pools(:creation_account => unique_creation_account_name)
        assert_true no_pools.empty?

        # add a pool:
        pool = ls_api.product_pool.add({
          :creation_account => unique_creation_account_name,
          :product_bundle_guid => '0d39a27d-1d9e-4d62-bdd7-02ce44ef6a9a', # course
          :starts_at => 1.hour.ago.to_i,
          :expires_at => 1.day.from_now.to_i,
          :allocations_max => 2,
          :provisioner_identifier => 'end_date_pool',
          :product_configuration => {
            'languages' => %w(ENG),
            'maximum_languages_per_allocation' => 1,
            'access_ends_at' => 1.year.from_now.to_i,
          }
        })

        assert_pool_details(pool)

        pool = ls_api.product_pool.details({:guid => pool['guid']})
        assert_pool_details(pool)

        pools = ls_api.creation_account.product_pools(:creation_account => unique_creation_account_name)
        assert_equal(1, pools.size)
        assert_pool_details(pools.first)

        # make us a license
        ls_api.license.add({:creation_account => unique_creation_account_name,
          :license => unique_namespaced_license_name,
          :password => 'password1'})

        license_details = ls_api.license.details(:license => unique_namespaced_license_name)

        # make sure we don't have the product right
        license_product_rights = ls_api.license.product_rights(
          :license => unique_namespaced_license_name,
          :family => 'application',
          :version => '3',
          :identifier => 'ENG'
        )

        assert_equal 0, license_product_rights.count

        allocation_details = ls_api.product_pool.allocate(:guid => pool['guid'], :license_guid => license_details['guid'],
          :product_configuration => {:languages => %w[ENG]})

        assert_equal license_details['guid'], allocation_details['license']['guid']

        # Did we get the product right?
        license_product_rights = ls_api.license.product_rights(
          :license => unique_namespaced_license_name,
          :family => 'application',
          :version => '3',
          :identifier => 'ENG'
        )

        assert_true license_product_rights.first['usable']

        allocation_details_2 = ls_api.product_pool.allocation(:allocation_guid => allocation_details['guid'])
        assert_equal allocation_details, allocation_details_2

        # Update some stuff
        ls_api.product_pool.update(
          :guid => pool[:guid],
          :allocations_max => 4,
          :product_configuration => {
           :access_ends_at => 2.years.from_now.to_i,
          });

        pool_2 = ls_api.product_pools.details(:guid => pool[:guid])
        assert_equal 4, pool_2[:allocations_max]

        # Get the allocations of the license
        allocations_on_license = ls_api.license.allocations(:license => unique_namespaced_license_name)
        assert_equal 1, allocations_on_license.count
        assert_equal %w[ENG], allocations_on_license[0][:product_configuration][:languages]

        # And now take it away

        ls_api.product_pool.deallocate(:allocation_guid => allocation_details['guid'])

        license_product_rights = ls_api.license.product_rights(
          :license => unique_namespaced_license_name,
          :family => 'application',
          :version => '3',
          :identifier => 'ENG'
        )

        assert_false license_product_rights.first['usable']

        # And now delete the pool

        deleted_pool = ls_api.product_pool.remove(:guid => pool['guid'])

        assert_true deleted_pool['deleted']

        assert_raises(RosettaStone::ActiveLicensing::ProductPoolNotFound) do
          ls_api.product_pool.details(:guid => pool['guid'])
        end

      end
    end

    def test_product_pool_allocations
      RosettaStone::WebrickSpawner.with_server(:port => WEBRICK_PORT) do
        # make us a creation account
        ls_api.creation_account.add({
          :type => 'pooled',
          :creation_account => unique_creation_account_name,
          :password => 'unique_password',
        })

        ca_details = ls_api.creation_account.details(:creation_account => unique_creation_account_name)

        # add a pool
        pool = ls_api.product_pool.add({
          :creation_account => unique_creation_account_name,
          :product_bundle_guid => '0d39a27d-1d9e-4d62-bdd7-02ce44ef6a9a', # course
          :starts_at => 1.hour.ago.to_i,
          :expires_at => 1.day.from_now.to_i,
          :allocations_max => 50,
          :provisioner_identifier => 'duration_pool',
          :product_configuration => {
            'languages' => %w(ENG),
            'maximum_languages_per_allocation' => 1,
            'duration' => '3m',
          }
        })

        # Make 5 licenses
        licenses = (1..5).map do |x|
          license = "#{unique_creation_account_name}/sublicenses/OLLC::" + RosettaStone::UUIDHelper.generate
          ls_api.license.add({:creation_account => unique_creation_account_name,
          :license => license,
          :password => 'password1'})
          license_details = ls_api.license.details(:license => license)
          license_details['guid']
        end

        # Allocate 10 products to each license
        licenses.each do |license|
          10.times do
            ls_api.product_pool.allocate(:guid => pool[:guid], :license_guid => license, :product_configuration => {:langages => ['ENG']})
          end
        end

        allocations = ls_api.product_pool.allocations(:guid => pool[:guid])
        assert_equal 50, allocations.size

        page = ls_api.product_pool.allocations(:guid => pool[:guid], :page => 2, :per_page => 10)
        assert_equal 5, page[:total_pages]
        assert_equal 50, page[:total_entries]
        assert_equal 10, page[:allocations].size
      end
    end

    def test_multicall_integration
      RosettaStone::WebrickSpawner.with_server(:port => WEBRICK_PORT) do
        ca_identifier = unique_creation_account_name
        license_identifier = unique_license_name

        responses = ls_api.multicall do
          # make us a creation account
          creation_account.add({
            :type => 'online_subscription',
            :creation_account => ca_identifier,
            :password => 'unique_password',
          })

          # make us a license
          license.add({:creation_account => ca_identifier, :license => license_identifier, :password => 'password1'})
        end

        assert_equal 2, responses.size
        responses.each do |response|
          assert_true response[:response]
        end

        details_responses = ls_api.multicall do
          creation_account.details(:creation_account => ca_identifier)
          license.details(:license => license_identifier)
        end

        assert_equal 2, details_responses.size
        details_responses.each do |response|
          assert_true response[:response].is_a?(Hash)
        end

        auth_responses = ls_api.multicall do
          license.authenticate(:license => license_identifier, :password => 'password1')
          license.change_password(:license => license_identifier, :password => 'password2')
          license.authenticate(:license => license_identifier, :password => 'password2')
        end

        assert_equal 3, auth_responses.size
        assert_true auth_responses[0][:response]['authentication']
        assert_true auth_responses[1][:response]
        assert_true auth_responses[2][:response]['authentication']
      end
    end

  private

    def mock_configuration!
      [
        RosettaStone::ActiveLicensing::ApiCommunicator,
        RosettaStone::ActiveLicensing::MulticallApiCommunicator,
      ].each do |communicator|
        communicator.any_instance.stubs(:configuration).returns({
          :host => '127.0.0.1',
          :port => WEBRICK_PORT,
          :proxy_host => nil,
          :proxy_port => nil,
          :endpoint_path => '/api'
        })
      end
    end

    def unique_license_name
      @unique_license_name ||= "test_new_license_#{RosettaStone::UUIDHelper.generate}"
    end

    def unique_creation_account_name
      @unique_creation_account_name ||= "test_new_creation_account_#{RosettaStone::UUIDHelper.generate}"
    end

    def unique_namespaced_license_name
      @unique_namespaced_license_name ||= "#{unique_creation_account_name}/sublicenses/OLLC::#{unique_license_name}"
    end

    def reset_unique_entities!
      @unique_license_name = @unique_creation_account_name = @unique_namespaced_license_name = nil
    end

    def ls_api
      RosettaStone::ActiveLicensing::Base.instance
    end

    def assert_current_active_license_count(count = 0)
      response = ls_api.creation_account.details(:creation_account => unique_creation_account_name, :skip_license_counts => false)
      assert_equal(count.to_s, response['active_license_count'])
    end

    def assert_authenticates(options, success = true)
      response = ls_api.license.authenticate(options)
      assert_equal(success, response[:authentication])
      response
    end

    def assert_authenticate_with_token(token, success = true)
      response = ls_api.license.authenticate_with_token(:token => token)
      assert_equal(success, response[:authentication])
      assert_equal(@guid, response[:guid]) if success
      response
    end

    def get_token(guid = @guid)
      response = ls_api.license.get_token(:guid => guid)
      response[:token]
    end

    def assert_pool_details(product_pool)
      assert_equal(2, product_pool['allocations_remaining'])
      assert_equal_arrays(%w(ENG), product_pool['product_configuration']['languages'])
    end
  end
end
