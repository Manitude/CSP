# This module is intended to be included into the monitoring controller in your app to provide
# checks for detecting clock skew between individual app tier boxes and to the database server.
module RosettaStone
  module MonitoringController
    module ClockChecks

      # The following constants can be defined in your monitoring controller *before* including this module
      # in order to customize the behavior of these checks:
      # CLOCK_CHECK_ACTIVE_RECORD_CLASS: this must be an ActiveRecord class that has 'id' and 'created_at' and has new records created regularly from multiple boxes
      # CLOCK_CHECK_QUERY_PROC: specify either this or CLOCK_CHECK_ACTIVE_RECORD_CLASS.  CLOCK_CHECK_QUERY_PROC specifies a block to run to retrieve the records to analyze
      # CLOCK_CHECK_NUMBER_OF_RECORDS_TO_CONSIDER: defaults to 100, how many records to look at
      # CLOCK_CHECK_SKEW_THRESHOLD: in seconds, defaults to 5.  if the skew is larger than this, the result will be prefixed with ERROR:
      # CLOCK_CHECK_TIMESTAMP_COLUMN: defaults to 'created_at'. the name of the column with the timestamp.
      #
      def self.included(controller_class)
        unless defined?(controller_class::CLOCK_CHECK_ACTIVE_RECORD_CLASS) || defined?(controller_class::CLOCK_CHECK_QUERY_PROC)
          raise "You must define CLOCK_CHECK_ACTIVE_RECORD_CLASS or CLOCK_CHECK_QUERY_PROC before including this module"
        end

        controller_class.define_check(:detected_clock_skew_in_seconds, {
          :description => "Maximum detected clock aberration (in seconds) based on recent #{controller_class::CLOCK_CHECK_ACTIVE_RECORD_CLASS if defined?(controller_class::CLOCK_CHECK_ACTIVE_RECORD_CLASS)} records.",
          :type => 'clocks'
        }) do
          num_records = (defined?(controller_class::CLOCK_CHECK_NUMBER_OF_RECORDS_TO_CONSIDER) && controller_class::CLOCK_CHECK_NUMBER_OF_RECORDS_TO_CONSIDER) || 100
          skew_threshold = (defined?(controller_class::CLOCK_CHECK_SKEW_THRESHOLD) && controller_class::CLOCK_CHECK_SKEW_THRESHOLD) || 5

          minimum_time = Time.max
          maximum_skew = 0

          timestamp_column = (defined?(controller_class::CLOCK_CHECK_TIMESTAMP_COLUMN) && controller_class::CLOCK_CHECK_TIMESTAMP_COLUMN) || :created_at
          records = (defined?(controller_class::CLOCK_CHECK_QUERY_PROC) && controller_class::CLOCK_CHECK_QUERY_PROC.call) ||
            controller_class::CLOCK_CHECK_ACTIVE_RECORD_CLASS.all(:select => timestamp_column, :order => 'id desc', :limit => 100)

          records.each do |record|
            record_created_at = record.send(timestamp_column)
            if record_created_at <= minimum_time
              minimum_time = record_created_at
            else
              skew = record_created_at - minimum_time
              maximum_skew = skew if skew > maximum_skew
            end
          end
          maximum_skew = maximum_skew.round

          status = (maximum_skew >= skew_threshold) ? 'ERROR' : 'OK'
          respond_with("#{status}: #{maximum_skew}")
        end

        # TODO: might be nice to set up separate checks for a configurable set of database connections, not just the primary...
        controller_class.define_check(:detected_database_clock_difference_in_seconds, {
          :description => "Current detected clock difference between this application server and the primary database server.",
          :type => 'clocks'
        }) do
          skew_threshold = (defined?(controller_class::CLOCK_CHECK_SKEW_THRESHOLD) && controller_class::CLOCK_CHECK_SKEW_THRESHOLD) || 5

          db_time = ActiveRecord::Base.connection.select_value('select now();')
          difference = (Time.now.to_i - db_time.to_i)

          status = (difference >= skew_threshold) ? 'ERROR' : 'OK'
          respond_with("#{status}: #{difference}")
        end
      end
    end
  end
end