# -*- encoding : utf-8 -*-
# run tests with TEST_STOP_ON_ERROR=true to enable this behavior

if ENV['TEST_STOP_ON_ERROR'] and not defined?(TEST_STOP_ON_ERROR)
  require 'test/unit/diff' if RUBY_VERSION =~ /^1\.9/
  require 'test/unit/ui/console/testrunner'
  module Test
    module Unit
      module UI
        module Console
          class TestRunner
            def start_with_bailout
              @output_level = VERBOSE
              start_without_bailout
            end
            alias_method_chain :start, :bailout

            def add_fault_with_bailout(fault)
              add_fault_without_bailout(fault)
              puts
              if fault.respond_to?(:exception)
                raise fault.exception
              else
                puts fault.message
                puts "\t" + fault.location.join("\n\t")
                raise Exception.new
              end
            end
            alias_method_chain :add_fault, :bailout
          end
        end
      end
    end
  end
  TEST_STOP_ON_ERROR = true
end
