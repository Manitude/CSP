require File.expand_path('test_helper', File.dirname(__FILE__))

class RosettaStone::ActiveLicensing::ProductPoolTest < Test::Unit::TestCase

  include RosettaStone::ActiveLicensing

  def setup
    @ls = RosettaStone::ActiveLicensing::Base.instance
    @time = Time.now.change(:usec => 0)
    @time_plus_one_year = @time + 1.year
    @time_plus_two_years = @time + 2.years
  end

  def test_add
    uuid = RosettaStone::UUIDHelper.generate
    xml = %Q[
      <response license_server_version="1.0">
      <product_pool>
        <guid>#{uuid}</guid>
        <creation_account>
          <identifier>pooled_creation_account</identifier>
          <guid>302c8860-f062-4078-a8d0-3c998bb10880</guid>
        </creation_account>
        <product_bundle>
          <name>totale_unlimited_studio</name>
          <guid>d86a52dc-ce3a-4c20-ac9d-bcff51c9cae5</guid>
        </product_bundle>
        <starts_at type="integer">#{@time.to_i}</starts_at>
        <expires_at type="integer">#{@time_plus_one_year.to_i}</expires_at>
        <provisioner_identifier>EndDatePool</provisioner_identifier>
        <allocations_max type="integer">50</allocations_max>
        <allocations_remaining type="integer">50</allocations_remaining>
        <product_configuration>
          <access_ends_at type="integer">#{@time_plus_one_year.to_i}</access_ends_at>
          <maximum_languages_per_allocation type="integer">1</maximum_languages_per_allocation>
          <languages type="array">
            <language>ENG</language>
            <language>ESP</language>
          </languages>
        </product_configuration>
      </product_pool>
      </response>
    ]

    opts = {
      :creation_account_guid => 'sdfsfasfasf',
      :provisioner_identifier => 'EndDatePool',
      :allocations_max => 100,
      :product_bundle_guid => 'sdsfasasdfa',
      :starts_at => @time.to_i,
      :ends_at => @time_plus_one_year.to_i,
      :product_configuration => {:access_ends_at => @time_plus_one_year.to_i, :languages => ['ENG', 'FRA'], :maximum_languages_per_allocation => 1}
    }

    ApiCommunicator.any_instance.expects(:api_post).with('product_pool', 'add', opts).at_least(1).returns(xml)
    assert_not_nil product_pool_details = @ls.product_pool.add(opts)
    assert_equal uuid, product_pool_details['guid']
    assert_equal @time, product_pool_details['starts_at']
    assert_equal @time_plus_one_year, product_pool_details['expires_at']
    assert_equal @time_plus_one_year, product_pool_details['product_configuration']['access_ends_at']
    assert_equal 1, product_pool_details['product_configuration']['maximum_languages_per_allocation']
    assert_equal_arrays ['ENG', 'ESP'], product_pool_details['product_configuration']['languages']
  end

  def test_add_fails_when_creation_account_is_not_found
    xml = %q[
      <?xml version="1.0" encoding="UTF-8"?>
      <response license_server_version="1.0">
      <exception type="creation_account_not_found">An error occurred while processing this request: Api::CreationAccountNotFound</exception>
      </response>
    ]

    opts = {}

    ApiCommunicator.any_instance.expects(:api_post).with('product_pool', 'add', opts).at_least(1).returns(xml)
    assert_raises(RosettaStone::ActiveLicensing::CreationAccountNotFound) do
       @ls.product_pool.add(opts)
    end
  end

  def test_details
    xml = %Q[
    <response license_server_version="1.0">
<product_pool>
  <guid>c1c48fe2-cdf3-4021-9f38-10ebca884f54</guid>
  <creation_account>
    <identifier>pooled_creation_account</identifier>
    <guid>325b3e5a-f50f-49ef-8850-bd08c2cbb5e0</guid>
  </creation_account>
  <product_bundle>
    <name>course</name>
    <guid>0d39a27d-1d9e-4d62-bdd7-02ce44ef6a9a</guid>
  </product_bundle>
  <starts_at type="integer">#{@time.to_i}</starts_at>
  <expires_at type="integer">#{@time_plus_one_year.to_i}</expires_at>
  <provisioner_identifier>duration_pool</provisioner_identifier>
  <allocations_max type="integer">50</allocations_max>
  <allocations_remaining type="integer">50</allocations_remaining>
  <product_configuration>
    <duration>6m</duration>
    <languages type="array">
      <language>ARA</language>
      <language>DEU</language>
      <language>EBR</language>
      <language>ENG</language>
      <language>ESC</language>
      <language>ESP</language>
      <language>FRA</language>
      <language>ITA</language>
      <language>POR</language>
      <language>RUS</language>
      <language>CHI</language>
      <language>JPN</language>
      <language>HEB</language>
      <language>GLE</language>
      <language>KOR</language>
      <language>FAR</language>
      <language>POL</language>
      <language>HIN</language>
      <language>SVE</language>
      <language>GRK</language>
      <language>NED</language>
      <language>TUR</language>
      <language>VIE</language>
      <language>TGL</language>
    </languages>
    <maximum_languages_per_allocation type="integer">1</maximum_languages_per_allocation>
  </product_configuration>
</product_pool>
</response>
]

    opts = { :guid => 'c1c48fe2-cdf3-4021-9f38-10ebca884f54'}

    ApiCommunicator.any_instance.expects(:api_call).with('product_pool', 'details', opts).at_least(1).returns(xml)
    assert_not_nil product_pool_details = @ls.product_pool.details(opts)

    assert_equal @time, product_pool_details['starts_at']
    assert_equal @time_plus_one_year, product_pool_details['expires_at']
    assert_equal '6m', product_pool_details['product_configuration']['duration']
    assert_equal 1, product_pool_details['product_configuration']['maximum_languages_per_allocation']
    assert_equal 24, product_pool_details['product_configuration']['languages'].size
  end

  def test_remove
    uuid = RosettaStone::UUIDHelper.generate
    xml = %Q[
      <response license_server_version="1.0">
      <product_pool>
        <guid>#{uuid}</guid>
        <deleted type="boolean">true</deleted>
        <creation_account>
          <identifier>pooled_creation_account</identifier>
          <guid>302c8860-f062-4078-a8d0-3c998bb10880</guid>
        </creation_account>
        <product_bundle>
          <name>totale_unlimited_studio</name>
          <guid>d86a52dc-ce3a-4c20-ac9d-bcff51c9cae5</guid>
        </product_bundle>
        <starts_at type="integer">#{@time.to_i}</starts_at>
        <expires_at type="integer">#{@time_plus_one_year.to_i}</expires_at>
        <provisioner_identifier>EndDatePool</provisioner_identifier>
        <allocations_max type="integer">50</allocations_max>
        <allocations_remaining type="integer">50</allocations_remaining>
        <product_configuration>
          <access_ends_at type="integer">#{@time_plus_one_year.to_i}</access_ends_at>
          <maximum_languages_per_allocation type="integer">1</maximum_languages_per_allocation>
          <languages type="array">
            <language>ENG</language>
            <language>ESP</language>
          </languages>
        </product_configuration>
      </product_pool>
      </response>
    ]

    opts = {:guid => uuid}

    ApiCommunicator.any_instance.expects(:api_post).with('product_pool', 'remove', opts).at_least(1).returns(xml)

    assert_not_nil response = @ls.product_pool.remove(opts)
    assert_equal uuid, response['guid']
    assert_true response['deleted']
  end

  def test_remove_fails_when_pool_has_allocations
    xml = %q[
<response license_server_version="1.0">
  <exception type="product_pool_cannot_be_destroyed_with_existing_allocations">An error occurred while processing this request: ProductPoolCannotBeDestroyedWithExistingAllocations</exception>
</response>
]
    opts = {:guid => 'c1c48fe2-cdf3-4021-9f38-10ebca884f54'}

    ApiCommunicator.any_instance.expects(:api_post).with('product_pool', 'remove', opts).at_least(1).returns(xml)

    assert_raises(RosettaStone::ActiveLicensing::ProductPoolCannotBeDestroyedWithExistingAllocation) do
      @ls.product_pool.remove(opts)
    end
  end

  def test_update
    xml = %Q[
    <response license_server_version="1.0">
<product_pool>
  <guid>c1c48fe2-cdf3-4021-9f38-10ebca884f54</guid>
  <creation_account>
    <identifier>pooled_creation_account</identifier>
    <guid>325b3e5a-f50f-49ef-8850-bd08c2cbb5e0</guid>
  </creation_account>
  <product_bundle>
    <name>course</name>
    <guid>0d39a27d-1d9e-4d62-bdd7-02ce44ef6a9a</guid>
  </product_bundle>
  <starts_at type="integer">#{@time.to_i}</starts_at>
  <expires_at type="integer">#{@time_plus_two_years.to_i}</expires_at>
  <provisioner_identifier>duration_pool</provisioner_identifier>
  <allocations_max type="integer">50</allocations_max>
  <allocations_remaining type="integer">50</allocations_remaining>
  <product_configuration>
    <access_ends_at>#{@time_plus_two_years.to_i}</access_ends_at>
    <languages type="array">
      <language>ENG</language>
    </languages>
    <maximum_languages_per_allocation type="integer">1</maximum_languages_per_allocation>
  </product_configuration>
</product_pool>
</response>
]


    opts = {
      :guid => 'c1c48fe2-cdf3-4021-9f38-10ebca884f54',
      :expires_at => 2.years.from_now,
      :product_configuration => { :access_ends_at => 2.years.from_now }
    }

    ApiCommunicator.any_instance.expects(:api_post).with('product_pool', 'update', opts).at_least(1).returns(xml)
    assert_not_nil product_pool_details = @ls.product_pool.update(opts)

    assert_equal @time, product_pool_details['starts_at']
    assert_equal @time_plus_two_years, product_pool_details['expires_at']
    assert_equal @time_plus_two_years, product_pool_details['product_configuration']['access_ends_at']
    assert_equal 1, product_pool_details['product_configuration']['maximum_languages_per_allocation']
    assert_equal 1, product_pool_details['product_configuration']['languages'].size
  end

  def test_update_fails_when_allocations_max_is_less_than_allocations_current
    xml = %q[
<response license_server_version="1.0">
<exception type="record_invalid">Validation failed: Allocations max cannot be reduced to less than the current number of allocations</exception>
<validation_errors>
  <error attribute="allocations_max">cannot be reduced to less than the current number of allocations</error>
</validation_errors>
</response>
    ]

    opts = {
      :guid => 'c1c48fe2-cdf3-4021-9f38-10ebca884f54',
      :max_allocations => 5
    }

    ApiCommunicator.any_instance.expects(:api_post).with('product_pool', 'update', opts).at_least(1).returns(xml)
    assert_raises(RosettaStone::ActiveLicensing::RecordInvalid) do
       @ls.product_pool.update(opts)
    end
  end

  def test_allocate
    xml = allocation_detail_response

    opts = {
      :guid => 'c1c48fe2-cdf3-4021-9f38-10ebca884f54',
      :license_guid => 'a56aad9a-7642-4ef5-bcdf-6861addba44a',
      :product_configuration => {:languages => ['ENG']}
    }

    ApiCommunicator.any_instance.expects(:api_post).with('product_pool', 'allocate', opts).at_least(1).returns(xml)
    assert_not_nil allocation = @ls.product_pool.allocate(opts)

    assert_equal 'b9a6ca92-710c-44f9-aded-67c094dc797e', allocation['guid']
    assert_equal ['ENG'], allocation[:product_configuration][:languages]
    assert_equal @time_plus_one_year, allocation[:product_configuration][:access_ends_at]
  end

  def test_allocate_fails_when_product_pool_is_not_found
    xml = %q[
      <?xml version="1.0" encoding="UTF-8"?>
      <response license_server_version="1.0">
      <exception type="product_pool_not_found">An error occurred while processing this request: Api::ProductPoolNotFound</exception>
      </response>
    ]

    opts = {
      :guid => 'c1c48fe2-cdf3-4021-9f38-10ebca884f54',
      :license_guid => 'a56aad9a-7642-4ef5-bcdf-6861addba44a',
      :product_configuration => {:languages => ['ENG']}
    }

    ApiCommunicator.any_instance.expects(:api_post).with('product_pool', 'allocate', opts).at_least(1).returns(xml)
    assert_raises(RosettaStone::ActiveLicensing::ProductPoolNotFound) do
       @ls.product_pool.allocate(opts)
    end
  end

  def test_allocate_fails_when_no_allocations_remain
    xml = %q[
      <?xml version="1.0" encoding="UTF-8"?>
      <response license_server_version="1.0">
      <exception type="no_allocations_remaining">An error occurred while processing this request: NoAllocationsRemaining</exception>
      </response>
    ]

    opts = {
      :guid => 'c1c48fe2-cdf3-4021-9f38-10ebca884f54',
      :license_guid => 'a56aad9a-7642-4ef5-bcdf-6861addba44a',
      :product_configuration => {:languages => ['ENG']}
    }

    ApiCommunicator.any_instance.expects(:api_post).with('product_pool', 'allocate', opts).at_least(1).returns(xml)
    assert_raises(RosettaStone::ActiveLicensing::NoAllocationsRemaining) do
       @ls.product_pool.allocate(opts)
    end
  end

  def test_deallocate
    xml = deleted_allocation_detail_response

    opts = {
      :allocation_guid => 'b9a6ca92-710c-44f9-aded-67c094dc797e'
    }

    ApiCommunicator.any_instance.expects(:api_post).with('product_pool', 'deallocate', opts).at_least(1).returns(xml)
    assert_not_nil allocation = @ls.product_pool.deallocate(opts)

    assert_equal 'b9a6ca92-710c-44f9-aded-67c094dc797e', allocation['guid']
    assert_true allocation['deleted']
  end

  def test_deallocate_fails_when_allocation_is_not_found
    xml = %q[
<?xml version="1.0" encoding="UTF-8"?>
<response license_server_version="1.0">
<exception type="allocation_not_found">An error occurred while processing this request: Api::AllocationNotFound</exception>
</response>
]
    opts = {
      :allocation_guid => 'b9a6ca92-710c-44f9-aded-67c094dc797e'
    }

    ApiCommunicator.any_instance.expects(:api_post).with('product_pool', 'deallocate', opts).at_least(1).returns(xml)

    assert_raises(RosettaStone::ActiveLicensing::AllocationNotFound) do
      @ls.product_pool.deallocate(opts)
    end
  end

  def test_deallocate_fails_when_deallocation_is_not_allowed
    xml = %q[
<?xml version="1.0" encoding="UTF-8"?>
<response license_server_version="1.0">
<exception type="deallocation_not_allowed">An error occurred while processing this request: DeallocationNotAllowed</exception>
</response>
]
    opts = {
      :allocation_guid => 'b9a6ca92-710c-44f9-aded-67c094dc797e'
    }

    ApiCommunicator.any_instance.expects(:api_post).with('product_pool', 'deallocate', opts).at_least(1).returns(xml)

    assert_raises(RosettaStone::ActiveLicensing::DeallocationNotAllowed) do
      @ls.product_pool.deallocate(opts)
    end
  end

  def test_allocations
    xml = %q[
    <?xml version="1.0" encoding="UTF-8"?>
    <response license_server_version="1.0">
    <allocations type="array">
      <allocation>
        <guid>5b954840-f956-428a-a47a-b4d788e51dfc</guid>
        <product_pool>
          <guid>99c81ec9-404e-4d9d-9355-32b3870dc865</guid>
        </product_pool>
        <license>
          <guid>bf9eee4a-b1e9-42f7-9ea0-1adb3b4636b3</guid>
          <identifier>osub_license</identifier>
        </license>
        <product_configuration>
          <duration>6m</duration>
          <languages type="array">
            <language>ENG</language>
          </languages>
        </product_configuration>
      </allocation>
      <allocation>
        <guid>06a72bbb-d10a-4e34-b745-776a584655ca</guid>
        <product_pool>
          <guid>99c81ec9-404e-4d9d-9355-32b3870dc865</guid>
        </product_pool>
        <license>
          <guid>bf9eee4a-b1e9-42f7-9ea0-1adb3b4636b3</guid>
          <identifier>osub_license</identifier>
        </license>
        <product_configuration>
          <duration>6m</duration>
          <languages type="array">
            <language>ENG</language>
          </languages>
        </product_configuration>
      </allocation>
    </allocations>
    </response>
]

    opts = {
      :guid => '99c81ec9-404e-4d9d-9355-32b3870dc865'
    }

    ApiCommunicator.any_instance.expects(:api_call).with('product_pool', 'allocations', opts).at_least(1).returns(xml)

    allocations = @ls.product_pool.allocations(opts)

    assert_equal 2, allocations.size
    assert_equal %w[ENG], allocations[0]['product_configuration']['languages']
  end

  def test_allocatons_paginated
        xml = %q[
    <?xml version="1.0" encoding="UTF-8"?>
<response license_server_version="1.0">
<page>
  <total_pages type="integer">4</total_pages>
  <total_entries type="integer">10</total_entries>
  <allocations type="array">
    <allocation>
      <guid>dd5a3f78-6e0b-4229-b105-a66f67d34107</guid>
      <product_pool>
        <guid>c3f4dc11-14da-4674-8d9e-a78591bbf545</guid>
      </product_pool>
      <license>
        <guid>5630a774-628b-4443-8f8d-d3fd0c33cb31</guid>
        <identifier>osub_license</identifier>
      </license>
      <product_configuration>
        <duration>6m</duration>
        <languages type="array">
          <language>FRA</language>
        </languages>
      </product_configuration>
    </allocation>
    <allocation>
      <guid>2573c59f-d67f-499a-aa56-4c4a99049c36</guid>
      <product_pool>
        <guid>c3f4dc11-14da-4674-8d9e-a78591bbf545</guid>
      </product_pool>
      <license>
        <guid>5630a774-628b-4443-8f8d-d3fd0c33cb31</guid>
        <identifier>osub_license</identifier>
      </license>
      <product_configuration>
        <duration>6m</duration>
        <languages type="array">
          <language>ITA</language>
        </languages>
      </product_configuration>
    </allocation>
    <allocation>
      <guid>d4ef2777-7c56-41f1-a012-24ec4497c891</guid>
      <product_pool>
        <guid>c3f4dc11-14da-4674-8d9e-a78591bbf545</guid>
      </product_pool>
      <license>
        <guid>5630a774-628b-4443-8f8d-d3fd0c33cb31</guid>
        <identifier>osub_license</identifier>
      </license>
      <product_configuration>
        <duration>6m</duration>
        <languages type="array">
          <language>ITA</language>
        </languages>
      </product_configuration>
    </allocation>
  </allocations>
</page>
</response>
]

    opts = {
      :guid => '99c81ec9-404e-4d9d-9355-32b3870dc865',
      :page => 2,
      :per_page => 3
    }

    ApiCommunicator.any_instance.expects(:api_call).with('product_pool', 'allocations', opts).at_least(1).returns(xml)

    page = @ls.product_pool.allocations(opts)

    assert_equal 4, page['total_pages']
    assert_equal 10, page['total_entries']
    assert_equal 3, page['allocations'].size
    assert_equal %w[FRA], page['allocations'][0]['product_configuration']['languages']
  end

  def test_allocation
    xml = allocation_detail_response

    opts = {
      :allocation_guid => 'b9a6ca92-710c-44f9-aded-67c094dc797e'
    }

    ApiCommunicator.any_instance.expects(:api_call).with('product_pool', 'allocation', opts).at_least(1).returns(xml)
    assert_not_nil allocation = @ls.product_pool.allocation(opts)

    assert_equal 'b9a6ca92-710c-44f9-aded-67c094dc797e', allocation[:guid]
    assert_equal ['ENG'], allocation[:product_configuration][:languages]
    assert_equal @time_plus_one_year, allocation[:product_configuration][:access_ends_at]
  end

private

  def allocation_detail_response
    %Q[
<response license_server_version="1.0">
<allocation>
  <guid>b9a6ca92-710c-44f9-aded-67c094dc797e</guid>
  <product_pool>
    <guid>6b537a4c-9543-489a-987f-c177f546b8c1</guid>
  </product_pool>
  <license>
    <guid>a56aad9a-7642-4ef5-bcdf-6861addba44a</guid>
    <identifier>osub_license</identifier>
  </license>
  <product_configuration>
    <languages type="array">
      <language>ENG</language>
    </languages>
    <access_ends_at type="integer">#{@time_plus_one_year.to_i}</access_ends_at>
  </product_configuration>
</allocation>
</response>
]
  end

  def deleted_allocation_detail_response
    %Q[
<response license_server_version="1.0">
<allocation>
  <guid>b9a6ca92-710c-44f9-aded-67c094dc797e</guid>
  <deleted type="boolean">true</deleted>
  <product_pool>
    <guid>6b537a4c-9543-489a-987f-c177f546b8c1</guid>
  </product_pool>
  <license>
    <guid>a56aad9a-7642-4ef5-bcdf-6861addba44a</guid>
    <identifier>osub_license</identifier>
  </license>
  <product_configuration>
    <languages type="array">
      <language>ENG</language>
    </languages>
    <access_ends_at type="integer">#{@time_plus_one_year.to_i}</access_ends_at>
  </product_configuration>
</allocation>
</response>
]
  end

end