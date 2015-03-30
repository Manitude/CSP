# -*- encoding : utf-8 -*-
# Copyright:: Copyright (c) 2011 Rosetta Stone
# License:: All rights reserved.

# ActiveRecord uses the clock on the app tier box for setting created_at & updated_at. Unfortunately this
# means that if different app servers have slightly skewed clocks, you can get weird behavior like
# updated_at being before created_at or updated_at going backward on an update...
#
# Tests for this are in the license server (test/unit/active_record_timestamps_never_go_backward_test.rb)
module RosettaStone
  module ActiveRecordTimestampsNeverGoBackward
    def current_time_from_proper_timezone
      current_time = self.class.default_timezone == :utc ? Time.now.utc : Time.now
      if respond_to?(:updated_at) && updated_at
        if updated_at > current_time
          if (updated_at - current_time) > 120 # arbitrary "large" skew
            logger.error("ActiveRecordTimestampsNeverGoBackward - WARNING: detected potential clock skew: current time is #{current_time.to_s(:db)} but record has updated_at of #{updated_at.to_s(:db)}")
          else
            logger.warn("ActiveRecordTimestampsNeverGoBackward - Note: record updated_at is in future; using it instead of current time")
            current_time = updated_at
          end
        end
      end
      current_time
    end
  end
end

ActiveRecord::Base.send(:include, RosettaStone::ActiveRecordTimestampsNeverGoBackward) if defined?(ActiveRecord::Timestamp)
