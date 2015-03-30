PLUGIN_LIST = Dir.glob(File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'plugins', '*')).select {|dir| File.directory?(dir)}.map {|dir| File.basename(dir)} unless defined?(PLUGIN_LIST)
RAKE_GEM_LIST = Dir.glob(File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'gems', '*', 'Rakefile')).map {|dir| File.dirname(dir)} unless defined?(RAKE_GEM_LIST)

namespace :test do
  desc "Run tests, stopping on errors"
  task :stop_on_error do
    ENV['TEST_STOP_ON_ERROR'] = "true"
    errors = %w(test:units test:functionals test:integration).collect do |task|
      Rake::Task[task].invoke
    end
  end

  desc "This task runs all tests (well, only ones that are not dynamically defined) individually in a ruby command."
  task :run_all_tests_individually do
    system(%Q[grep -nr "def test" test/ | fgrep -v .svn | egrep -v ':[ ]*#' | sed -e "s/^/ruby /" | cut -d":" -f 1,3  | sed -e "s/:[ ]*def/ -n/" | sort | bash])
  end

  desc "Run each test file within test/ (or other directory specified by directory=) with a separate ruby command"
  task :run_each_test_file_individually do
    test_dir = ENV['directory'] || 'test'
    Dir.glob(File.expand_path(test_dir) + '/**/*_test.rb').each do |test_file|
      command = "ruby #{test_file}"
      puts command
      system command
    end
  end

  module RecursiveTestTaskCreator
    class << self
      include Rake::DSL if defined?(Rake::DSL) # newer versions of rake (0.9.2+?) want this

      def recursively_make_test_runner_rake_tasks_for_dir(dir)
        make_test_runner_rake_task_for_dir(dir)
        namespace File.basename(dir).to_sym do
          (Dir.new(dir).entries - [".", ".."]).each do |entry|
            path = File.join(dir, entry)
            recursively_make_test_runner_rake_tasks_for_dir(path) if File.directory?(path)
          end
        end
      end

      def make_test_runner_rake_task_for_dir(dir)
        task_name = File.basename(dir).to_sym
        pattern = File.join(dir, "**", "*_test.rb")
        Rake::TestTask.new(task_name => "db:test:prepare") do |t|
          t.libs << "test"
          t.pattern = pattern
          t.verbose = true
        end
        Rake::Task[task_name].prerequisites << 'db:test:prepare'
        Rake::Task[task_name].comment = "Run the tests in #{dir.inspect}"
      end
    end
  end
  
  #Add a rake test:[units|functionals|integrations] task for each of the directories under test/[unit|functional|integration]
  [:unit, :functional, :integration].each do |test_type|
    namespace "#{test_type}s".to_sym do
      Dir.glob("test/#{test_type}/*").select{|dir| File.directory?(dir)}.each do |dir|
        RecursiveTestTaskCreator.recursively_make_test_runner_rake_tasks_for_dir(dir)
      end
    end
  end

  # these tasks assume that you have defined TESTABLE_GEMS in your app
  desc "Run tests on gems that are considered 'testable' in this app"
  task :testable_gems do
    TESTABLE_GEMS.each do |gem|
      gem_task = "test:gem:#{gem}"
      raise "Tried to test gem '#{gem}' but it was not found" unless Rake::Task.task_defined?(gem_task)
      Rake::Task[gem_task].invoke
    end
  end

  # create rake tasks to test each gem in the form of test:plugin:gem_name
  RAKE_GEM_LIST.each do |gem_dir|
    gem_with_version = File.basename(gem_dir)
    gem_name = gem_with_version.gsub(/-[^-]+$/,'')
    desc "Run tests for the #{gem_name} gem"
    task "gem:#{gem_name}" do
      begin
        initial_dir = File.expand_path('.')
        Dir.chdir(gem_dir)
        ENV['CI_REPORTS'] = File.join(gem_dir, '..', '..', '..', 'test', 'reports')
        if File.exists?('../../../rake')
          system('../../../rake')
        else
          system('rake')
        end
      ensure
        Dir.chdir(initial_dir)
      end
    end
  end

  # create rake tasks to test each plugin in the form of test:plugin:plugin_name
  PLUGIN_LIST.each do |plugin|
    desc "Run tests for the #{plugin} plugin"
    Rake::TestTask.new("plugin:#{plugin}".to_sym) do |t|
      t.libs << "test"
      t.pattern = "vendor/plugins/#{plugin}/test/**/*_test.rb"
      t.verbose = true
    end
    Rake::Task["plugin:#{plugin}"].prerequisites << 'db:test:prepare' if Rake::Task.task_defined?('db:test:prepare')
    # set up plugin fixtures if we are using engines
    Rake::Task["plugin:#{plugin}"].prerequisites << 'test:plugins:setup_plugin_fixtures' if Rake::Task.task_defined?('test:plugins:setup_plugin_fixtures')
  end

  # these tasks assume that you have defined TESTABLE_PLUGINS in your app

  desc "Run tests on plugins that are considered 'testable' in this app"
  task :testable_plugins do
    TESTABLE_PLUGINS.each do |plugin|
      plugin_task = "test:plugin:#{plugin}"
      raise "Tried to test plugin '#{plugin}' but it was not found" unless Rake::Task.task_defined?(plugin_task)
      Rake::Task[plugin_task].invoke
    end
  end

  desc "Lists the plugins that are tested in test:testable_plugins"
  task :list_tested_plugins do
    puts(TESTABLE_PLUGINS.sort.join("\n"))
  end

  desc "Lists the plugins that aren't tested in test:testable_plugins"
  task :list_untested_plugins do
    puts((PLUGIN_LIST - TESTABLE_PLUGINS).sort.join("\n"))
  end

  # see tests defined in lib/test/migration
  desc "Run the migration tests"
  Rake::TestTask.new(:migration => [:environment, 'db:test:prepare']) do |t|
    t.libs << "test"
    t.pattern = File.join(File.dirname(__FILE__), '..', 'rosetta_stone', 'test', 'migration', '**', '*_test.rb')
    t.verbose = true
  end

  # see tests defined in lib/test/system_readiness
  desc "Run the system readiness tests"
  Rake::TestTask.new(:system_readiness => :environment) do |t|
    t.libs << "test"
    t.pattern = File.join(File.dirname(__FILE__), '..', 'rosetta_stone', 'test', 'system_readiness', '**', '*_test.rb')
    t.verbose = true
  end

  # see tests defined in lib/test/system_readiness
  if defined?(Rails)
    desc "Run the post-deployment tests"
    Rake::TestTask.new(:post_deployment => :environment) do |t|
      root_path = ::Rails.respond_to?(:root) ? ::Rails.root.to_s : RAILS_ROOT
      t.pattern = File.join(root_path, 'test', 'post_deployment', '**', '*_test.rb')
      t.verbose = true
    end
  end

  # change all Test::Unit::TestCase to ActiveSupport::TestCase
  desc "Change all test cases to inherit from ActiveSupport::TestCase instead of Test::Unit::TestCase"
  task :upgrade_to_rails_2_3 do
    Dir.glob("test/**/*.rb") do |filename|
      old_file = File.open(filename).read
      search_string = "Test::Unit::TestCase"
      unit_test = !filename.match(/\/unit\//).nil?
      replace_string = "ActiveSupport::TestCase" if unit_test
      functional_test = !filename.match(/\/functional\//).nil?
      replace_string = "ActionController::TestCase" if functional_test
      integration_test = !filename.match(/\/integration\//).nil?
      replace_string = "ActionController::IntegrationTest" if integration_test

      new_file = ""
      line_matched = false
      old_file.each_line do |line|

        if line.match(/#{search_string}/)
          line_matched = true
          line.gsub!(/#{search_string}/,replace_string)
        end
        new_file << line
      end
      #Only write out changes if there are changes to be made
      if line_matched
        File.open(filename,'w') {|f| f.write(new_file)}
      end
    end
  end

  desc "Used to test that the exception notifier task works"
  task :exception_notification_enabled  => [:environment,:notify_on_exception] do
    raise "Exception that should be thrown to hoptoad!"
  end

  desc "Used to test that the exception notifier does nothing if it's not included in the prereqs"
  task :exception_notification_disabled => [:environment] do
    raise "Exception that should just be thrown to the screen (not to hoptoad)"
  end

end
