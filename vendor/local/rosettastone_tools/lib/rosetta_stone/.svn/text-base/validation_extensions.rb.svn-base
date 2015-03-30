# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

# This doesn't work as-is in Rails 3 since it uses a pretty different validation syntax.
module RosettaStone
  #NOTE: If anyone changes this, we should ensure all users (LM+Core) update their client-facing messaging
  VALID_EMAIL_REGEX = /^([^@\s]+)@((?:[-a-zA-Z0-9]+\.)+[a-zA-Z]{2,})$/ unless defined? VALID_EMAIL_REGEX
  VALID_NAME_REGEX = /^[^%&:\|"]*$/ unless defined? VALID_NAME_REGEX
  VALID_LOTUS_DISPLAY_NAME_REGEX = /^[a-zA-Z \-\.]+$/ unless defined? VALID_LOTUS_DISPLAY_NAME_REGEX
  VALID_NONLOTUS_DISPLAY_NAME_REGEX = /^[^0-9!@#\$%^&*()_=+`~:;"?¿¡,<>\[\]{\}\\\|\/♥♦]*$/ unless defined? VALID_NONLOTUS_DISPLAY_NAME_REGEX
  module Validations
    module ClassMethods

      def validates_foreign_key_presence(*association_names_with_options)
        association_names = association_names_with_options.dup
        options = association_names.last.is_a?(Hash) ? association_names.pop : {}
        association_names.each do |association_name|
          raise ArgumentError, "Association '#{association_name}' not found. Define your association before using this validation." unless association = reflect_on_association(association_name)
          raise ArgumentError, "Association '#{association_name}' is not a belongs_to association." unless association.macro == :belongs_to
        end

        validates_each *association_names_with_options do |record, attribute, value|
          value = record.send(reflect_on_association(attribute).primary_key_name)
          record.errors.add(attribute, options[:message] || "must be present") unless !value.nil? && value > 0
        end
      end

      def validates_absence_of(*attr_names)
        configuration = { :message => "must be blank", :on => :save }
        configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

        # can't use validates_each here, because it cannot cope with nonexistent attributes,
        # while errors.add_on_empty can
        attr_names.each do |attr_name|
          send(validation_method(configuration[:on])) do |record|
            unless configuration[:if] and not evaluate_condition(configuration[:if], record)
              record.errors.add(attr_name, configuration[:message]) unless record.send(attr_name).blank?
            end
          end
        end
      end

    end # ClassMethods
  end   # Validation
end     # RosettaStone

ActiveRecord::Base.extend(RosettaStone::Validations::ClassMethods) if defined?(ActiveRecord)
