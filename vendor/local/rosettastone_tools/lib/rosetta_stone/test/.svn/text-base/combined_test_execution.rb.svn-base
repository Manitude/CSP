# -*- encoding : utf-8 -*-
module RosettaStone
  module CombinedTestExecution
    def self.included(klass)
      if ARGV.any? { |option| option.grep(/^-n[t \/]/) }
        # find all combined methods and make test-prefixed methods for them
        klass.instance_methods.map(&:to_s).grep(/^combined/).each do |method_name|
          new_method_name = method_name.sub(/^combined_/, '').to_sym
          klass.send(:alias_method, new_method_name, method_name)
        end
      else
        # define only the combined test methods
        define_method('test_all_combined_tests_in_one_test') do
          klass.instance_methods.map(&:to_s).grep(/^combined/).sort.each do |method_name|
            send(method_name)
            setup_fixtures
          end
        end
      end
    end
  end
end
