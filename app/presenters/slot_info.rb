require File.dirname(__FILE__) + '/../utils/schedules/schedule_utils'

module SlotInfo
  class SlotInfoLotusFetcher
    attr_accessor :confirmed_session, :orphaned_session, :local_session, :extra_session
    def confirmed_session

    end
    def orphaned_session
    end
    def local_session
    end
    def extra_session
    end
    def populate_slot_info(confirmed_sessions, orphaned_session, local_session, extra_session)
      @confirmed_session = confirmed_sessions
      @orphaned_session = orphaned_session
      @local_session = local_session
      @extra_session = extra_session
    end
  end
  class SlotInfoFetcher
    attr_accessor :confirmed_session, :orphaned_session, :local_session, :extra_session
    def confirmed_session
    end
    def orphaned_session
    end
    def local_session
    end
    def extra_session
    end
    def populate_slot_info(confirmed_sessions, orphaned_session, local_session, extra_session)
      @confirmed_session = confirmed_sessions
      @orphaned_session = orphaned_session
      @local_session = local_session
      @extra_session = extra_session
    end
  end
end
