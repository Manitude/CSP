# Copyright:: Copyright (c) 2009 Rosetta Stone
# License:: All rights reserved.

# This module defines the tests themselves.  It is intended to be included into 
# a Test::Unit::TestCase (or ActiveSupport::TestCase) class.
module RosettaStone
  class JavascriptLint
    module JavascriptLintTestDefinitions
      RosettaStone::JavascriptLint.files_to_validate.each do |file_to_validate|
        define_method("test javascript lintyness for file #{file_to_validate}") do
          assert_lintless_javascript_file(file_to_validate)
        end
      end
    end
  end
end
