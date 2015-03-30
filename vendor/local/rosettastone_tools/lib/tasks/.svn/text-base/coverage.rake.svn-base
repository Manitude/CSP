rcov_path = Dir.glob(File.dirname(__FILE__) + '/../../../../gems/rcov-*').last
rcov_path = File.expand_path(rcov_path) if rcov_path
if rcov_path && File.directory?(rcov_path)
  begin
    require 'rcov/rcovtask'
    ENV['RCOVPATH'] = "#{rcov_path}/bin/rcov"

    namespace :test do
      desc 'Aggregate code coverage for unit, functional, agents and integration tests'
      Rcov::RcovTask.new(:coverage => [:'db:test:prepare']) do |t|
        t.libs << "test"
        t.test_files = FileList[%w[unit functional integration agents].map{|target|"test/#{target}/**/*_test.rb"}]
        t.output_dir = "tmp/coverage"
        t.verbose = true
        t.rcov_opts << "--rails --aggregate coverage.data --exclude '/usr/local,/opt/local,/Library'"
      end

      namespace :units do
        Rcov::RcovTask.new(:coverage => [:'db:test:prepare', :'db:migrate']) do |t|
          t.libs << 'test'
          t.rcov_opts = "--rails --aggregate coverage.data --exclude 'app/helpers/,app/controllers/,/usr/local,/opt/local,/Library'"
          t.output_dir = 'tmp/coverage/unit'
          t.test_files = FileList['test/unit/**/*_test.rb']
        end
      end

      namespace :functionals do
        Rcov::RcovTask.new(:coverage => [:'db:test:prepare', :'db:migrate']) do |t|
          t.libs << 'test'
          t.rcov_opts = "--rails --aggregate coverage.data --exclude '/usr/local,/opt/local,/Library'"
          t.output_dir = 'tmp/coverage/functional'
          t.test_files = FileList['test/functional/**/*_test.rb']
        end
      end

      namespace :integration do
        Rcov::RcovTask.new(:coverage => [:'db:test:prepare', :'db:migrate']) do |t|
          t.libs << 'test'
          t.rcov_opts = "--rails --aggregate coverage.data --exclude '/usr/local,/opt/local,/Library'"
          t.output_dir = 'tmp/coverage/integration'
          t.test_files = FileList['test/integration/**/*_test.rb']
        end
      end
    end
  rescue LoadError => e
    puts "WARNING: Unable to load RCov task\n" #+ e.backtrace.to_s
  rescue Exception => e
    puts "#{e}"
  end
end