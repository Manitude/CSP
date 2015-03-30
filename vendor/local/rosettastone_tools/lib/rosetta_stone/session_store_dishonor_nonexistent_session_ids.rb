# Copyright:: Copyright (c) 2011 Rosetta Stone
# License:: All rights reserved.

# The ActiveRecord SessionStore in Rails 2.3+ seems to have this curious behavior of honoring the session ID specified by
# the client even if that session ID doesn't exist in the database.  I'm not sure why it does that, or why that behavior
# seemed (?) to have changed between Rails 2.2.x and 2.3.x (see https://opx.lan.flt/changeset/16435#file22)
#
# This change overrides two methods to make it so that the ActiveRecord SessionStore will not honor a client-specified
# session ID that does not exist; rather it will generate and return a new session ID in that case.
#
# See Work Item 16035
if RosettaStone::RailsVersionString >= RosettaStone::VersionString.new(2,3,0) && defined?(ActiveRecord::SessionStore)
  module ActiveRecord
    class SessionStore
    private

      def get_session(env, sid)
        Base.silence do
          session = find_session(sid)
          env[SESSION_RECORD_KEY] = session
          [session.session_id, session.data]
        end
      end

      def find_session(id)
        (id.present? && @@session_class.find_by_session_id(id)) ||
          @@session_class.new(:session_id => generate_sid, :data => {})
      end
    end
  end
end