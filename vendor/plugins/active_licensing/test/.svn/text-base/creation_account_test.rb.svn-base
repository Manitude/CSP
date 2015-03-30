# -*- encoding : utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))

class RosettaStone::ActiveLicensing::CreationAccountTest < Test::Unit::TestCase
  include RosettaStone::ActiveLicensing

  def setup
    @ls = RosettaStone::ActiveLicensing::Base.instance
  end

  def test_creation_account_returns_integer_when_license_count_is_called
    opts = {:creation_account => "some_creation_account"}
    xml = %q[<response license_server_version="1.0"><license_count>37</license_count></response>]
    ApiCommunicator.any_instance.expects(:api_call).with('creation_account', 'license_count', opts).at_least(1).returns(xml)

    assert_equal 37, @ls.creation_account.license_count(opts)
  end

  def test_creation_account_returns_an_array_of_licenses_when_licenses_is_called
    opts = {:creation_account => "some_creation_account", :created_after => 0, :created_before => Time.now.to_i}
    xml = %q[<response license_server_version="1.0">
      <licenses>
        <license>
          <usable>true</usable>
          <test>false</test>
          <identifier>zkt-d_1551_ENG-LA-3M_01242007_0311</identifier>
          <created_at>1169604552</created_at>
          <active>true</active>
        </license>
      </licenses>
    </response>]
    ApiCommunicator.any_instance.expects(:api_call).with('creation_account', 'licenses', opts).at_least(1).returns(xml)

    assert_equal [{"usable"=>true, "test"=>false, "identifier"=>"zkt-d_1551_ENG-LA-3M_01242007_0311", "created_at"=> Time.at(1169604552), "active"=> true }], @ls.creation_account.licenses(opts)
  end

  def test_details
    xml = %Q[<response license_server_version="1.0">
    <creation_account>
      <identifier>zkt</identifier>
      <test>false</test>
      <licenses_require_password>true</licenses_require_password>
      <maximum_active_licenses></maximum_active_licenses>
      <active_license_count>3</active_license_count>
      <available_license_count></available_license_count>
      <created_at>1175545336</created_at>
    </creation_account>
    </response>]

    opts = {:creation_account => "zkt"}
    ApiCommunicator.any_instance.expects(:api_call).with('creation_account', 'details', opts).once.returns(xml)

    details = @ls.creation_account.details(opts)
    assert_equal({
      "licenses_require_password" => true,
      "maximum_active_licenses" => nil,
      "available_license_count" => nil,
      "active_license_count" => "3",
      "test" => false,
      "identifier" => "zkt",
      "created_at" => Time.at(1175545336),
    }, details)
  end

  def test_available_products_when_they_exist_on_the_creation_account
    xml = %Q[<response license_server_version="1.0">
      <available_products>
        <available_product product_identifier="ALL" product_version="2">
          <type>date_range</type>
          <active>false</active>
          <usable>false</usable>
          <demo>false</demo>
          <access_starts_at>1092092400</access_starts_at>
          <access_ends_at>1191106800</access_ends_at>
          <created_at>0</created_at>
          <duration></duration>
        </available_product>
        <available_product product_identifier="ESP" product_version="2">
          <type>date_range</type>
          <active>true</active>
          <usable>true</usable>
          <demo>false</demo>
          <access_starts_at>1092092400</access_starts_at>
          <access_ends_at>1191106800</access_ends_at>
          <created_at>0</created_at>
          <duration></duration>
        </available_product>
      </available_products>
    </response>]

    opts = {:creation_account => "OLLC::army1"}

    ApiCommunicator.any_instance.expects(:api_call).with('creation_account', 'available_products', opts).once.returns(xml)
    available_products = @ls.creation_account.available_products(opts)

    assert_equal [
      {"product_version"=>"2", "access_ends_at"=>Time.at(1191106800), "usable"=>false, "demo"=>false, "type"=>"date_range", "access_starts_at"=>Time.at(1092092400), "product_identifier"=>"ALL", "duration"=>nil, "content_ranges"=>["all"], "created_at"=>Time.at(0), "active"=>false},
      {"product_version"=>"2", "access_ends_at"=>Time.at(1191106800), "usable"=>true, "demo"=>false, "type"=>"date_range", "access_starts_at"=>Time.at(1092092400), "product_identifier"=>"ESP", "duration"=>nil, "content_ranges"=>["all"], "created_at"=> Time.at(0), "active"=>true}
    ], available_products
  end

  def test_available_products_when_available_products_is_only_whitespace
    xml = %Q[<response license_server_version="1.0">
      <available_products>
      </available_products>
    </response>]

    opts = {:creation_account => "OLLC::army1"}

    ApiCommunicator.any_instance.expects(:api_call).with('creation_account', 'available_products', opts).once.returns(xml)
    available_products = @ls.creation_account.available_products(opts)

    assert_equal [], available_products
  end

  # note, this looks like it's the same as the test above but apparently it's parsed differently
  # this one hits the "rescue []" instead of the "|| []"
  def test_available_products_when_available_products_are_empty
    xml = %Q[<response license_server_version="1.0">
      <available_products></available_products>
    </response>]

    opts = {:creation_account => "OLLC::army1"}

    ApiCommunicator.any_instance.expects(:api_call).with('creation_account', 'available_products', opts).once.returns(xml)
    available_products = @ls.creation_account.available_products(opts)

    assert_equal [], available_products
  end

  def test_api_category
    assert_equal "creation_account", @ls.creation_account.send(:api_category)
  end

  def test_product_pools_when_none_returned
    opts = {:creation_account => "OLLC::army1"}

    ApiCommunicator.any_instance.expects(:api_call).with('creation_account', 'product_pools', opts).once.returns(product_pools_xml(0))
    assert_not_nil no_pools = @ls.creation_account.product_pools(opts)

    assert_equal [], no_pools
  end

  def test_product_pools_with_one_pool
    opts = {:creation_account => "OLLC::army1"}

    ApiCommunicator.any_instance.expects(:api_call).with('creation_account', 'product_pools', opts).once.returns(product_pools_xml(1))
    assert_not_nil product_pools = @ls.creation_account.product_pools(opts)

    assert_equal(1, product_pools.size)
    assert_equal 'pooled_creation_account', product_pools.first[:creation_account][:identifier]
    assert_equal '6m', product_pools.first[:product_configuration][:duration]
  end

  def test_product_pools_with_four_pools
    opts = {:creation_account => "OLLC::army1"}

    ApiCommunicator.any_instance.expects(:api_call).with('creation_account', 'product_pools', opts).once.returns(product_pools_xml(4))
    assert_not_nil product_pools = @ls.creation_account.product_pools(opts)

    assert_equal(4, product_pools.size)
    assert_equal 'pooled_creation_account', product_pools.last[:creation_account][:identifier]
    assert_equal '6m', product_pools.last[:product_configuration][:duration]
  end

private

  def product_pools_xml(count = 0)
    %Q[
      <response license_server_version="1.0">
        <product_pools type='array'>
          #{([product_pool_xml] * count).join("\n")}
        </product_pools>
      </response>
    ].strip
  end

  def product_pool_xml
    %Q[
      <product_pool>
        <guid>#{RosettaStone::UUIDHelper.generate}</guid>
        <creation_account>
          <identifier>pooled_creation_account</identifier>
          <guid>325b3e5a-f50f-49ef-8850-bd08c2cbb5e0</guid>
        </creation_account>
        <product_bundle>
          <name>course</name>
          <guid>0d39a27d-1d9e-4d62-bdd7-02ce44ef6a9a</guid>
        </product_bundle>
        <starts_at type="integer">1364328481</starts_at>
        <expires_at type="integer">1395864481</expires_at>
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
    ].strip
  end
end
