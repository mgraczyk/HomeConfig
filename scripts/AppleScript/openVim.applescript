on open this_item
	tell application "System Events"
		if (count (processes whose name is "iTerm")) is 0 then
			tell application "iTerm"
				activate
				
				if (count of terminals) = 0 then
					set t to (make new terminal)
				else
					set t to current terminal
				end if
				
				tell t
					set mysession to (make new session at the end of sessions)
					
					tell mysession
						exec command "vim " & (POSIX path of this_item)
					end tell
				end tell
			end tell
			
			tell application "iTerm"
				terminate the first session of the first terminal
			end tell
		else
			tell application "iTerm"
				activate
				
				if (count of terminals) = 0 then
					set t to (make new terminal)
				else
					set t to current terminal
				end if
				
				tell t
					set mysession to (make new session at the end of sessions)
					
					tell mysession
						exec command "vim " & (POSIX path of this_item)
					end tell
				end tell
			end tell
		end if
	end tell
	
end open