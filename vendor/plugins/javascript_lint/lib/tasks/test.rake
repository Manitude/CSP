
namespace :test do
  # see tests defined in lib/test
  desc "Run the javascript lint tests"
  Rake::TestTask.new(:javascript_lint => :environment) do |t|
    t.libs << "test"
    t.pattern = File.join(File.dirname(__FILE__), '..', 'test', '**', '*_test.rb')
    t.verbose = true
  end
end