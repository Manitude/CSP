module ExternalHandler

	class HandleSession

		class << self

			# Reverses the contents of a String or IO object.
			#
			# @param [String, #read] contents the contents to reverse
			# @return [String] the contents reversed lexically
			# creating sessions
			def create_sessions(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					Eschool::Session.create(options)
				when 'supersaas'
					SuperSaas::Session.create(options)
				end
			end

			# finding session
			def find_session(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					options[:handle_eschool_down] ||= false
					Eschool::Session.find_by_id(options[:id], options[:handle_eschool_down])
				when 'supersaas'
					SuperSaas::Session.find_by_id(options[:id], lang.identifier, options[:number_of_seats])
				end
			end

			# find sessions
			def find_sessions(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					options[:handle_eschool_down] ||= false
					Eschool::Session.find_by_ids(options[:ids], options[:handle_eschool_down])
				when 'supersaas'
					# Bulk finding sessions not available in supersaas
				end
			end

			# updating sessions
			def update_sessions(lang, options, coach_session)
				set_connection_type_ambient(lang)
				result = error_message = nil
				options[:supersaas_check] = true if options[:supersaas_check].nil?

				if lang.eschool?
					result        = Eschool::Session.bulk_edit_sessions(:sessions => options[:sessions].flatten)
					error_message = 'An issue occurred when your edit was submitted to eSchool, and your changes were not saved. Please try again later, and contact the Help Desk if the issue persists.' if result.blank?
				elsif lang.super_saas? && options[:supersaas_check]
					[options[:sessions]].flatten.each do |session|
						options.merge!(Topic.fetch_topic_details(options[:topic_id])) if options[:topic_id]
						options[:id] = coach_session.eschool_session_id
						result       = SuperSaas::Session.update_session_in_saas(session[:start_time], session)
					end
				end
				error_message ||= ""
				return options, result, error_message
			end

			# cancel single session
			def cancel_session(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					Eschool::Session.cancel(:eschool_session_id => options[:remote_session_id], :cancelled_by => options[:cancelled_by])
				when 'supersaas'
					SuperSaas::Session.cancel(options[:remote_session_id], options[:session_start_time], lang.identifier, options[:number_of_seats])
				end
			end

			# cancel bulk sessions
			def cancel_sessions(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					Eschool::Session.bulk_cancel(options[:session_ids].flatten)
				when 'supersaas'
					# Bulk cancel sessions not available in supersaas
				end
			end

			# un-cancel bulk sessions
			def un_cancel_sessions(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					Eschool::Session.bulk_uncancel(options[:session_ids].flatten)
					when 'supersaas'
					# Bulk un-cancel sessions not available in supersaas
				end
			end

			# edit sessions
			def edit_sessions(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					Eschool::Session.bulk_edit_sessions(:sessions => [options[:sessions]].flatten)
				when 'supersaas'
					SuperSaas::Session.update_session_in_saas(options[:session_start_time], options)
				end
			end

			# delete session
			def delete_session(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					Eschool::Session.delete_session(options)
				when 'supersaas'
					SuperSaas::Session.delete_booking_in_saas(options[:remote_session_id], options[:session_start_time], lang, options[:number_of_seats])
				end
			end

			# substitute session
			def substitute_session(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					options[:eschool_session_id] = options[:remote_session_id]
					Eschool::Session.substitute(options)
				when 'supersaas'
					SuperSaas::Session.substitute(options[:session], options[:grabber_coach], options[:coach]) if options[:grabber_coach] != options[:coach] 
				end
			end

			def find_upcoming_sessions_for_language_and_levels(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					Eschool::Session.find_upcoming_sessions_for_language_and_levels(lang.identifier, options[:level_string], options[:start_date], options[:end_date], options[:page_num], options[:village_ids], options[:number_of_seats])
				when 'supersaas'
					# find_upcoming_sessions_for_language_and_levels not available in supersaas
				end
			end

			def find_upcoming_sessions_for_language_and_levels_without_pagination(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					Eschool::Session.find_upcoming_sessions_for_language_and_levels_without_pagination(lang.identifier, options[:level_string], options[:start_date], options[:end_date], options[:page_num], options[:village_ids], options[:number_of_seats])
				when 'supersaas'
					# find_upcoming_sessions_for_language_and_levels_without_pagination not available in supersaas
				end
			end

			def find_registered_and_unregistered_learners_for_session(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					Eschool::Session.find_registered_and_unregistered_learners_for_session(options[:session_id], options[:class_id], options[:email])
				when 'supersaas'
					# find_registered_and_unregistered_learners_for_session not available in supersaas
				end
			end

			def get_session_details(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					Eschool::Session.get_session_details(options)
				when 'supersaas'
					SuperSaas::Session.get_booking_details(options[:booking_id], options[:schedule_id])
				end
			end

			def get_sessions_in_next_x_minutes(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					Eschool::Session.get_sessions_in_next_x_minutes(options[:time])
				when 'supersaas'
					# get_sessions_in_next_x_minutes not available in supersaas
				end
			end

			def remove_student_from_session(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					Eschool::Session.remove_student_from_session(options[:attendance_id])
				when 'supersaas'
					# remove_student_from_session not available in supersaas
				end
			end

			def add_student_to_session(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					Eschool::Session.add_student_to_session(options[:session_id], options[:student_id], options[:single_number_unit], options[:lesson], options[:one_on_one])
				when 'supersaas'
					# add_student_to_session not available in supersaas
				end
			end

			def dashboard_data(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					Eschool::Session.dashboard_data(options[:dashboard_user_name], options[:records_per_page], options[:page_num], options[:start_time], options[:end_time], options[:session_language], options[:support_language], options[:native_language], options[:dashboard_future_session], options[:get_non_assistable_sessions])
				when 'supersaas'
					# dashboard_data not available in supersaas
				end
			end

			def set_has_technical_problem(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					Eschool::Session.set_has_technical_problem(options[:remote_session_id], options[:student_guid], options[:has_technical_problem])
				when 'supersaas'
					# set_has_technical_problem not available in supersaas
				end
			end

			def update_wildcard_units_for_eschool_sessions(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					Eschool::Session.update_wildcard_units_for_eschool_sessions(options[:qualification])
				when 'supersaas'
					# update_wildcard_units_for_eschool_sessions not available in supersaas
				end
			end

			def get_reflex_studio_recording_enabled(lang, options = {})
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					Eschool::Session.get_reflex_studio_recording_enabled
				when 'supersaas'
					# get_reflex_studio_recording_enabled not available in supersaas
				end
			end

			def sessions_count_for_ms_week(lang, options = {})
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					options[:handle_eschool_down] ||= false
					Eschool::Session.sessions_count_for_ms_week(options[:start_time], options[:end_time], lang.identifier, options[:classroom_type], options[:village_id], options[:handle_eschool_down])
				when 'supersaas'
					# sessions_count_for_ms_week not available in supersaas
				end
			end

			def find_between(lang, options = {})
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					Eschool::Session.find_between(options[:from_time], options[:to_time], lang.identifier)
				when 'supersaas'
					# find_between not available in supersaas
				end
			end

			def custom_method_collection_url(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					# custom_method_collection_url not available in eschool
				when 'supersaas'
					SuperSaas::Session.custom_method_collection_url(options[:method_name], options[:others])
				end
			end

			def get_slot_id_for_session(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					# get_slot_id_for_session not available in eschool
				when 'supersaas'
					SuperSaas::Session.get_slot_id_for_session(options[:guid], lang.identifier, options[:start_time], options[:number_of_seats])
				end
			end

			def fetch_slot_description(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					# fetch_slot_description not available in eschool
				when 'supersaas'
					SuperSaas::Session.fetch_slot_description(options[:guid], lang.identifier, options[:start_time], options[:number_of_seats])
				end
			end

			def assign_extra_session(lang, options)
				set_connection_type_ambient(lang)
				case lang.external_scheduler
				when 'eschool'
					Eschool::Session.assign_extra_session(options[:remote_session_id], options[:coach_id])
				when 'supersaas'
					SuperSaas::Session.substitute(options[:session], options[:grabber_coach], options[:coach]) if options[:grabber_coach] != options[:coach] 
					# For supersaas, an extra session is up for a substitution
				end
			end

			private

			def set_connection_type_ambient(lang)
				raise 'First parameter should be Language object' unless lang.is_a?(Language)
				Ambient.init
				Ambient.connection_type = lang.connection_type
				SuperSaas::Base.reset_credentials(lang.connection_type) unless lang.connection_type.blank?
			end

		end

	end

end