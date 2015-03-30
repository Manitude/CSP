# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2008 Rosetta Stone
# License:: All rights reserved.

# tests that test our tests
# these tests typically get included into a unit test file in your app

module RosettaStone
  module MetaTest

    def test_no_test_files_are_improperly_named
      assert_equal('', get_rake_output('show:improperly_named_test_files'))
    end

    def test_no_duplicate_test_method_names
      assert_equal('', get_rake_output('show:duplicate_tests'))
    end

    def test_no_duplicate_test_class_names
      assert_equal('', get_rake_output('show:duplicate_test_classes'))
    end

    if Rails::VERSION::MAJOR < 3
      def test_rake_does_not_accidentally_load_environment
        assert_equal('nil', get_rake_output('show:is_environment_accidentally_loaded'))
      end
    end

    def test_cron_rake_tasks_are_valid_and_notify_on_failure
      #Must check that one of these is defined, and can't believe that GenericExceptionNotifier
      #is defined for some reason... meh?
      return if !defined?(HoptoadNotifier) && !defined?(ExceptionNotifier)
      crontab_file = File.join(Rails.root,'config','crontab')
      return unless File.exists?(crontab_file)
      dependency_str = get_rake_output('-P')
      dependencies = {}
      current_rake_task = "UNKNOWN"
      dependency_str.each_line do |line|
        match = line.match(/rake (.*)/)
        if match
          current_rake_task = match[1]
          dependencies[current_rake_task] = []
        else
          dependencies[current_rake_task] << line.strip
        end
      end
      crontab_entry = File.read(crontab_file)
      crontab_entry.each_line do |line|
        match = line.match(/^[^#]*rake\s*(--\w+)?\s+(\S+)/)
        if match
          assert_true dependencies.has_key?(match[2]), "The crontab calls the task '#{match[2]}', but that task is not defined."
          assert_true dependencies[match[2]].include?('notify_on_exception'), "The task '#{match[2]}' should have :notify_on_exception as a prerequisite"
        end
      end
    end

    if defined?(ActiveRecord)
      def test_validity_of_all_fixtures
        all_active_record_models.each do |model|
          if ActiveRecord::Base.connection.tables.include?(model.table_name)
            assert_validity_of_all_records(model)
          end
        end
      end
    end

    def test_syntax_of_erb_templates
      assert_equal('', get_rake_output('check_syntax:erb'))
    end

    def test_syntax_of_ruby_files
      assert_equal('', get_rake_output('check_syntax:ruby'))
    end

    def test_svn_externals_are_https
      assert_equal('', get_rake_output('svn:show_externals_not_using_https'))
    end

    # there needs to be a line near the top of config/boot.rb (or better yet, in config/preinitializer.rb)
    # that calls out the locally embedded rubygems version, if this rails app has embedded rubygems.  it looks like:
    # $LOAD_PATH.unshift(File.dirname(__FILE__) + "/../vendor/gems/rubygems-update-1.3.5/lib") or
    # $LOAD_PATH.unshift(Dir.glob(File.dirname(__FILE__) + "/../vendor/gems/rubygems-update-*/lib").last)
    def test_that_boot_rb_loads_embedded_rubygems
      rubygems_dirs = Dir.glob(File.join(Rails.root, 'vendor', 'gems', 'rubygems-update*'))
      assert(rubygems_dirs.size < 2, "Multiple embedded versions of rubygems found in vendor/gems")
      return unless rubygems_dirs.size == 1 # exit if you don't have embedded rubygems in this app
      relative_dir = rubygems_dirs.first.sub(Rails.root.to_s, '') + '/lib'
      # accept it in either config/preinitializer.rb or config/boot.rb
      preinitializer_contents = %w(boot.rb preinitializer.rb).map do |file|
        full_path = File.join(Rails.root, 'config', file)
        File.exist?(full_path) ? File.read(full_path) : ''
      end.join
      assert_match(%r{#{relative_dir}|Dir.glob.+vendor/gems/rubygems-update-\*/lib}, preinitializer_contents, "Failed to find the line in config/preinitializer.rb or config/boot.rb that loads embedded rubygems")
    end

  private
    def get_rake_output(task)
      `./rake --silent #{task} RAILS_ENV=development | fgrep -v "Using rake"`.strip
    end

    def all_active_record_models
      load_all_models
      ActiveRecord::Base.send(Rails::VERSION::MAJOR >= 3 ? :descendants : :subclasses)
    end

    # tries to invoke the constant for each model in order to get it loaded
    def load_all_models
      Dir.glob(File.join(models_base_directory, '**', '*.rb')).map {|file| file.gsub(models_base_directory, '').gsub(%r{\.rb$}, '')}.each do |model_file|
        camelized = model_file.camelize

        begin
          camelized.constantize  # like Reporting::TotalUsageData
        rescue NameError, LoadError
          begin
            camelized.split('::').last.constantize if camelized.include?('::') # like TotalUsageData
          rescue NameError, LoadError
          end
        end

      end
    end

    def models_base_directory
      File.join(Rails.root, 'app', 'models') + '/'
    end

    def assert_validity_of_all_records(model, options = {})
      model.find(:all).each do |some_object|
        assert(some_object.valid?, some_object.errors.full_messages.inspect + ". object: #{some_object.inspect}")
      end
    end
  end
end
