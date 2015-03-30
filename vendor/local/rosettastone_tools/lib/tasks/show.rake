# Copyright:: Copyright (c) 2006 Rosetta Stone
# License:: All rights reserved.

namespace :show do
  desc "show tests that were probably intended to not be commented out or otherwise disabled"
  task :disabled_tests do
    system('cd test && grep -r "^.*#.*assert" * | grep -v a-better-assert_difference | fgrep -v .svn')
  end

  desc "show test method names that are duplicates and thus probably not executed properly"
  task :duplicate_tests do
    exclusions = %w(test_namespaces plugins/has_many_polymorphs)
    exclusion_commands = exclusions.map {|ex| %Q[| fgrep -v "#{ex}" ]}.join
    test_directories = %w(test)
    test_directories << 'vendor/plugins/*/test' if File.exists?('vendor/plugins')
    system(%Q[egrep -r "def\s+test_" #{test_directories.join(' ')} | fgrep -v .svn | sed "s/: *def */:/" | sort | uniq -d #{exclusion_commands}])
  end

  desc "finds test files that aren't named _test"
  task :improperly_named_test_files do
    system(%Q[find test | fgrep ".rb" | fgrep -v .svn | fgrep -v _test.rb | fgrep -v '/mocks/' | fgrep -v '/support/' | fgrep -v '_helper.rb' | fgrep -v '_tests' | fgrep -v _suite.rb])
  end

  desc "finds duplicate test class names"
  task :duplicate_test_classes do
    # there are some duplicate test class names in various 3rd-party libraries that we are just ignoring (test/consistency is from viper and is safe to ignore)
    exclusions = %w(vendor/plugins/mocha vendor/plugins/globalize2 vendor/plugins/calendar_date_select vendor/plugins/shoulda MixinNestedSetTest FinderTest OverrideTest RecursiveVerifyControllerTest test/consistency)
    exclusion_commands = exclusions.map {|ex| %Q[| fgrep -v "#{ex}" ]}.join
    test_directories = %w(test)
    test_directories << 'vendor/plugins/*/test' if File.exists?('vendor/plugins')
    system(%Q[egrep -r --exclude "*~" "class .+ <" #{test_directories.join(' ')} | grep "Test <" #{exclusion_commands} | fgrep -v .svn | sed -e 's/^.*:class //' -e 's/ .*$//' | sort | uniq -d])
  end

  desc "grep through code for FIXME's and show where they are hidden"
  task :fixmes do
    system(%Q[grep -r "#.*FIXME" app/* config/* lib/* test/* | fgrep -v .svn])
  end

  desc "This will output 'constant' if some rake task has required the environment.  Don't do that!  Should output 'nil'."
  task :is_environment_accidentally_loaded do
    # ha, what a hack
    p defined?(ActionController::Base)
  end
end
