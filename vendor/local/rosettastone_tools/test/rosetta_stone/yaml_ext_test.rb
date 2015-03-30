# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

if RUBY_VERSION =~ /^1\.8/
  class RosettaStone::YamlExtTest < Test::Unit::TestCase
    EXTRA_LOAD_PATH = File.expand_path('yaml_ext', File.dirname(__FILE__))

    def test_lazy_loaded_class_can_be_deserialized
      # Add the dir to the paths that Rails uses to look for classes that can be
      # autoloaded
      if defined?(ActiveSupport::Dependencies)
        # Rails 2.3 style
        (ActiveSupport::Dependencies.respond_to?(:autoload_paths) ? ActiveSupport::Dependencies.autoload_paths : ActiveSupport::Dependencies.load_paths) << EXTRA_LOAD_PATH
      else
        # Handling how older rails (i.e. 2.0.5 in the OLLCs) accesses load_paths
        Dependencies.load_paths << EXTRA_LOAD_PATH
      end
      deserialized_class = YAML.load_file(File.join(EXTRA_LOAD_PATH, 'non_loaded_class.yml'))
      assert_true deserialized_class.is_a?(NonLoadedClass)
      # Since this class hasn't been loaded, without the change in yaml_ext, we
      # would have a yaml object and calling .name on it would throw an error
      assert_nothing_raised("The class wasn't autoloaded, so, you don't have a NonLoadedClass object like you expected") do
        assert_equal 'named_class', deserialized_class.name
      end
    end

    def test_class_not_in_load_path_gets_acceptable_error
      # The class we're deserializing here actually doesn't exist, which is equiv
      # to it not being in the load path.  We want this to behave like it did before
      # -- in that a YAML::Object will be returned
      deserialized_class = YAML.load_file(File.join(EXTRA_LOAD_PATH, 'non_existent_class.yml'))
      assert_true deserialized_class.is_a?(YAML::Object)
      assert_raise(NoMethodError, "You should be expecting a YAML::Object here, which will complain about having 'name' called") do
        assert_equal 'named_class', deserialized_class.name
      end
    end
  end
end
