# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

module RosettaStone
  module TestUnitExtensions
    include SayWithTime

    def self.included(klass)
      klass.extend(ClassMethods)
      klass.send(:include, InstanceMethods)
    end

    module ClassMethods

      def self.included(klass)
        klass.send(:class_inheritable_hash, :descriptions_for_test_methods)
      end

      if ActiveSupport::VERSION::MAJOR >= 3 && ActiveSupport::VERSION::MINOR >= 2
        def define_test(description, &test_definition)
          method_name = 'test_' + description.strip.gsub(/[^a-zA-Z0-9\s]/, '').gsub(/\s/, '_').downcase
          method_name = method_name.to_sym
          class_attribute :descriptions_for_test_methods
          self.descriptions_for_test_methods = {method_name => description}
          define_method(method_name, &test_definition)
        end
      else
        def define_test(description, &test_definition)
          method_name = 'test_' + description.strip.gsub(/[^a-zA-Z0-9\s]/, '').gsub(/\s/, '_').downcase
          method_name = method_name.to_sym
          write_inheritable_hash :descriptions_for_test_methods, {method_name => description}
          define_method(method_name, &test_definition)
        end
      end

      def load_all_fixtures(*except_these)
        fixtures(get_ordered_fixture_list - except_these.flatten.map(&:to_s))
      end

      def get_ordered_fixture_list
        # manually constructed list in proper order for loading
        fixture_list = defined?(ORDERED_FIXTURE_LIST) ? ORDERED_FIXTURE_LIST : []

        # find and append any other fixtures hanging out in test/fixtures/
        fixture_path =
          (defined?(ActiveSupport::TestCase) && ActiveSupport::TestCase.respond_to?(:fixture_path) ?
            ActiveSupport::TestCase.fixture_path :
            File.join(Framework.root, 'test', 'fixtures'))
        fixture_list = fixture_list +
          (ENV['FIXTURES'] ?
            ENV['FIXTURES'].split(/,/) :
            Dir.glob(File.join(fixture_path, '*.{yml,csv}'))
        ).collect { |fixture_file|  File.basename(fixture_file, '.*') }
        fixture_list.uniq
      end

      # if you want to add these meta tests to every ActionController::TestCase class,
      # call this method from your test_helper.rb file.  if you want to add them to
      # just a few functional test classes, require and include
      # RosettaStone::ActionControllerMetaTests in those classes.
      def add_filter_chain_meta_tests_to_all_action_controller_test_case_classes!
        require 'rosetta_stone/test/action_controller_meta_tests'
        ActionController::TestCase.class_eval do
          def self.inherited(subclass)
            super(subclass)
            subclass.class_eval do
              include RosettaStone::ActionControllerMetaTests
            end
          end
        end
      end

    end # ClassMethods

    module InstanceMethods

      # Temporarily makes the given methods on object public before restoring to the original visibility
      def publicize(object, *methods)
        raise "Requires a block" unless block_given?
        sc = object.singleton_class
        restore = methods.inject({}) do |vis_rec,method_name|
          v = [:private, :protected, :public].detect {|vis| sc.send(:"#{vis}_instance_methods").map(&:to_s).include?(method_name.to_s)}
          (vis_rec[v] ||= []) << method_name
          vis_rec
        end
        restore.values.flatten.each { |m| sc.send(:public, m) }
        yield
      ensure
        restore.each do |visibility,methods|
          methods.each { |m| sc.send(visibility, m) }
        end
      end

      if RUBY_VERSION =~ /^1\.8/
        def name
          description = descriptions_for_test_methods.nil? ? nil : descriptions_for_test_methods[@method_name.to_sym]
          if description
            "#{description}\n(method: #{@method_name}) (#{self.class.name})"
          else
            "#{@method_name} (#{self.class.name})"
          end
        end
      end

      def assert_redirected_to_matches(pattern, message = nil)
        assert_response :redirect
        if Rails::VERSION::MAJOR >= 3
          $stderr.puts('WARNING: You are trying to call assert_redirect_to_matches with an argument that is not a regular expression or string. Please use assert_redirected_to instead.') unless pattern.is_a?(Regexp) || pattern.is_a?(String)
          assert_match(pattern, @response.redirect_url, message)
        else
          assert_match(pattern, @response.redirected_to.to_s, message)
        end
      end

      def assert_redirected_to_no_match(pattern, message = nil)
        assert_response :redirect
        assert_no_match(pattern, @response.redirected_to.to_s, message)
      end

      # NOTE: this is only defined for Rails < 2.  In Rails 2.x, it is part of Rails, so we don't override it.
      # Note also that the method signatures differ!
      #
      # assert_difference(Publication) do
      #   post :create, :publication => { .... }
      # end
      #
      # Encapsulates the pattern of taking a measurement, doing some stuff, then comparing to
      # another measurement.
      if defined?(Rails) && Rails::VERSION::MAJOR < 2
        def assert_difference(object, method = :count, difference = 1)
          initial_value = object.send(method)
          yield
          assert_equal initial_value + difference, object.send(method), "#{object}##{method}"
        end
      end

      # Asserts that an exception is raised with a specific message contained in the exception.
      def assert_raise_with_message(exception, message, &block)
        assert_raise(exception) do
          begin
            block.call
          rescue => e
            assert_match message, e.message
            raise e
          end
        end
      end

      def assert_equal_arrays(expected, actual, message = "")
        first_differences = (actual - expected)
        second_differences = (expected - actual)
        differences = (first_differences + second_differences).uniq
        full_message = build_message(message, <<EOT, expected, actual, differences)
<?> expected but was
<?>.
Differences are:
<?>
EOT
        assert_block(full_message) { differences.empty? }
      end

      if defined?(Rails) && Rails::VERSION::MAJOR >= 3
        def assert_errors_on(object, attribute, error_message = //, message = nil)
          assert_false object.valid?
          message ||= "Expected error on #{attribute} but validation errors were: #{object.errors.full_messages}"
          assert_block(message) do
            !object.errors[attribute].grep(error_message).empty?
          end
        end

        def assert_no_errors_on(object, attribute, error_message = //, message = '')
          assert_block(message) do
            object.errors[attribute].grep(error_message).empty?
          end
        end
      else
        def assert_errors_on(object, attribute, error_message = //, message = nil)
          assert_false object.valid?
          message ||= "Expected error on #{attribute} but validation errors were: #{object.errors.full_messages}"
          assert_block(message) do
            !Array(object.errors.on(attribute)).grep(error_message).empty?
          end
        end

        def assert_no_errors_on(object, attribute, error_message = //, message = '')
          assert_block(message) do
            Array(object.errors.on(attribute)).grep(error_message).empty?
          end
        end
      end

      # this wraps around the same method from the rails_tidy plugin to fail meaningfully & gracefully if you don't have tidy installed
      def assert_tidy(body = nil)
        unless ENV['skip_tidy']
          begin
            tidy_file = File.join(Rails.root, 'vendor', 'plugins', 'rails_tidy', 'lib', 'rails_tidy.rb')
            assert File.file?(tidy_file), "The 'rails_tidy.rb' file could not be found. Perhaps the plugin is not installed?"
            require tidy_file
            super
          rescue MissingSourceFile => e
            puts %Q{
#{e.inspect}
There was an exception when attempting to use rails_tidy. Skipping tidy assertions.
To install the compiled, platform-specific gem, run:
gem install tidy
or pass skip_tidy=true
            }
          end
        end
      end

      def assert_tidy_html_fragment(fragment = @response.body)
        flunk if fragment.blank?
        assert_tidy(valid_html_wrapper(fragment.to_s))
      end

      # this wraps the output from the EJS template so we can run assert_tidy on it
      # to test for HTML validity
      def valid_html_wrapper(content)
        %Q[
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
                "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
        <head>
          <title>tidy test</title>
        </head>
        <body>
        #{content}
        </body>
        </html>
        ]
      end

      def assert_valid_xml(potential_xml = @response.body)
        if defined?(LibXML::XML)
          assert_nothing_raised do
            LibXML::XML::Document.string(potential_xml)
          end
        elsif defined?(REXML)
          assert_nothing_raised do
            REXML::Document.new(potential_xml)
          end
        else
          raise "Couldn't find an XML parser to use"
        end
      end

      # for use in functional tests to ensure there are no stray actions
      # pass a list of action methods with an optional options hash as the last argument
      def assert_action_methods(*opts)
        options = opts.last.is_a?(Hash) ? opts.pop : {}
        action_methods = opts
        assert_equal_arrays(action_methods.map(&:to_s), action_methods_in_controller)
        assert_all_action_methods_are_routable unless options[:skip_routing_assertions]
      end

      def assert_all_action_methods_are_routable
        controller_routes = routes.map(&:requirements).select {|route| route[:controller] == @controller.controller_path }
        # if there is a generic route for any action in the controller (i.e. it includes :action), skip this assertion:
        return if controller_routes.any? {|route| route[:action].nil? }

        routed_actions_for_controller = controller_routes.map {|route| route[:action]}.uniq
        assert_equal_arrays(action_methods_in_controller, routed_actions_for_controller)
      end

      # for use in functional tests to introspect on controllers to catch places where you do something like
      # before_filter :y, :only => :x   where :x is not a defined action method
      def assert_all_filters_reference_existing_actions_in_only
        action_methods_referenced_in_filter_chain_by(:only).each do |specified_action_method|
          assert_true(action_methods_in_controller.include?(specified_action_method.to_s), "A filter's only condition references #{specified_action_method.inspect} which is not a valid action method among #{action_methods_in_controller.inspect}.")
        end
      end

      def assert_all_filters_reference_existing_actions_in_except
        action_methods_referenced_in_filter_chain_by(:except).each do |specified_action_method|
          assert_true(action_methods_in_controller.include?(specified_action_method.to_s), "A filter's except condition references #{specified_action_method.inspect} which is not a valid action method among #{action_methods_in_controller.inspect}.")
        end
      end

      def filter_chain
        @controller.class.send(Rails::VERSION::MAJOR >= 3 ? :_process_action_callbacks : :filter_chain)
      end

      # pass :only or :except
      def action_methods_referenced_in_filter_chain_by(mechanism = :only)
        if Rails::VERSION::MAJOR >= 3
          filter_chain.map do |filter|
            filter.options[mechanism]
          end.flatten.uniq.compact
        else
          filter_chain.map {|f| f.options[mechanism]}.compact.map(&:to_a).flatten.uniq
        end
      end
      private :action_methods_referenced_in_filter_chain_by

      # Returns the action methods in a controller
      #
      # Use a heuristic regex matcher to ignore actions that are suspected to have
      # been dynamically generated by before filters.
      def action_methods_in_controller
        @controller.class.action_methods.to_a.reject do |method_name|
          method_name.to_s =~ /^_/
        end
      end
      private :action_methods_in_controller

      # blarg. is there a better way to do this?
      def set_host_for_functionals_or_integrations(host)
        if integration_test? # integrations
          host!(host)
          return
        end
        @request.host = host unless @request.nil? # functionals
      end

      # returns true for integration tests, false otherwise
      def integration_test?
        is_a?(ActionController::IntegrationTest)
      end

      # often appropriate to use in your setup method
      def sending_test_emails!
        ActionMailer::Base.delivery_method = :test
        ActionMailer::Base.perform_deliveries = true
        ActionMailer::Base.deliveries = []
        @expected = TMail::Mail.new
        @expected.set_content_type('text', 'plain', {'charset' => 'utf-8'})
        @emails = ActionMailer::Base.deliveries
        @emails.clear
        assert_equal 0, @emails.size
      end

      def assert_email_count(expected_count)
        raise "You must call sending_test_emails! before assert_email_count" if @emails.nil?
        assert_equal(expected_count, @emails.size, "Expected #{expected_count} email(s) but got #{@emails.size}")
      end

      def assert_one_email
        assert_email_count(1)
      end

      def assert_no_emails
        assert_email_count(0)
      end

      def assert_email_to(email, address)
        assert email.to
        to = (email.to.class == Array) ? email.to.first : email.to
        if address.is_a? Regexp
          assert to =~ address
        else
          assert_equal to, address
        end
      end

      def assert_true(expression, *opts)
        assert_equal(true, expression, *opts)
      end

      def assert_false(expression, *opts)
        assert_equal(false, expression, *opts)
      end

      # For log entry testing
      def with_clean_log_file(&block)
        old_log_level = Rails.logger.level
        Rails.logger.level = 0 #:debug level
        @log_file_path ||= File.join(Rails.root, 'log', 'test.log')
        @log_file_size = File.size(@log_file_path) # store the current point in the file
        yield
      ensure
        Rails.logger.level = old_log_level
      end

      # Returns the contents of the log file since with_clean_log_file was invoked
      def log_file_entries
        new_entries = nil
        File.open(@log_file_path, 'r') do |log_file|
          log_file.pos = @log_file_size # wind forward to where the new entries start
          new_entries = log_file.read # read to the end of the file
        end
        new_entries
      end

      # hot. kb is awesome.
      def assert_select_on!(string)
        # using Mocha::Mockery instead of just mock() here because mock() is something else
        # if rspec is installed in the app
        @response = Mocha::Mockery.instance.named_mock('response_mock') do
          stubs(:content_type).returns('text/xml')
          stubs(:body).returns(string) # Rails < 2.3 style
        end
        self.stubs(:html_document).returns(HTML::Document.new(string, false, true)) # Rails 2.3+ style
        # this is a hack for Rails 2.3+ to include the module with assert_select if it's not already defined
        unless methods.map(&:to_s).include?('assert_select')
          if Rails::VERSION::MAJOR >= 3
            class_eval %Q[
              include ActionDispatch::Assertions::SelectorAssertions
            ]
          else
            class_eval %Q[
              include ActionController::Assertions::SelectorAssertions
            ]
          end
        end
      end

      # Random string, length <= max_length
      # Each character will be selected from ASCII codes 32 - 125
      #
      def build_rand_string(max_length = 64)
        Array.new(rand(max_length)).map { (rand(94) + 32).chr }.join('')
      end

      # Random string, length <= max_length
      # On average, half will be ASCII codes 32 - 125, others will be selected randomly from an array of "special" UTF-8 characters
      #
      def build_extended_rand_string(max_length = 64)
        Array.new(rand(max_length)).map { (rand < 0.5) ? (rand(94) + 32).chr : %w(ã é 美 国 ア メ リ カ т е)[rand(10)] }.join('')
      end

      # when pulling urls from a page, parameters will be separated with &amp;
      # however, with integration tests, we don't want to send requests like that
      def page_scrape(string)
        # assert that the string doesn't contain any *unescaped* ampersands, just for good measure:
        assert_equal string.scan('&amp;').size, string.scan('&').size
        string.gsub('&amp;', '&')
      end

      def assert_all_named_routes_specify_valid_controllers_and_actions(options = {})
        excluded_controllers = options[:excluded_controllers]
        routes.each do |route|
          assert_route_points_to_valid_controller_and_action(route, excluded_controllers)
        end
      end

      def assert_route_points_to_valid_controller_and_action(route, excluded_controllers = nil)
        return true unless snake_case_controller = route.requirements[:controller] # generic routes might not have this
        path = route.respond_to?(:path) ? route.path : route.segments.map(&:to_s).join # rails 2
        return true if path.to_s =~ %r{^/test/} # by convention, start paths for test-only routes with /test/ and they'll be ignored here
        assert(controller = snake_case_controller.controllerize.constantize, "Controller not found for '#{route.requirements[:controller]}'")
        return true if excluded_controllers && excluded_controllers.include?(controller) # almost always missing actions on resource-routed controllers, so give up
        return true unless action = route.requirements[:action]  # generic routes might not have this
        assert(controller.new.respond_to?(action), "Controller '#{controller}' does not respond to action '#{action}'.  If this is a resource-routed controller, consider adding it to the exclusion list in test/integration/routing_test.rb")
      end

      #extension to mocha expectations that checks to make sure an array parameter includes all of a list of passed in parameters
      def includes_all(expected_array_elements)
        all_matchers = expected_array_elements.map { |el| includes(el) }
        all_of(*all_matchers)
      end

      def routes
        if Rails::VERSION::MAJOR >= 3
          Rails.application.routes.routes
        else
          ActionController::Routing::Routes.routes
        end
      end

    end # InstanceMethods

  end
end

if defined?(Rails)
  current_env = ::Rails.respond_to?(:env) ? ::Rails.env : RAILS_ENV
elsif defined?(StoneStream)
  current_env = StoneStream::Environment.environment  
end

if current_env == 'test'
  require 'test/unit/testcase'
  Test::Unit::TestCase.send(:include, RosettaStone::TestUnitExtensions)
  Test::Unit::TestCase.send(:alias_method, :assert_very_close, :assert_in_delta)
end
