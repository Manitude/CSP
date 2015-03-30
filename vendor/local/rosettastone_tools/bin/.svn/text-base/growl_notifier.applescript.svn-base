-- usage: osascript growl_notifier.scpt TASK_NAME 0|1 [reason for failure]
on run argv
	if (count of argv) ² 1 then
		log "usage: osascript growl_notifier.scpt TASK_NAME 0|1 [reason for failure]"
		return
	end if
	tell application "System Events"
		set isRunning to (count of (every process whose name is "Growl")) > 0
	end tell
	
	if isRunning then
		tell application "Growl"
			-- Make a list of all the notification types 
			-- that this script will ever send:
			set the allNotificationsList to Â
				{"Test Failed", "Test Successful"}
			
			-- Make a list of the notifications 
			-- that will be enabled by default.      
			-- Those not enabled by default can be enabled later 
			-- in the 'Applications' tab of the growl prefpane.
			set the enabledNotificationsList to Â
				{"Test Failed", "Test Successful"}
			
			-- Note that reregistering seems to always overwrite whatever
			-- growl preferences you had saved. I haven't found a way to
			-- only send the register call if it hasn't been registered, but
			-- as far as I can tell, the preferences in Growl aren't even
			-- obeyed by the notify command anyway
			register as application Â
				"Rosetta Stone Rails Apps" all notifications allNotificationsList Â
				default notifications enabledNotificationsList Â
				icon of application "Terminal"
			
			set test_name to item 1 of argv
			
			if item 2 of argv = "0" then
				notify with name Â
					"Test Successful" title Â
					"Tests Successful!" description Â
					"The execution of " & test_name & " was successful!" application name "Rosetta Stone Rails Apps"
				
			else
				set more_details to "The execution of " & test_name & " failed! "
				if (count of argv) > 2 then
					set more_details to more_details & (item 3 of argv)
				end if
				notify with name Â
					"Test Failed" title Â
					"Tests Failed!" description Â
					more_details application name "Rosetta Stone Rails Apps"
			end if
		end tell
	end if
end run
