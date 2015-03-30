# -*- encoding : utf-8 -*-
require File.expand_path('test_helper', File.dirname(__FILE__))

class RosettaStone::ActiveLicensing::ApiCommunicatorTest < Test::Unit::TestCase
  include RosettaStone::ActiveLicensing

  def setup
    @connection_opts = { :host => 'local', :port => 12345, :endpoint_path => '/api/', :proxy_host => 'proxy', :proxy_port => '31244', :api_username => 'test', :api_password => 'yo' }
    @api_communicator = ApiCommunicator.new(@connection_opts)
    @multicall_api_communicator = MulticallApiCommunicator.new(@connection_opts)
    RosettaStone::ActiveLicensing.allow_real_api_calls_in_test_mode!
  end

  def teardown
    RosettaStone::ActiveLicensing.stop_allowing_real_api_calls_in_test_mode!
  end

  def test_connection_options_turn_into_instance_variables_for_attribute_readers
    @connection_opts.each do |k,v|
      assert_equal v, @api_communicator.send(k)
    end
  end

  def test_request_path_concatenates_endpoint_path_api_category_and_method_name
    assert_equal "/api/cat/meth", @api_communicator.send(:request_path, "cat", "meth")
  end

  def test_request_path_adds_opts_as_query_string
    assert_equal "/api/cat/meth?yes=itdoes", @api_communicator.send(:request_path, "cat", "meth", { :yes => "itdoes" })
  end

  def test_explicitly_enabling_real_api_calls_in_test_mode_will_hit_simple_http
    SimpleHTTP::Client.any_instance.expects(:get).once.returns(mock(:body => 'cat'))
    Rails.expects(:test?).never # in this case the override takes over
    RosettaStone::ActiveLicensing.allow_real_api_calls_in_test_mode!
    assert_nothing_raised do
      @api_communicator.api_call("cat", "meth", :yes => "itdoes")
    end
  end

  def test_explicitly_disabling_real_api_calls_in_test_mode_will_not_hit_simple_http
    SimpleHTTP::Client.any_instance.expects(:get).never
    Rails.expects(:test?).returns(true)
    RosettaStone::ActiveLicensing.stop_allowing_real_api_calls_in_test_mode!
    assert_raises(RuntimeError) do
      @api_communicator.api_call("cat", "meth", :yes => "itdoes")
    end
  end

  def test_does_not_raise_in_non_test_mode_even_if_override_setting_does_not_allow_requests
    SimpleHTTP::Client.any_instance.expects(:get).once.returns(mock(:body => 'cat'))
    Rails.expects(:test?).returns(false)
    RosettaStone::ActiveLicensing.stop_allowing_real_api_calls_in_test_mode!
    assert_nothing_raised do
      @api_communicator.api_call("cat", "meth", :yes => "itdoes")
    end
  end

  def test_does_not_raise_in_non_test_mode_if_override_setting_does_allow_requests
    SimpleHTTP::Client.any_instance.expects(:get).once.returns(mock(:body => 'cat'))
    Rails.expects(:test?).never # in this case the override takes over
    RosettaStone::ActiveLicensing.allow_real_api_calls_in_test_mode!
    assert_nothing_raised do
      @api_communicator.api_call("cat", "meth", :yes => "itdoes")
    end
  end

  def test_calling_api_call_completes_an_http_get_request_to_the_license_server
    SimpleHTTP::Client.any_instance.expects(:get).with("/api/cat/meth?yes=itdoes").returns(mock(:body => 'yes'))
    assert_equal "yes", @api_communicator.api_call("cat", "meth", :yes => "itdoes")
  end

  def test_calling_api_post_completes_an_http_post_request_to_the_license_server
    SimpleHTTP::Client.any_instance.expects(:post).with("/api/cat/meth", :data => "a cat on meth").returns(mock(:body => 'yes'))
    assert_equal "yes", @api_communicator.api_post("cat", "meth", "a cat on meth")
  end

  def test_calling_api_post_with_a_hash_for_data
    SimpleHTTP::Client.any_instance.expects(:post).with("/api/cat/meth", :data => 'license=kstarling&password=whatever').returns(mock(:body => 'yes'))
    assert_equal "yes", @api_communicator.api_post("cat", "meth", {:license => 'kstarling', :password => 'whatever'})
  end

  def test_calling_api_post_with_a_hash_for_data_escapes_the_data_properly
    SimpleHTTP::Client.any_instance.expects(:post).with("/api/cat/meth", :data => 'license=%24%26%5E%3B%3F%22').returns(mock(:body => 'yes'))
    assert_equal "yes", @api_communicator.api_post("cat", "meth", {:license => '$&^;?"'})
  end

  def test_setting_no_api_credentials_doesnt_do_basic_auth
    connection_opts = @connection_opts.except(:api_username, :api_password)
    api_communicator = ApiCommunicator.new(connection_opts)
    SimpleHTTP::Client::Get.any_instance.expects(:attributes=).with do |attr_hash|
      attr_hash[:http_user].nil? && attr_hash[:http_password].nil?
    end
    SimpleHTTP::Client::Get.any_instance.expects(:go!).returns(mock(:body => 'yes'))
    assert_equal "yes", api_communicator.api_call("cat", "meth", :yes => "itdoes")
  end

  def test_setting_api_credentials_sets_basic_auth_options
    SimpleHTTP::Client::Get.any_instance.expects(:attributes=).with do |attr_hash|
      attr_hash[:http_user] == 'test' && attr_hash[:http_password] == 'yo'
    end
    SimpleHTTP::Client::Get.any_instance.expects(:go!).returns(mock(:body => 'yes'))
    assert_equal "yes", @api_communicator.api_call("cat", "meth", :yes => "itdoes")
  end

  def test_setting_credentials_works
    SimpleHTTP::Client::Get.any_instance.expects(:attributes=).with do |attr_hash|
      attr_hash[:http_user] == 'some crazy user' && attr_hash[:http_password] == 'some crazy password'
    end
    SimpleHTTP::Client::Get.any_instance.expects(:go!).returns(mock(:body => 'yes'))
    @api_communicator.set_credentials('some crazy user', 'some crazy password')
    assert_equal "yes", @api_communicator.api_call("cat", "meth", {:yes => "itdoes"})
  end

  def test_timeout_error_is_handled_by_three_retries_before_throwing_license_server_exception
    SimpleHTTP::Client::Get.any_instance.expects(:net_http).times(3).raises(Timeout::Error)
    assert_raises(ConnectionException) { @api_communicator.api_call("cat", "meth", {:yes => "itdoes"}) }
  end

  def test_socket_error_for_bad_hostname_raises_license_server_exception
    SimpleHTTP::Client::Get.any_instance.expects(:net_http).at_least(1).raises(SocketError)
    assert_raises(ConnectionException) { @api_communicator.api_call("cat", "meth", {:yes => "itdoes"}) }
  end

  def test_connection_refused_raises_license_server_exception
    SimpleHTTP::Client::Get.any_instance.expects(:net_http).at_least(1).raises(Errno::ECONNREFUSED)
    assert_raises(ConnectionException) { @api_communicator.api_call("cat", "meth", {:yes => "itdoes"}) }
  end

  ############## From here down is Multicall tests ##############

  def test_queued_calls_is_initally_empty
    assert @multicall_api_communicator.queued_calls.blank?
  end

  def test_multicall_does_not_send_request_when_there_are_no_queued_calls_specified
    SimpleHTTP::Client.any_instance.expects(:post).never
    assert_raises(RosettaStone::ActiveLicensing::NoApiCallsSpecified) do
      @multicall_api_communicator.dispatch_calls
    end
  end

  def test_calling_api_call_in_multi_call_mode_queues_the_call_instead_of_sending_api_request
    @multicall_api_communicator.expects(:queue_call).with("cat", "meth", {:yes => "itdoes"}).returns(true)
    assert_equal :defer_handling, @multicall_api_communicator.api_call("cat", "meth", {:yes => "itdoes"})
  end

  def test_calling_api_call_in_multi_call_mode_always_returns_defer_handling
    assert_equal :defer_handling, @multicall_api_communicator.api_call("cat", "meth", {:yes => "itdoes"})
  end

  def test_calling_queue_call_adds_to_the_queued_calls_array
    @multicall_api_communicator.queued_calls.expects(:<<).with({:api_category => "cat", :method_name => "meth", :params => {:yes => "itdoes"}}).returns(true)
    assert @multicall_api_communicator.send(:queue_call, "cat", "meth", {:yes => "itdoes"})
  end

  def test_license_server_request_xml_creates_some_general_wrapping_xml
    assert_match(/<request.*><\/request>/, (@api_communicator.send(:license_server_request_xml) {}).gsub(/\s/,''))
  end

  def test_license_server_request_xml_puts_the_content_of_the_block_inside_the_wrapping_xml
    assert_match(/<request.*><hello>there<\/hello><\/request>/, (@api_communicator.send(:license_server_request_xml) { |xml| xml.hello 'there' }).gsub(/\s/,''))
  end

  def test_multicall_request_xml_generates_correct_xml
    @multicall_api_communicator.instance_eval { @queued_calls = [{:api_category => 'cat', :method_name => 'meth', :params => nil}, {:api_category => 'cat2', :method_name => 'meth2', :params => {:yes => 'okay'}}] }

    expected_xml = %q[<multicall>
      <call path="/api/cat/meth">
      </call>
      <call path="/api/cat2/meth2">
        <parameter name="yes">okay</parameter>
      </call>
    </multicall>].gsub(/\>\s*\</,'><')
    assert_match(/#{expected_xml}/, @multicall_api_communicator.send(:multicall_request_xml).gsub(/\>\s*\</,'><'))
  end

  def test_multicall_request_xml_iterates_over_the_queued_calls
    @multicall_api_communicator.instance_eval { @queued_calls = [{:api_category => 'cat', :method_name => 'meth', :params => nil}, {:api_category => 'cat2', :method_name => 'meth2', :params => {:yes => 'okay'}}] }
    @multicall_api_communicator.queued_calls.expects(:each).at_least(1)

    @multicall_api_communicator.send(:multicall_request_xml)
  end

  def test_setting_api_credentials_works_on_multicall_also
    SimpleHTTP::Client::Post.any_instance.expects(:attributes=).with do |attr_hash|
      attr_hash[:http_user] == 'test' && attr_hash[:http_password] == 'yo'
    end
    SimpleHTTP::Client::Post.any_instance.expects(:go!).returns(mock(:body => "<returned>xml</returned>"))

    xml = "<fake>clearly</fake>"
    @multicall_api_communicator.instance_eval { @queued_calls = [{:also_clearly_fake => true}] }
    @multicall_api_communicator.expects(:multicall_request_xml).at_least(1).returns(xml)
    assert @multicall_api_communicator.dispatch_calls
  end

  def test_dispatch_multi_call_sends_an_http_post
    xml = "<fake>clearly</fake>"
    @multicall_api_communicator.instance_eval { @queued_calls = [{:also_clearly_fake => true}] }
    mocked_http = mock
    mocked_http.expects(:post).with("/api/multicall/index", :data => xml, :headers => {'Content-Type' => 'application/xml'}).returns(mock(:body => "<returned>xml</returned>"))
    @multicall_api_communicator.expects(:multicall_request_xml).at_least(1).returns(xml)
    @multicall_api_communicator.expects(:http_client).returns(mocked_http)
    assert @multicall_api_communicator.dispatch_calls
  end

  def test_dispatch_multi_call_clears_the_queued_calls_after_post
    @multicall_api_communicator.instance_eval { @queued_calls = [{:api_category => 'cat', :method_name => 'meth', :params => nil}, {:api_category => 'cat2', :method_name => 'meth2', :params => {:yes => 'okay'}}] }

    SimpleHTTP::Client.any_instance.expects(:post).with do |path,options|
      (path == "/api/multicall/index") && (options[:headers]["Content-Type"] == "application/xml") && (options[:data] =~ /<multicall/)
    end.returns(mock(:body => ''))

    assert @multicall_api_communicator.dispatch_calls
    assert_equal [], @multicall_api_communicator.queued_calls
  end

  def test_dispatch_multi_call_clears_the_queued_calls_even_when_an_exception_is_raised
    @multicall_api_communicator.instance_eval { @queued_calls = [{:api_category => 'cat', :method_name => 'meth', :params => nil}, {:api_category => 'cat2', :method_name => 'meth2', :params => {:yes => 'okay'}}] }
    SimpleHTTP::Client::Post.any_instance.expects(:net_http).times(3).raises(Exception)

    assert_raises(ConnectionException) { @multicall_api_communicator.dispatch_calls }
    assert_equal [], @multicall_api_communicator.queued_calls
  end

end
