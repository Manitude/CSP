# snagged & adapted from:
# http://blog.hungrymachine.com/2008/06/04/rake-task-for-syntax-checking-a-ruby-on-rails-project/

task :check_syntax => ['check_syntax:erb', 'check_syntax:ruby', 'check_syntax:yaml']

namespace :check_syntax do
  desc 'Load syntax checker helper libraries'
  task :load_libraries do
    require 'open3'
    require File.expand_path('../../rosetta_stone/system_call_helpers', __FILE__)
  end

  if Rails::VERSION::MAJOR >= 3
    desc 'Validate ERB syntax parsing of all *.erb files'
    task :erb => :environment do
      Dir["**/*.erb"].each do |file_name|
        next if file_name.match("vendor/gem_home") # don't check installed gems
        next if file_name.match("vendor/bundle") # don't check installed gems
        erb = ActionView::Template::Handlers::Erubis.new(File.read(file_name))
        begin
          erb.result
        rescue SyntaxError => syntax_error
          $stderr.puts("#{file_name.to_console_string.red}: #{syntax_error.message}")
        rescue NameError, LocalJumpError # includes NoMethodError, and allows templates with <%= yield %>
          # passed
        rescue Exception => unexpected_exception
          puts "ERB syntax check failed on file #{file_name}: #{unexpected_exception}\n#{unexpected_exception.backtrace}"
          raise
        end
      end
    end
  else
    desc 'Validate ERB syntax parsing of all *.erb and *.rhtml files'
    task :erb => :load_libraries do
      require 'erb'
      (Dir["**/*.erb"] + Dir["**/*.rhtml"]).each do |file|
        next if file.match("vendor/rails")
        next if file.match("vendor/plugins/shoulda/test/rails3_root/app/views/posts/new.rhtml") # something in this file that doesn't pass this particular validator (maybe a new convention in rails 3)
        next if file.match("vendor/(plugins|gems)/granite") # only work for rails 3 for now.
        Open3.popen3('ruby -c') do |stdin, stdout, stderr|
          stdin.puts(ERB.new(File.read(file), nil, '-').src)
          stdin.close
          if error = ((stderr.readline rescue false))
            puts file + error[1..-1]
          end
          stdout.close rescue false
          stderr.close rescue false
        end
      end
    end
  end

  desc 'Validate ruby syntax parsing of all *.rb files'
  task :ruby => :load_libraries do
    Dir['**/*.rb'].each do |file|
      next if file.match("vendor/rails") # no need to check rails every time
      next if file.match("vendor/gem_home") # deprecated in favor of vendor/home (on the next line). can remove this at some point.
      next if file.match("vendor/home")
      next if file.match("vendor/bundle")
      next if file.match("vendor/(gems|plugins)/.*/generators/.*/templates") # erb templates of ruby code
      next if file.match("spec/runner/resources/utf8_encoded.rb") # nice, thanks rspec
      next if file.match("vendor/plugins/fckeditor/app/controllers/fckeditor_controller.rb")
      next if file.match("vendor/gems/amq-.*/tasks.rb") # these files in the amq-protocol and amq-client gems have non-standard stuff in their shebang lines
      RosettaStone::SystemCallHelpers.with_empty_rubyopt do
        Open3.popen3(%Q[ruby -c "#{file}"]) do |stdin, stdout, stderr|
          if error = ((stderr.readline rescue false))
            puts error
          end
          stdin.close rescue false
          stdout.close rescue false
          stderr.close rescue false
        end
      end
    end
  end

  desc 'Validate YAML syntax parsing of all *.yml files'
  task :yaml => :load_libraries do
    require 'yaml'
    Dir['**/*.yml'].each do |file|
      next if file.match("vendor/rails")
      begin
        YAML.load_file(file)
      rescue => e
        puts "#{file}:#{(e.message.match(/on line (\d+)/)[1] + ':') rescue nil} #{e.message}"
      end
    end
  end
end
