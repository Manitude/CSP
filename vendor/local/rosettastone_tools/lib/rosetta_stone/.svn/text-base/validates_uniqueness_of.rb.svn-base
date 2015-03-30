# -*- encoding : utf-8 -*-
# See http://dev.rubyonrails.org/ticket/3833
module RosettaStone
  module Patches
    module ValidatesUniqueness
      def self.extended(klass)
        klass.metaclass.instance_eval do
          alias_method_chain :validates_uniqueness_of, :ignore_sti
        end
      end

      def validates_uniqueness_of_with_ignore_sti(*attr_names)
        # default_error_messages is deprecated in Rails 2.2 and up; use I18n if available:
        message = if defined?(I18n) && I18n.respond_to?(:translate) # then we are Rails 2.2+
            I18n.backend.send('init_translations') if !I18n.backend.initialized?
            # IMPORTANT: when using globalize, we need to make sure it goes through its codepath, and not call I18n.translate directly, which will not go through fallbacks
            I18n.backend.translate(I18n.locale, 'activerecord.errors.messages')[:taken]
          else # Rails < 2.2
            ActiveRecord::Errors.default_error_messages[:taken]
          end

        configuration = { :message => message, :case_sensitive => true, :scope_to_type => true }
        configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

        validates_each(attr_names,configuration) do |record, attr_name, value|
          if value.nil? || (configuration[:case_sensitive] || !columns_hash[attr_name.to_s].text?)
            condition_sql = "#{record.class.table_name}.#{attr_name} #{attribute_condition(value)}"
            condition_params = [value]
          else
            condition_sql = "LOWER(#{record.class.table_name}.#{attr_name}) #{attribute_condition(value)}"
            condition_params = [value.downcase]
          end
          if scope = configuration[:scope]
            Array(scope).map do |scope_item|
              scope_value = record.send(scope_item)
              condition_sql << " AND #{record.class.table_name}.#{scope_item} #{attribute_condition(scope_value)}"
              condition_params << scope_value
            end
          end
          unless record.new_record?
            condition_sql << " AND #{record.class.table_name}.#{record.class.primary_key} <> ?"
            condition_params << record.send(:id)
          end
          model_class = configuration[:scope_to_type] ? record.class : record.class.base_class
          if model_class.find(:first, :conditions => [condition_sql, *condition_params])
            record.errors.add(attr_name, configuration[:message])
          end
        end
      end

    end # ValidatesUniqueness
  end   # Patches
end     # RosettaStone

# This patch only works with 1.2.0 up through 2.2.x.  This behavior (:scope_to_type => false) actually changed to become
# the standard behavior in Rails somewhere around version 2.0 (see http://dev.rubyonrails.org/ticket/3833, thanks Gabe!),
# but this patch works well up through 2.2.x.  However, it breaks with Rails 2.3 and thus we wean ourselves from it then.
if (defined?(ActiveRecord) &&
    RosettaStone::RailsVersionString >= RosettaStone::VersionString.new(1,2,0) &&
    RosettaStone::RailsVersionString <  RosettaStone::VersionString.new(2,3,0))
  ActiveRecord::Base.extend(RosettaStone::Patches::ValidatesUniqueness)
end
