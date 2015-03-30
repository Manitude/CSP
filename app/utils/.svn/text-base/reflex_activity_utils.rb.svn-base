module ReflexActivityUtils
  ACCEPTABLE_FOLLOWERS = {:coach_initialized => %w{coach_initialized coach_match_accepted coach_paused coach_resumed},
   :coach_match_accepted => %w{coach_ready coach_paused student_not_show_up coach_end_session_incomplete coach_end_session_complete coach_initialized},
   :coach_ready => %w{student_not_show_up coach_end_session_complete coach_end_session_incomplete coach_paused coach_initialized},
   :student_not_show_up => %w{coach_end_session_incomplete coach_initialized},
   :coach_end_session_complete => %w{coach_paused coach_match_accepted coach_initialized},
   :coach_end_session_incomplete => %w{coach_paused coach_ready coach_initialized},
   :coach_paused => %w{coach_initialized coach_resumed},
   :coach_resumed => %w{coach_initialized coach_match_accepted coach_paused}}

end
