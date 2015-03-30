# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::ActsAsInterfaceTest < Test::Unit::TestCase

  def test_setting_interface_methods
    superklass = Class.new {
      include ActsAsInterface

      interface_instance_methods [:meth_1, :meth_2]
      interface_class_methods [:meth_a, :meth_b]

      def self.name; "SuperKlass"; end
    }
    klass = Class.new(superklass) {
      def self.name; "SubKlass"; end
    }

    [:meth_1, :meth_2].each do |instance_meth|
      error = assert_raises(ActsAsInterface::MissingInterfaceMethod) do
        klass.new.send(instance_meth)
      end
      assert_equal "Classes descending from SuperKlass should define instance method #{instance_meth.to_s}. SubKlass does not.", error.message
    end

    [:meth_a, :meth_b].each do |class_meth|
      error = assert_raises(ActsAsInterface::MissingInterfaceMethod) do
        klass.send(class_meth)
      end
      assert_equal "Classes descending from SuperKlass should define class method #{class_meth.to_s}. SubKlass does not.", error.message
    end
  end

end
