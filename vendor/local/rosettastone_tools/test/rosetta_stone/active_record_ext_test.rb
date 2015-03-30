# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

class RosettaStone::ActiveRecordExtTest < Test::Unit::TestCase

  # This tests that mySQL is locking as expected.  This tests both that
  # locking is working and whether the locking timeout is being handled.
  def test_that_locking_times_out
    return unless run_tests_that_require_database_connection?
    shared_lock_name = "LOCK"
    # When test_that_locking_times_out_child is set, then this test only makes sure that the timeout occurs
    if ENV['test_that_locking_times_out_child'] == "true"
      assert_raise(ActiveRecord::ApplicationLockTimeout) do
        # Since the parent has this lock, the child should time out
        ActiveRecord::Base.application_lock(shared_lock_name, 1) do
          raise "Lock timeout not detected or original lock never gotten"
        end
      end
    else
      ActiveRecord::Base.application_lock(shared_lock_name, 40) do
        # You may be tempted to use a fork() here, but, a fork will cause the
        # mysql connection to be dropped.  Basically, we want to have another
        # connection come in and try to grab the same lock
        childThread = Thread.new do
          ruby_location = `which ruby`.chomp
          `test_that_locking_times_out_child=true "#{ruby_location}" "#{__FILE__}"`
          # Make sure that this returned successfully
          # (i.e., it got a timeout error)
          assert_true $?.success?, "Lock timeout was not detected or original lock was never gotten. ( ************ WARNING. This test always fails if any other test in this suite fails.  Fix all the other tests first before fixing this one. ************)"
        end
        # Wait for the child thread to finish.  This will also print
        # any exceptions
        childThread.join
      end
    end
  end

  if defined?(ActiveRecord::Base)
    def test_application_lock_with_float
      assert_raises(ArgumentError) do
        ActiveRecord::Base.application_lock('whatever', 0.25) { }
      end
    end

    def test_with_record_timestamps_disabled
      toy_class.record_timestamps = true
      assert_true(toy_class.record_timestamps)
      toy_class.with_record_timestamps_disabled do
        assert_false(toy_class.record_timestamps)
      end
      assert_true(toy_class.record_timestamps)
    end

    def test_with_record_timestamps_disabled_with_they_are_disabled_to_begin_with
      toy_class.record_timestamps = false
      assert_false(toy_class.record_timestamps)
      toy_class.with_record_timestamps_disabled do
        assert_false(toy_class.record_timestamps)
      end
      assert_false(toy_class.record_timestamps)
    end

    def test_nested_use_of_with_record_timestamps_disabled
      toy_class.record_timestamps = true
      assert_true(toy_class.record_timestamps)
      toy_class.with_record_timestamps_disabled do
        assert_false(toy_class.record_timestamps)
        toy_class.with_record_timestamps_disabled do
          assert_false(toy_class.record_timestamps)
        end
        assert_false(toy_class.record_timestamps)
      end
      assert_true(toy_class.record_timestamps)
    end

    def test_with_record_timestamps_disabled_for_all_active_record_classes
      assert_true(toy_class.record_timestamps)
      ActiveRecord::Base.with_record_timestamps_disabled_for_all_active_record_classes do
        assert_false(toy_class.record_timestamps)
      end
      assert_true(toy_class.record_timestamps)
    end

    if ActiveSupport::VERSION::MAJOR < 3 || (ActiveSupport::VERSION::MAJOR == 3 && ActiveSupport::VERSION::MINOR < 1)
      def test_with_record_timestamps_disabled_for_all_active_record_classes_even_if_property_has_been_set_on_subclass_in_rails_2
        toy_class.record_timestamps = true
        assert_true(toy_class.record_timestamps)
        ActiveRecord::Base.with_record_timestamps_disabled_for_all_active_record_classes do
          assert_false(toy_class.record_timestamps)
        end
        assert_true(toy_class.record_timestamps)
      end
    else
      # see the test below with no_override, override_true, and override_false
      # for a demonstration of how Rails 3's pattern works. this test replicates
      # a part of the demonstration there and is meant as a counterpoint to the
      # Rails 2 version of this test above.
      def test_with_record_timestamps_disabled_for_all_active_record_classes_does_not_overwrite_subclass_explicit_setting_in_rails_3
        toy_class.record_timestamps = true
        assert_true(toy_class.record_timestamps)
        ActiveRecord::Base.with_record_timestamps_disabled_for_all_active_record_classes do
          # observe failure to override
          assert_true(toy_class.record_timestamps)
        end
        assert_true(toy_class.record_timestamps)
      end
    end

    def test_with_record_timestamps_disabled_for_all_active_record_classes_when_it_is_false_to_begin_with
      toy_class.record_timestamps = false
      assert_false(toy_class.record_timestamps)
      ActiveRecord::Base.with_record_timestamps_disabled_for_all_active_record_classes do
        assert_false(toy_class.record_timestamps)
      end
      assert_false(toy_class.record_timestamps)
    end

    def test_nested_use_of_with_record_timestamps_disabled_for_all_active_record_classes
      assert_true(toy_class.record_timestamps)
      ActiveRecord::Base.with_record_timestamps_disabled_for_all_active_record_classes do
        assert_false(toy_class.record_timestamps)
        ActiveRecord::Base.with_record_timestamps_disabled_for_all_active_record_classes do
          assert_false(toy_class.record_timestamps)
        end
        assert_false(toy_class.record_timestamps)
      end
      assert_true(toy_class.record_timestamps)
    end

    def test_with_record_timestamps_disabled_for_all_active_record_classes_does_not_affect_classes_that_have_manually_set_record_timestamps
      no_override = Class.new(ActiveRecord::Base)
      override_true = Class.new(ActiveRecord::Base)
      override_false = Class.new(ActiveRecord::Base)
      override_true.record_timestamps = true
      override_false.record_timestamps = false
      assert_true(no_override.record_timestamps)
      assert_true(override_true.record_timestamps)
      assert_false(override_false.record_timestamps)
      ActiveRecord::Base.with_record_timestamps_disabled_for_all_active_record_classes do
        assert_false(no_override.record_timestamps)
        # Rails < 3 does a hard override.
        # Rails >= 3 respects the subclass overriding.
        if ActiveSupport::VERSION::MAJOR < 3 || (ActiveSupport::VERSION::MAJOR == 3 && ActiveSupport::VERSION::MINOR < 1)
          assert_false(override_true.record_timestamps)
        else
          assert_true(override_true.record_timestamps)
        end
        assert_false(override_false.record_timestamps)
      end
      assert_true(no_override.record_timestamps)
      assert_true(override_true.record_timestamps)
      assert_false(override_false.record_timestamps)
    end

    def test_insert_or_update_with_just_unique_identifiers
      ActiveRecord::Base.stubs(:default_timezone).returns(:utc)
      mock_column_names(toy_class)
      now = Time.now
      Time.stubs(:now).returns(now)
      now_string = now.utc.to_s(:db)
      expect_insert_or_update(
        {
          :uniq_attr_1 => 1,
          :uniq_attr_2 => 2,
          :updated_at => "'#{now_string}'",
          :created_at => "'#{now_string}'",
        },
        {
          :uniq_attr_1 => 1,
          :uniq_attr_2 => 2,
          :updated_at => "'#{now_string}'"
        }
      )
      toy_class.insert_or_update({:uniq_attr_1 => 1, :uniq_attr_2 => 2})
    end

    def test_insert_or_update_with_unique_identifiers_and_insert_values
      ActiveRecord::Base.stubs(:default_timezone).returns(:utc)
      mock_column_names(toy_class)
      now = Time.now
      Time.stubs(:now).returns(now)
      now_string = now.utc.to_s(:db)
      expect_insert_or_update(
        {
          :uniq_attr_1 => 1,
          :uniq_attr_2 => 2,
          :insert_attr_1 => 1,
          :insert_attr_2 => 2,
          :updated_at => "'#{now_string}'",
          :created_at => "'#{now_string}'",
        },
        {
          :insert_attr_1 => 1,
          :insert_attr_2 => 2,
          :updated_at => "'#{now_string}'"
        }
      )
      toy_class.insert_or_update(
        {:uniq_attr_1 => 1, :uniq_attr_2 => 2},
        {:insert_attr_1 => 1, :insert_attr_2 => 2}
      )
    end

    def test_insert_or_update_with_unique_identifiers_and_insert_values_and_no_update_values
      ActiveRecord::Base.stubs(:default_timezone).returns(:utc)
      mock_column_names(toy_class)
      now = Time.now
      Time.stubs(:now).returns(now)
      now_string = now.utc.to_s(:db)
      expect_insert_or_update(
        {
          :uniq_attr_1 => 1,
          :uniq_attr_2 => 2,
          :insert_attr_1 => 1,
          :insert_attr_2 => 2,
          :updated_at => "'#{now_string}'",
          :created_at => "'#{now_string}'",
        },
        {}
      )
      toy_class.insert_or_update(
        {:uniq_attr_1 => 1, :uniq_attr_2 => 2},
        {:insert_attr_1 => 1, :insert_attr_2 => 2},
        {}
      )
    end

    def test_insert_or_update_with_unique_identifiers_and_update_values_and_no_insert_values
      ActiveRecord::Base.stubs(:default_timezone).returns(:utc)
      mock_column_names(toy_class)
      now = Time.now
      Time.stubs(:now).returns(now)
      now_string = now.utc.to_s(:db)
      expect_insert_or_update(
        {
          :uniq_attr_1 => 1,
          :uniq_attr_2 => 2,
        },
        {
          :update_attr_1 => 1,
          :update_attr_2 => 2,
          :updated_at => "'#{now_string}'"
        }
      )
      toy_class.insert_or_update(
        {:uniq_attr_1 => 1, :uniq_attr_2 => 2},
        {},
        {:update_attr_1 => 1, :update_attr_2 => 2}
      )
    end


    def test_insert_or_update_with_unique_identifiers_and_insert_values_and_update_values
      ActiveRecord::Base.stubs(:default_timezone).returns(:utc)
      mock_column_names(toy_class)
      now = Time.now
      Time.stubs(:now).returns(now)
      now_string = now.utc.to_s(:db)
      expect_insert_or_update(
        {
          :uniq_attr_1 => 1,
          :uniq_attr_2 => 2,
          :insert_attr_1 => 1,
          :insert_attr_2 => 2,
          :updated_at => "'#{now_string}'",
          :created_at => "'#{now_string}'",
        },
        {
          :update_attr_1 => 1,
          :update_attr_2 => 2,
          :updated_at => "'#{now_string}'"
        }
      )
      toy_class.insert_or_update(
        {:uniq_attr_1 => 1, :uniq_attr_2 => 2},
        {:insert_attr_1 => 1, :insert_attr_2 => 2},
        {:update_attr_1 => 1, :update_attr_2 => 2}
      )
    end

    def test_insert_or_update_with_timestamps_overridden
      ActiveRecord::Base.stubs(:default_timezone).returns(:utc)
      mock_column_names(toy_class)

      yesterday = 1.day.ago
      yesterday_string = yesterday.utc.to_s(:db)

      expect_insert_or_update(
        {
          :uniq_attr_1 => 1,
          :insert_attr_1 => 1,
          :created_at => "'#{yesterday_string}'",
          :updated_at => "'#{yesterday_string}'",
        },
        {
          :update_attr_1 => 1,
          :created_at => "'#{yesterday_string}'",
          :updated_at => "'#{yesterday_string}'",
        }
      )
      toy_class.insert_or_update(
        {:uniq_attr_1 => 1},
        {:insert_attr_1 => 1, :created_at => yesterday, :updated_at => yesterday},
        {:update_attr_1 => 1, :created_at => yesterday, :updated_at => yesterday}
      )
    end

    def test_insert_or_update_treats_hashes_with_indifferent_access
      ActiveRecord::Base.stubs(:default_timezone).returns(:utc)
      mock_column_names(toy_class)

      yesterday = 1.day.ago
      yesterday_string = yesterday.utc.to_s(:db)

      expect_insert_or_update(
        {
          :uniq_attr_1 => 1,
          :insert_attr_1 => 1,
          :created_at => "'#{yesterday_string}'",
          :updated_at => "'#{yesterday_string}'",
        },
        {
          :update_attr_1 => 1,
          :created_at => "'#{yesterday_string}'",
          :updated_at => "'#{yesterday_string}'",
        }
      )
      toy_class.insert_or_update(
        {'uniq_attr_1' => 1},
        {'insert_attr_1' => 1, 'created_at' => yesterday, 'updated_at' => yesterday},
        {'update_attr_1' => 1, 'created_at' => yesterday, 'updated_at' => yesterday}
      )
    end

    def test_insert_or_update_with_values_as_array
      ActiveRecord::Base.stubs(:default_timezone).returns(:utc)
      mock_column_names(toy_class)
      now = Time.now
      Time.stubs(:now).returns(now)
      now_string = now.utc.to_s(:db)

      expected_insert_hash =
        {
          :uniq_attr_1 => 1,
          :insert_attr_1 => 1,
          :created_at => "'#{now_string}'",
          :updated_at => "'#{now_string}'",
        }

      proc = Proc.new do |query|
        assert_equal_arrays(expected_insert_hash.map { |key, value| "`#{key.to_s}` = #{value.to_s}" }, insert_assignments_from_insert_or_update_query(query), "Expected insert values to match")
        update_clauses = update_assignments_from_insert_or_update_query(query)
        assert_equal(1, update_clauses.size)
        assert_match('update_attr_1', update_clauses.first)
        true
      end
      toy_class.connection.expects(:update).with(&proc)
      toy_class.insert_or_update(
        {:uniq_attr_1 => 1},
        {:insert_attr_1 => 1},
        ["update_attr_1 = ?", 1]
      )
    end

    def test_insert_or_update_without_timestamps
      ActiveRecord::Base.stubs(:default_timezone).returns(:utc)
      mock_column_names(toy_class, false)
      now = Time.now
      Time.stubs(:now).returns(now)
      expect_insert_or_update(
        {
          :uniq_attr_1 => 1,
          :uniq_attr_2 => 2
        },
        {
          :uniq_attr_1 => 1,
          :uniq_attr_2 => 2
        }
      )
      toy_class.insert_or_update({:uniq_attr_1 => 1, :uniq_attr_2 => 2})
    end

    def test_insert_or_update_with_retries_using_default_options
      toy_class.expects(:attempt_database_activity_with_retries).with(3, [ActiveRecord::StatementInvalid])
      toy_class.insert_or_update_with_retries({})
    end

    def test_insert_or_update_with_retries_with_overrides
      toy_class.expects(:attempt_database_activity_with_retries).with(2, [ActiveRecord::RecordInvalid])
      toy_class.insert_or_update_with_retries({}, nil, nil, {:max_attempts => 2, :exceptions_to_rescue => [ActiveRecord::RecordInvalid]})
    end

  end # if ActiveRecord::Base is defined

private

  def mock_column_names(klass, exist = true)
    mock = []
    if exist
      mock << 'created_at'
      mock << 'updated_at'
    end
    klass.stubs(:column_names).returns(mock);
  end

  def expect_insert_or_update(insert_hash, update_hash)
    proc = Proc.new do |query|
      assert_equal_arrays(insert_hash.map { |key, value| "`#{key.to_s}` = #{value.to_s}" }, insert_assignments_from_insert_or_update_query(query), "Expected insert values to match")
      assert_equal_arrays(update_hash.map { |key, value| "`#{key.to_s}` = #{value.to_s}" }, update_assignments_from_insert_or_update_query(query), "Expected update values to match")
      true
    end

    toy_class.connection.expects(:update).with(&proc)
  end

  def insert_assignments_from_insert_or_update_query(query)
    query.match(/SET ([^(ON)]*)/)[1].split(', ').map { |t| t.strip }
  end

  # dynamically setting toy_class instead of using a singleton ToyClass constant
  # that persisted across multiple tests
  def toy_class
    return @toy_class if defined?(@toy_class)
    @toy_class = Class.new(ActiveRecord::Base)
  end

  def update_assignments_from_insert_or_update_query(query)
    query.match(/UPDATE (.*)/)[1].split(', ').map { |t| t.strip }
  end

  def update_hash_from_insert_or_update_query(query)
    {:a => 1}
  end

  def run_tests_that_require_database_connection?
    return false unless defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection('test') && true
  rescue
    false
  end
end
