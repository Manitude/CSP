# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2010 Rosetta Stone
# License:: All rights reserved.

# this module should get included into an ActiveSupport::TestCase class within your app in order to be executed.
module RosettaStone
  module CrossdomainTest

    def test_crossdomain_file_exists
      assert File.exist?(path_to_crossdomain_xml), "no file at #{path_to_crossdomain_xml}"
    end

    def test_crossdomain_file_seems_valid
      assert xml = crossdomain_contents
      assert_nothing_raised do
        REXML::Document.new(xml)
      end
      assert_select_on!(xml)
    end

    def test_relaxng_validation_of_crossdomain_file
      # check at runtime (instead of environment load time) since this plugin loads before relaxng_validator
      if defined?(RosettaStone::RelaxngValidator)
        assert_relaxng_validation(crossdomain_contents, path_to_relaxng_spec)
      end
    end

  private

    def path_to_crossdomain_xml
      File.join(Rails.root, 'public', 'crossdomain.xml')
    end

    def crossdomain_contents
      File.read(path_to_crossdomain_xml)
    end

    def path_to_relaxng_spec
      File.join(File.dirname(__FILE__), '..', '..', '..', 'doc', 'relaxng_specifications', 'crossdomain.rng')
    end
  end
end
