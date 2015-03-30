# This module is intended to be included into the monitoring controller in your app to provide
# checks for Rails sessions in the database.
module RosettaStone
  module MonitoringController
    module RailsSessionChecks

      # The following constants can optionally be defined in your monitoring controller *before* including this module
      # in order to customize the behavior of these checks:
      # WHAT_RAILS_SESSIONS_INDICATE_USAGE_OF (defaults to "application")
      # ACTIVE_RAILS_SESSION_AGE_IN_MINUTES (defaults to 5)
      # USE_CONNECTION_TZ_FOR_DATABASE_NOW (defaults to false, which uses utc_timestamp().  true uses SQL now())
      # RAILS_SESSION_COUNT_THRESHOLD (defaults to 10000)
      # RAILS_SESSION_AVERAGE_SIZE_THRESHOLD (defaults to 64000)
      # RAILS_SESSION_CLASS (defaults to ActiveRecord::SessionStore::Session)
      def self.included(controller_class)
        rails_session_class = (defined?(controller_class::RAILS_SESSION_CLASS) && controller_class::RAILS_SESSION_CLASS) || ActiveRecord::SessionStore::Session

        controller_class.define_check(:active_rails_session_count, {
          :description => "Number of active Rails sessions.  Approximation of the number of users currently using the #{(defined?(controller_class::WHAT_RAILS_SESSIONS_INDICATE_USAGE_OF) && controller_class::WHAT_RAILS_SESSIONS_INDICATE_USAGE_OF) || 'application'}.  Pass ?minutes=N to override the number of minutes.",
          :type => 'rails_sessions'
        }) do
          minutes_back = (params[:minutes] && params[:minutes].to_i) || (defined?(controller_class::ACTIVE_RAILS_SESSION_AGE_IN_MINUTES) && controller_class::ACTIVE_RAILS_SESSION_AGE_IN_MINUTES) || 5
          now_function = (defined?(controller_class::USE_CONNECTION_TZ_FOR_DATABASE_NOW) && controller_class::USE_CONNECTION_TZ_FOR_DATABASE_NOW) ? 'now()' : 'utc_timestamp()'
          active_count = rails_session_class.count(:conditions => ["updated_at > date_sub(#{now_function}, interval ? minute)", minutes_back])
          respond_with(active_count)
        end

        total_session_count_threshold = (defined?(controller_class::RAILS_SESSION_COUNT_THRESHOLD) && controller_class::RAILS_SESSION_COUNT_THRESHOLD) || 10000
        controller_class.define_check(:rails_session_count, :description => "Number of Rails sessions in the database.  Pass threshold=X to override default of #{total_session_count_threshold}.", :type => 'rails_sessions') do
          threshold = params[:threshold] ? params[:threshold].to_i : total_session_count_threshold
          count = rails_session_class.count
          status = count > threshold ? 'ERROR' : 'OK'
          respond_with("#{status}: #{count}")
        end

        session_size_threshold = (defined?(controller_class::RAILS_SESSION_AVERAGE_SIZE_THRESHOLD) && controller_class::RAILS_SESSION_AVERAGE_SIZE_THRESHOLD) || 64000
        controller_class.define_check(:rails_session_average_size, :description => "Average data length (in bytes) of Rails sessions in the database.  Pass threshold=X to override default of #{session_size_threshold}.", :type => 'rails_sessions') do
          threshold = params[:threshold] ? params[:threshold].to_i : session_size_threshold
          average_size = rails_session_class.average('length(data)').to_i
          status = average_size > threshold ? 'ERROR' : 'OK'
          respond_with("#{status}: #{average_size}")
        end
      end
    end
  end
end