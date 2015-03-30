# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2007 Rosetta Stone
# License:: All rights reserved.

module RosettaStone
  # Use RosettaStone::SqlExpression.new() to send a direct SQL expression for a query as a "value"
  class SqlExpression < String
  end

  module ActiveRecordExtensions
    module InstanceMethods

      def invalid?
        !valid?
      end

      def update_attributes_including_timestamps(attributes)
        klass.with_record_timestamps_disabled do
          update_attributes(attributes)
        end
      end

      def update_attributes_including_timestamps!(attributes)
        klass.with_record_timestamps_disabled do
          update_attributes!(attributes)
        end
      end

      def save_including_timestamps
        klass.with_record_timestamps_disabled do
          save
        end
      end

      def save_including_timestamps!
        klass.with_record_timestamps_disabled do
          save!
        end
      end

      # used by with_record_timestamps_disabled_for_all_active_record_classes
      def record_timestamps_with_disabled
        klass.record_timestamps_with_disabled
      end
    end # InstanceMethods

    module ClassMethods
      def self.extended(klass)
        klass.singleton_class_eval do
          alias_method_chain :quote_bound_value, :sql_expressions
        end
      end

      def with_record_timestamps_disabled(&block)
        old_record_timestamps_value = record_timestamps
        self.record_timestamps = false
        yield
      ensure
        self.record_timestamps = old_record_timestamps_value
      end

      # used by with_record_timestamps_disabled_for_all_active_record_classes
      def record_timestamps_with_disabled
        false
      end

      # Rails 3.1 uses a different method for inheriting and setting the record_timestamps
      # (class_attribute instead of class_inheritable_accessor) that does wacky things
      # like dynamically define methods, which prevents this from working reliably.
      #
      # Commit chaging it:
      # https://github.com/rails/rails/commit/d7db6a#activerecord/lib/active_record/timestamp.rb
      #
      # Rails 3.1 version:
      # https://github.com/rails/rails/blob/v3.1.3/activerecord/lib/active_record/timestamp.rb#L36
      #
      # Rails 3.0 verison:
      # https://github.com/rails/rails/blob/v3.0.11/activerecord/lib/active_record/timestamp.rb#L32
      #
      # Rails 2.3 version:
      # https://github.com/rails/rails/blob/v2.3.14/activerecord/lib/active_record/timestamp.rb#L15
      #
      # So for Rails 3, we support a weaker implementation that merely temporarily sets
      # record_timestamps on ActiveRecord::Base, which promulgates down to all of the
      # classes that inherit from it EXCEPT those that have themselves set a value on
      # record_timestamps.
      #
      if ActiveSupport::VERSION::MAJOR < 3 || (ActiveSupport::VERSION::MAJOR == 3 && ActiveSupport::VERSION::MINOR < 1)
        # STOMP ON IT
        # so, we need two state variables in order to properly handle nested use cases, which you just shouldn't do anyway :)
        # yuck, note also that since record_timestamps is a class_inheritable_accessor, we have to stomp on both the class
        # method and the instance method for record_timestamps.
        def with_record_timestamps_disabled_for_all_active_record_classes(&block)
          @@recording_timestamps_for_all_active_record_classes ||= false
          revert_in_ensure = false
          if !@@recording_timestamps_for_all_active_record_classes
            singleton_class_eval do
              alias_method_chain :record_timestamps, :disabled
            end
            alias_method_chain :record_timestamps, :disabled
            @@recording_timestamps_for_all_active_record_classes = true
            revert_in_ensure = true
          end
          yield if block_given?
        ensure
          if @@recording_timestamps_for_all_active_record_classes && revert_in_ensure
            singleton_class_eval do
              alias_method :record_timestamps, :record_timestamps_without_disabled
            end
            alias_method :record_timestamps, :record_timestamps_without_disabled
            @@recording_timestamps_for_all_active_record_classes = false
          end
        end
      else
        # not inheritable
        def with_record_timestamps_disabled_for_all_active_record_classes(&block)
          raise NoMethodError unless self == ActiveRecord::Base
          logger.debug 'Attempting to disable timestamp recordings for all active record classes. Be advised: classes that have manually set record_timestamps will not be affected.'
          with_record_timestamps_disabled(&block)
        end
      end

      def none?
        count == 0
      end

      def some?
        !none?
      end

      def attempt_database_activity_with_retries(max_attempts = 2, exceptions_to_rescue = [ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid], &block)
        retry_on_exception(exceptions_to_rescue, max_attempts) do
          yield
        end
      end

      # This method uses the INSERT ... ON DUPLICATE KEY UPDATE statement in SQL to implement the create-or-update pattern without having to use
      # a transaction with multiple queries.  All arguments should be hashes with attribute names as keys.
      # Note that you can use RosettaStone::SqlExpression to send direct SQL into the "values" for the insert or update clauses.
      # Note: this has only been tested with MySQL 5.0+
      #
      # The update_values argument can be any valid argument to ActiveRecord's sanitize_sql_for_assignment (hash, array, string).
      # The unique_identifiers and insert_values arguments *must* be hashes (so we can merge them).
      #
      # This method will try to set created_at and updated_at appropriately if the table has those columns, but this works only
      # if your arguments are hashes.  Otherwise you'll need to handle those values manually.
      #
      # Note: these SQL statements are especially prone to triggering LOCK WAIT TIMEOUTs and DEADLOCKs in MySQL.  You will generally
      # want to wrap it with attempt_database_activity_with_retries.  See insert_or_update_with_retries (below).  This problem is
      # much less prevalent on MySQL versions newer than 5.1.61 or 5.5.20 (see http://bugs.mysql.com/bug.php?id=52020)
      #
      # This returns 1 when a new record was inserted, 2 when it updated an existing record, 0 when the existing record was not changed.
      #
      # WARNING: the return value can only be trusted when the mysql CLIENT_FOUND_ROWS flag is not set in your mysql client adapter.  
      # In general, versions of the old "mysql" client gem will be fine, but most versions of the "mysql2" client gem set this flag
      # in what I believe to be an overwhelming wave of poor judgement on the part of the gem's authors.  We have locally hacked
      # versions of the mysql2 gem (see https://trac.lan.flt/webdev/changeset/95335) that unset the flag in order to fix this issue.
      # We have tests to prevent regression on this problem in test/unit/insert_or_update_test.rb in the tracking service and baffler.
      def insert_or_update(unique_identifiers, insert_values = nil, update_values = nil)
        insert_values = unique_identifiers.dup if insert_values.nil?
        update_values = insert_values.dup if update_values.nil?

        unique_identifiers = unique_identifiers.with_indifferent_access if unique_identifiers.respond_to?(:with_indifferent_access)
        insert_values = insert_values.with_indifferent_access if insert_values.respond_to?(:with_indifferent_access)
        update_values = update_values.with_indifferent_access if update_values.respond_to?(:with_indifferent_access)

        if defined?(ActiveSupport::TimeWithZone) && Time.zone
          #Rails >= 2.3 with a time zone set
          current_time = Time.zone.now
        else
          current_time = ActiveRecord::Base.default_timezone == :utc ? Time.now.utc : Time.now
        end
        if column_names.map(&:to_sym).include?(:updated_at)
          insert_values = {:updated_at => current_time}.with_indifferent_access.merge(insert_values) if insert_values.is_a?(Hash) && insert_values.keys.any?
          update_values = {:updated_at => current_time}.with_indifferent_access.merge(update_values) if update_values.is_a?(Hash) && update_values.keys.any?
        end
        if column_names.map(&:to_sym).include?(:created_at)
          insert_values = {:created_at => current_time}.with_indifferent_access.merge(insert_values) if insert_values.is_a?(Hash) && insert_values.keys.any?
        end

        sql = %Q[INSERT INTO #{quoted_table_name} SET #{sanitize_sql_for_assignment(unique_identifiers.merge(insert_values))} ON DUPLICATE KEY UPDATE #{sanitize_sql_for_assignment(update_values)}]
        # using connection.update instead of connection.insert because update returns the number of rows affected where insert returns the inserted id
        # in mysql, an "insert ... on duplicate key update" query returns 1 for an insert and 2 for an update, and 1 for an update when nothing was updated!
        # READ THE NOTE ABOVE BEFORE USING THE RETURN VALUE FROM THIS METHOD!
        #
        # Pop Quiz: What will this return if the record already exists in the database with all of the update values the same as the update values you are trying to update?
        #    a. 0
        #    b. 1
        #    c. 2
        # see bottom of this file for answer.
        connection.update(sql)
      end

      # Since it is such a common pattern to run insert_or_update within an attempt_database_activity_with_retries block, this method
      # wraps it for you.
      # retry_options can include :max_attempts and :exceptions_to_rescue.
      def insert_or_update_with_retries(unique_identifiers, insert_values = nil, update_values = nil, retry_options = {})
        retry_options = retry_options.with_indifferent_access
        max_attempts = (retry_options[:max_attempts] || 3).to_i
        exceptions_to_rescue = retry_options[:exceptions_to_rescue] || [ActiveRecord::StatementInvalid]
        attempt_database_activity_with_retries(max_attempts, exceptions_to_rescue) do
          insert_or_update(unique_identifiers, insert_values, update_values)
        end
      end

      # This method uses MySQL's INSERT IGNORE ... syntax to insert a record or do nothing if a record with the same values for the
      # primary key or a unique key already exists (these attributes should be passed in unique_identifiers; other values should go
      # in insert_values)
      # Regardless of whether a record was created or not, the corresponding ActiveRecord object will be returned.
      # The unique_identifiers and insert_values arguments *must* be hashes (so we can merge them).
      def insert_ignore(unique_identifiers, insert_values = {})
        insert_values = insert_values.dup
        unique_identifiers = unique_identifiers.with_indifferent_access if unique_identifiers.respond_to?(:with_indifferent_access)

        if defined?(ActiveSupport::TimeWithZone) && Time.zone
          #Rails >= 2.3 with a time zone set
          current_time = Time.zone.now
        else
          current_time = ActiveRecord::Base.default_timezone == :utc ? Time.now.utc : Time.now
        end
        if column_names.map(&:to_sym).include?(:updated_at)
          insert_values[:updated_at] = current_time
        end
        if column_names.map(&:to_sym).include?(:created_at)
          insert_values[:created_at] = current_time
        end

        sql = %Q[INSERT IGNORE INTO #{quoted_table_name} SET #{sanitize_sql_for_assignment(unique_identifiers.merge(insert_values))}]
        id = connection.insert(sql)

        if id == 0
          find(:first, :conditions => unique_identifiers)
        else
          find(id)
        end
      end

      # find or create the record, and then lock that record while you do whatever is in the block
      # another process with be unable to select that record as long as you're messing with it
      # see https://svn.lan.flt/svn/Labs/AdaptiveRecall_2/trunk/app/models/user_text_status.rb for an example
      def find_or_create_for_update(attributes_hash, &block)
        begin
          create(attributes_hash)
        rescue ActiveRecord::StatementInvalid => e
          raise e unless e.message.match('Duplicate entry')
        end
        self.transaction do
          record = find(:first, :conditions => attributes_hash, :lock => true)
          raise ActiveRecord::RecordNotFound.new("Expected to find a record in find_or_create_for_update") if record.nil?
          yield(record)
        end
      end

      # Get a lock with the given name.  MySQL handles allocating these locks, so, we can use it
      # as a means of handling concurrency between many rails processes.
      #
      # This takes a block and wraps it in a lock request.  The block binding
      # is done implicitly for speed (http://blog.sidu.in/2007/11/ruby-blocks-gotchas.html)
      #
      # timeout is in seconds and must be an integer (it seems that MySQL rounds to the nearest integer, which is surprising,
      # so we enforce it to be an integer here).
      #
      # db_connection defaults to the Active Record class' connection if not specified.
      def application_lock(lock_name, timeout, db_connection = nil)
        raise ArgumentError, "Timeout must be an integer: #{timeout.inspect}" unless timeout.is_a?(Integer)
        begin
          lock_connnection = db_connection || connection # store a reference to the connection in case the current connection gets swapped in the yield
          result = lock_connnection.select_one(%Q[SELECT COALESCE(GET_LOCK('#{lock_name}',#{timeout}),0) as RESULT])
          if result && result['RESULT'] && result['RESULT'].to_i == 1 # This means that we got the lock
            yield
          else # This means that the request for the lock timed out, or there was another error
            logger.error Time.now.to_s(:db) + " Failed to lock on #{lock_name}"
            raise ActiveRecord::ApplicationLockTimeout, 'Lock request timed out or was killed unexpectedly.'
          end
        ensure
          lock_connnection.execute(%Q[SELECT RELEASE_LOCK('#{lock_name}')])
        end
      end

      # Support for sending direct SQL expressions as "values"
      def quote_bound_value_with_sql_expressions(*args)
        value = args.first
        if value.is_a?(SqlExpression)
          value
        else
          quote_bound_value_without_sql_expressions(*args)
        end
      end

      def escape_for_sql_like(string)
        # see http://dev.mysql.com/doc/refman/5.0/en/string-comparison-functions.html#operator_like - there's a note about blackslashes.
        # if you need to match one \ in a value, you need FOUR backslashes in your LIKE clause.  not kidding.  so to get ruby to do that,
        # we need to use EIGHT consecutive backslashes in the gsub.
        string.gsub('\\', '\\\\\\\\').gsub(/[%_]/) { |c| '\\' + c }
      end

      # these return arrays of strings
      # def boolean_columns
      # def datetime_columns
      # def string_columns
      # def float_columns
      [:boolean, :datetime, :string, :float].each do |column_type|
        define_method("#{column_type}_columns") do
          columns.select {|c| c.type == column_type }.map(&:name)
        end
      end

      # special handling for integer because of id and *_id columnes:
      def integer_columns
        columns.select {|c| c.type == :integer && c.name != 'id' && c.name !~ /.+_id$/ }.map(&:name)
      end

      if defined?(Rails) && Rails::VERSION::MAJOR >= 3
        def paginated_each(options = {})
          options = { :order => 'id', :page => 1 }.merge options
          options[:page] = options[:page].to_i
          options[:total_entries] = 0 # skip the individual count queries
          total = 0

          begin
            collection = paginate(options)
            with_exclusive_scope(:find => {}) do
              # using exclusive scope so that the block is yielded in scope-free context
              total += collection.each { |item| yield item }.size
            end
            options[:page] += 1
          end until collection.size < collection.per_page

          total
        end
      end

      def switch_connection(environment)
        establish_connection(configurations[environment])
      end

    end
  end   # ActiveRecordExtensions
end     # RosettaStone


if defined?(ActiveRecord)
  ActiveRecord::Base.send(:include, RosettaStone::ActiveRecordExtensions::InstanceMethods)
  ActiveRecord::Base.extend(RosettaStone::ActiveRecordExtensions::ClassMethods)

  # MySQL-specific extension
  #
  # Sample usage:
  #
  # ActiveRecord::Base.connection.without_foreign_key_checks {|conn| conn.tables.each {|table| conn.drop_table(table) } }
  module RosettaStone::MysqlAdapterExtensions
    def without_foreign_key_checks(&blk)
      ActiveRecord::Base.connection.execute('/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;')
      yield(self)
    ensure
      ActiveRecord::Base.connection.execute('/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;')
    end

    def self.include_in_ar
      ActiveRecord::ConnectionAdapters::MysqlAdapter.send(:include, RosettaStone::MysqlAdapterExtensions) if defined?(ActiveRecord::ConnectionAdapters::MysqlAdapter)
      ActiveRecord::ConnectionAdapters::Mysql2Adapter.send(:include, RosettaStone::MysqlAdapterExtensions) if defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
    end
  end
  if defined?(Rails::Railtie)
    class RosettaStone::MysqlAdapterExtensions::Railtie < Rails::Railtie
      config.after_initialize do
        RosettaStone::MysqlAdapterExtensions.include_in_ar
      end
    end
  else
    RosettaStone::MysqlAdapterExtensions.include_in_ar
  end

  # Raised when the application_lock request times out
  class ActiveRecord::ApplicationLockTimeout < ActiveRecord::ActiveRecordError
  end
end
# Answer to Pop Quiz: b
