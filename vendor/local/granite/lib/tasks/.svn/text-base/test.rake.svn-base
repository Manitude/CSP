namespace :test do
  namespace :granite do

    Rake::TestTask.new('agents') do |t|
      t.libs << "test"
      t.pattern = "test/agents/**/*_test.rb"
      t.verbose = true
    end
  end
end
Rake::Task['test:granite:agents'].prerequisites << 'environment'

unless defined?(AVOID_TEST_GRANITE_AGENTS)
  Rake::Task[:default].prerequisites << 'test:granite:agents' if Rake::Task.task_defined?(:default)
end
