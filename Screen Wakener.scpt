(*
    “Screen Wakener” – Activation tool intended for Hackintosh “Black
    Screens” that appear in “System Preferences” ▸ “Displays”.
    Copyright © 2019 by “mabam”

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

    Contact via https://github.com/mabam/ScreenWakener/issues
*)

set appPath to (path to me as text)
set quotedPOSIXAppPath to "\"" & (POSIX path of appPath) & "\""
set {tid, AppleScript's text item delimiters} to {AppleScript's text item delimiters, {"\\ ", space}}
set escapedPOSIXAppPath to (every text item of (POSIX path of appPath)) as text
set AppleScript's text item delimiters to tid


-- Language formatting for the dialogs.

-- English localization.
set buttonCancelEN to "Cancel"
set buttonSelectEN to "Select"
set buttonApplicationsEN to "Open “Applications” …"
set buttonChangeSettingsEN to "Change settings …"
set buttonStopLogORRemoveEN to "Stop logging OR remove Screen Wakener …"
set buttonStartLogORRemoveEN to "Write log file OR remove Screen Wakener …"
set buttonContinueEN to "Continue …"
set buttonOpenPrefsEN to "Open System Preferences …"
set buttonRemoveEN to "Remove Screen Wakener …"
set buttonDefRemoveEN to "Remove …"
set buttonStopLogEN to "Stop logging"
set buttonStartLoggingEN to "Start logging"

set displayNameEDIDen to "Display Name (from EDID): "
set vendorIDen to "Vendor ID: "
set productIDen to "Product ID: "
set dialogTempResSelectionVarResEN to "resolution"
set dialogTempResSelectionVarFreqEN to "frequency"

-- German localization.
set buttonCancelDE to "Abbrechen"
set buttonSelectDE to "Auswählen"
set buttonApplicationsDE to "“Programme” öffnen …"
set buttonChangeSettingsDE to "Einstellungen ändern …"
set buttonStopLogORRemoveDE to "Log abschalten ODER Screen Wakener löschen …"
set buttonStartLogORRemoveDE to "Log aufzeichnen ODER Screen Wakener löschen …"
set buttonContinueDE to "Weiter …"
set buttonOpenPrefsDE to "Systemeinstellungen öffnen …"
set buttonRemoveDE to "Screen Wakener löschen …"
set buttonDefRemoveDE to "Entfernen …"
set buttonStopLogDE to "Log abschalten"
set buttonStartLoggingDE to "Log aufzeichnen"

set displayNameEDIDde to "Monitor-Name (aus EDID): "
set vendorIDde to "Hersteller-ID: "
set productIDde to "Produkt-ID: "
set dialogTempResSelectionVarResDE to "Auflösung"
set dialogTempResSelectionVarFreqDE to "Frequenz"

-- Get system language.
set systemLanguage to first word of (do shell script "defaults read NSGlobalDomain AppleLanguages")
-- set systemLanguage to (do shell script "plutil -convert xml1 -o - /Users/markus/Library/Preferences/.GlobalPreferences.plist | xmllint --xpath '/plist/dict/key[text()=\"AppleLocale\"]/following-sibling::string[position()=1]/text()' - | cut -d'_' -f1")

if systemLanguage is "de" then
	set buttonOK to "OK"
	set buttonCancel to buttonCancelDE
	set buttonSelect to buttonSelectDE
	set buttonApplications to buttonApplicationsDE
	set buttonChangeSettings to buttonChangeSettingsDE
	set buttonStopLogORRemove to buttonStopLogORRemoveDE
	set buttonStartLogORRemove to buttonStartLogORRemoveDE
	set buttonContinue to buttonContinueDE
	set buttonOpenPrefs to buttonOpenPrefsDE
	set buttonRemove to buttonRemoveDE
	set buttonDefRemove to buttonDefRemoveDE
	set buttonStopLog to buttonStopLogDE
	set buttonStartLogging to buttonStartLoggingDE
	
	set terminalSource to "_DE"
	set displayNameEDID to displayNameEDIDde
	set vendorID to vendorIDde
	set productID to productIDde
	set dialogTempResSelectionVarRes to dialogTempResSelectionVarResDE
	set dialogTempResSelectionVarFreq to dialogTempResSelectionVarFreqDE
else
	set buttonOK to "OK"
	set buttonCancel to buttonCancelEN
	set buttonSelect to buttonSelectEN
	set buttonApplications to buttonApplicationsEN
	set buttonChangeSettings to buttonChangeSettingsEN
	set buttonStopLogORRemove to buttonStopLogORRemoveEN
	set buttonStartLogORRemove to buttonStartLogORRemoveEN
	set buttonContinue to buttonContinueEN
	set buttonOpenPrefs to buttonOpenPrefsEN
	set buttonRemove to buttonRemoveEN
	set buttonStopLog to buttonStopLogEN
	set buttonStartLogging to buttonStartLoggingEN
	
	set terminalSource to "_EN"
	set displayNameEDID to displayNameEDIDen
	set vendorID to vendorIDen
	set productID to productIDen
	set dialogTempResSelectionVarRes to dialogTempResSelectionVarResEN
	set dialogTempResSelectionVarFreq to dialogTempResSelectionVarFreqEN
	
end if


-- Make these global to reach into the handlers:
global buttonCancel
global buttonSelect
global buttonOpenPrefs
global buttonContinue

global systemLanguage
global IOClassAppleDisplay
global screenParticulars
global selectionDialogLineBreakTab
global selectionDialogLineBreak
global busySoftwareCons
global quotedPOSIXAppPath
global terminalSource
global dialogTempResSelectionVarRes
global dialogTempResSelectionVarFreq

-- Make these global to reach outside of the handlers:
global screenChoice
global chosenDisplayID
global currentMode
global tempMode
global displayFinalResItems
global dialogTempResSelectionVar
global tempMode


-- Check whether ScreenWakener.app is in /Applications. Display Alert if not.
if systemLanguage is "de" then
	if not (POSIX path of (path to me as string) is "/Applications/Screen Wakener.app/") then
		tell application (path to frontmost application as text) to set wrongLocation to button returned of (display alert "Nach „Programme“ verschieben" message "Damit „Screen Wakener“ funktionieren kann, muss er sich im „Programme“-Ordner befinden. Bitte verschieben Sie ihn dorthin." as critical buttons {buttonApplications, buttonOK})
		if wrongLocation = buttonOK then error number -128 -- stop script execution
		if wrongLocation = buttonApplications then
			-- Open Applications folder in new Finder window, even if Applications is already open in a different window.
			tell application "Finder" to set target of (make new Finder window) to path to applications folder
			-- Bring only that window to front, not the other Finder windows.
			do shell script "open -a Finder"
			error number -128 -- stop script execution
		end if
	end if
else
	if not (POSIX path of (path to me as string) is "/Applications/Screen Wakener.app/") then
		tell application (path to frontmost application as text) to set wrongLocation to button returned of (display alert "Move to “Applications” folder" message "In order for “Screen Wakener” to work, it must be located in your System’s Applications folder. Please move it there." as critical buttons {buttonApplications, buttonOK})
		if wrongLocation = buttonOK then error number -128 -- stop script execution
		if wrongLocation = buttonApplications then
			-- Open Applications folder in new Finder window, even if Applications is already open in a different window.
			tell application "Finder" to set target of (make new Finder window) to path to applications folder
			-- Bring only that window to front, not the other Finder windows.
			do shell script "open -a Finder"
			error number -128 -- stop script execution
		end if
	end if
end if


-- Read display information from IO Registry WITHOUT changing its line endings from ASCII 10 (line feed (LF) – AppleScript: linefeed) to ASCII 13 (carriage return (CR) – AppleScript: return). Discard what we don’t need.
set IOClassAppleDisplay to do shell script "ioreg -w 0 -rc AppleDisplay | egrep '\\+-o|DisplayProductID|AppleIntelFramebuffer|DisplayVendorID'" without altering line endings

-- Extract all instances of AppleIntelFramebuffer@n as those represent the Software Connectors which are recognised to have a screen attached to them.
set busySoftwareCons to paragraphs of (do shell script "echo \"" & IOClassAppleDisplay & "\" | grep -o \"AppleIntelFramebuffer@.\" | sort -u")

-- Changing the AppleScript delimiters resulted in an empty list every time. Also, adding to the end of a list would delete all other items from the list (probably some formatting issue I couldn’t figure out). So we work around that by setting screenParticulars to a list with a dummy item instead of an empty list. This will lateron let us prepare the list with displays for the selection dialog.
set screenParticulars to {"dummy"}

-- For every busy Software Connector, extract the corresponding REAL Vendor ID and Product ID from IOClassAppleDisplay.
repeat with sequentialItem from 1 to the count of busySoftwareCons
	set screenIDs to words -2 thru -1 of (do shell script "echo \"" & IOClassAppleDisplay & "\" | grep \"" & item sequentialItem of busySoftwareCons & "\"")
	
	-- For every pair of Vendor & Product ID, try to extract the Display Name from the corresponding EDID Override file (if present).
	-- Prepare some text formatting for the screen selection dialog to be generated later in this script.
	try
		set EDIDDisplayName to {displayNameEDID, (do shell script "xmllint --xpath '/plist/dict/key[text()=\"DisplayProductName\"]/following-sibling::string[position()=1]/text()' /System/Library/Displays/Contents/Resources/Overrides/DisplayVendorID-" & (item 1 of screenIDs as string) & "/DisplayProductID-" & (item 2 of screenIDs as string)), "  •  "}
		set selectionDialogLineBreakTab to " "
		set selectionDialogLineBreak to " "
	on error
		set EDIDDisplayName to {}
		set selectionDialogLineBreakTab to {return & tab}
		set selectionDialogLineBreak to {return & space & space & space}
	end try
	
	-- Prepare list with displays for the selection dialog.
	set screenParticulars to every item of screenParticulars & ({sequentialItem, ": ", EDIDDisplayName, vendorID, (item 1 of screenIDs as string), "  •  " & productID, (item 2 of screenIDs as string), "  •  (", (item sequentialItem of busySoftwareCons as string), ")"} as string)
end repeat

-- Let user select screen and temporary settings.
on dialogScreenSelection()
	-- Let user choose “Black Screen”.
	if systemLanguage is "de" then
		tell application (path to frontmost application as text) to set openPrefs to button returned of (display alert "ACHTUNG:" message "Nach dem Aktivieren Ihres „Schwarzen Monitors“ wird „Screen Wakener“ diesen immer auf seine jetzigen Einstellungen zurücksetzen. Stellen Sie daher bevor Sie fortfahren sicher, dass er in „Systemeinstellungen“ ▸ „Monitore“ richtig konfiguriert ist." & return & return & "Copyright © 2019 by ‘mabam’" & return & "Für dieses Programm besteht KEINERLEI GARANTIE." & return & "Dies ist freie Software, die Sie unter bestimmten Bedingungen weitergeben dürfen. |" & return & "Für Details siehe die GNU General Public License unter https://www.gnu.org/licenses/ (deutsche Übersetzung: http://www.gnu.de/documents/gpl.de.html)." buttons {buttonOpenPrefs, buttonContinue} default button buttonContinue)
		if openPrefs is buttonOpenPrefs then
			tell application "System Preferences"
				activate
				set current pane to pane id "com.apple.preference.displays"
			end tell
			error number -128 -- stop script execution
		end if
		tell application (path to frontmost application as text) to set screenChoice to choose from list (rest of screenParticulars) with title "„Schwarzen Monitor“ wählen" with prompt "Bitte wählen Sie Ihren „Schwarzen Monitor“ entweder" & return & "• anhand seines Namens (nur verfügbar, wenn in der EDID-Override-Datei" & selectionDialogLineBreak & "Ihres Monitors gespeichert), oder" & return & "• indem Sie Hersteller- und Produkt-ID mit denen unter dem Reiter" & selectionDialogLineBreak & "„Display“ in Hackintool vergleichen." & return & return & "Zum Abschluss erscheint eine Passwort-Abfrage." & return & return & "(Die Nummer hinter „AppleIntelFramebuffer@“ gibt an, welcher Software Connector verwendet wird.)" cancel button name buttonCancel OK button name buttonSelect
	else
		tell application (path to frontmost application as text) to set openPrefs to button returned of (display alert "ATTENTION:" message "After activating your “Black Screen”, “Screen Wakener” will always set it back to its present configuration. Therefore make sure it is correctly configured in “System Preferences” ▸ “Displays” before you continue." & return & return & "Copyright © 2019 by ‘mabam’" & return & "This program comes with ABSOLUTELY NO WARRANTY. This is free software, and you are welcome to redistribute it under certain conditions. | For details see the GNU General Public License under https://www.gnu.org/licenses/." buttons {buttonOpenPrefs, buttonContinue} default button buttonContinue)
		if openPrefs is buttonOpenPrefs then
			tell application "System Preferences"
				activate
				set current pane to pane id "com.apple.preference.displays"
			end tell
			error number -128 -- stop script execution
		end if
		tell application (path to frontmost application as text) to set screenChoice to choose from list (rest of screenParticulars) with title "Choose your “Black Screen”" with prompt "Please identify your “Black Screen” either" & return & "• by name (only available if set in your screen’s EDID Override file)," & selectionDialogLineBreakTab & "or" & return & "• by comparing Vendor ID and Product ID with the ones under" & selectionDialogLineBreak & "“Display” in Hackintool." & return & return & "At completion you will be prompted for your password." & return & return & "(The number behind “AppleIntelFramebuffer@” indicates which Software Connector is used.)" cancel button name buttonCancel OK button name buttonSelect
	end if
	if screenChoice is false then error number -128 -- stop script execution
	
	-- Split up Display info from IOReg per screen.
	set {tid, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "+-o"}
	set IOClassAppleDisplaySplit to rest of text items of IOClassAppleDisplay
	set AppleScript's text item delimiters to tid
	
	
	-- For every busy Software Connector, extract the corresponding FAKE Vendor and Product ID’s from IOClassAppleDisplay. These are needed for identifying the corresponding settings in ~/Library/Preferences/ByHost/com.apple.windowserver.* and from there pulling the display ID’s to match with displayplacer.
	set IOClassAppleDisplayParticularsFAKE to {}
	
	repeat with sequentialItem in busySoftwareCons
		repeat with subSequentialItem in IOClassAppleDisplaySplit
			if subSequentialItem contains sequentialItem then
				set IOClassAppleDisplaySorted to (sequentialItem as string) as list
				copy words of (paragraph 2 of subSequentialItem) as string to end of IOClassAppleDisplaySorted
				copy words of (paragraph 4 of subSequentialItem) as string to end of IOClassAppleDisplaySorted
				copy IOClassAppleDisplaySorted as list to end of IOClassAppleDisplayParticularsFAKE
			end if
		end repeat
	end repeat
	
	
	-- Create a list with Software Connector (AppleIntelFramebuffer@n), FAKE Vendor and Product ID’s from the different sets of screen preferences in ~/Library/Preferences/ByHost/com.apple.windowserver.*, and a second list with the corresponding display ID’s.
	set displaySetsArrays1 to {}
	set displaySetsArrays2 to {}
	set displaySetsParticularsFAKE to {}
	set displayIDs to {}
	
	set {tid, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "<array>"}
	set displaySetsArrays to rest of text items of (do shell script "plutil -convert xml1 -o - $(ls -t1 ~/Library/Preferences/ByHost/com.apple.windowserver.* | head -n 1) | xmllint --xpath '/plist/dict/key[text()=\"DisplaySets\"]/following-sibling::array/array' - | egrep -A 1 'array>|</dict>|DisplayID|DisplayProductID|DisplayVendorID|IODisplayLocation'")
	set AppleScript's text item delimiters to "<dict>"
	repeat with sequentialItemArrays1 in displaySetsArrays
		set displaySetsDictsLoop to rest of text items of sequentialItemArrays1
		set end of displaySetsArrays1 to displaySetsDictsLoop
	end repeat
	set AppleScript's text item delimiters to tid
	
	repeat with sequentialItemArrays2 in displaySetsArrays1
		set end of displaySetsArrays2 to {}
		repeat with sequentialItem in busySoftwareCons
			repeat with sequentialItemDicts1 in sequentialItemArrays2
				--try
				if sequentialItemDicts1 contains sequentialItem then set end of list -1 of displaySetsArrays2 to sequentialItemDicts1 as text
				--end try
			end repeat
		end repeat
	end repeat
	
	repeat with sequentialItemArrays3 in displaySetsArrays2
		set sequentialItemArrays3Loop to items of sequentialItemArrays3
		set end of displaySetsParticularsFAKE to {}
		set end of displayIDs to {}
		repeat with sequentialItemDicts2 in sequentialItemArrays3Loop
			set sequentialItemDicts2Loop to (items of sequentialItemDicts2) as text
			set end of list -1 of displaySetsParticularsFAKE to {}
			set end of list -1 of displayIDs to {}
			set {tid, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "</integer>"}
			set sequentialItemInteger to text items of sequentialItemDicts2Loop
			set AppleScript's text item delimiters to tid
			set displaySetsInteger1 to {word 4, word 11} of item 1 of sequentialItemInteger
			set displaySetsInteger2 to {word 4, word 11} of item 2 of sequentialItemInteger
			set displaySetsInteger3 to {word 4, word 11} of item 3 of sequentialItemInteger
			set {tid, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "</string>"}
			set displaySetsString to text item 1 of item 4 of sequentialItemInteger
			set AppleScript's text item delimiters to "/"
			set (end of list -1 of list -1 of displaySetsParticularsFAKE) to (text item -1 of displaySetsString as text)
			set AppleScript's text item delimiters to "="
			set (end of list -1 of list -1 of displaySetsParticularsFAKE) to (displaySetsInteger2 as text)
			set (end of list -1 of list -1 of displaySetsParticularsFAKE) to (displaySetsInteger3 as text)
			set (end of list -1 of list -1 of displayIDs) to (displaySetsInteger1 as text)
			set AppleScript's text item delimiters to tid
		end repeat
	end repeat
	
	
	-- Match connected screens with corresponding preferences set. Its position in list displaySetsParticularsFAKE is the same as the position of the corresponding DisplayID in list displayIDs. (Credits for the count handler this is based on: https://macscripter.net/viewtopic.php?id=12222 and Apple.)
	-- Get Display ID of screen chosen by user.
	repeat with i from 1 to the count of displaySetsParticularsFAKE
		if item i of displaySetsParticularsFAKE is IOClassAppleDisplayParticularsFAKE then set chosenDisplayID to item (first character of (screenChoice as string)) of item i of displayIDs
	end repeat
	
	
	-- Get available display modes for all screens from displayplacer.
	set {tid, AppleScript's text item delimiters} to {AppleScript's text item delimiters, return & return}
	set displayList to text items 1 thru -3 of (do shell script "" & quotedPOSIXAppPath & "Contents/Resources/displayplacer list")
	set AppleScript's text item delimiters to tid
	
	-- Only keep modes for chosenDisplayID.
	repeat with i from 1 to the count of displayList
		if item i of displayList contains word 3 of (chosenDisplayID as string) then set displayResListRaw to item i of displayList
	end repeat
	
	-- Split displayResListRaw into list with the current mode and list with all other modes.
	set displayResItems to {}
	set {tid, AppleScript's text item delimiters} to {AppleScript's text item delimiters, return & "  mode "}
	repeat with mode in rest of text items in displayResListRaw
		if mode contains " <-- current mode" then
			set currentMode to mode as string
		else
			copy mode as string to end of displayResItems
		end if
	end repeat
	set AppleScript's text item delimiters to tid
	
	-- Generate list containing all modes that have the same RESOLUTION and colour depth as current mode.
	set ResBitMatch to {}
	-- set ResBitMatch to {"dummy1, 2, 3, 4, 5"} ---------- Uncomment to test choose from list dialogTempResSelection.
	repeat with mode in displayResItems
		if text of {word 3, word 7} of mode is text of {word 3, word 7} of currentMode then
			copy text of mode to end of ResBitMatch
		end if
	end repeat
	
	-- set ResBitMatch to {} ---------- Uncomment to test list generation with same FREQUENCY and colour depth.
	if (count of ResBitMatch) is 1 then
		set tempMode to {word 1, word 3, word 5} of item 1 of ResBitMatch
	else if (count of ResBitMatch) is greater than 1 then
		set {tid, AppleScript's text item delimiters} to {AppleScript's text item delimiters, space}
		set displayFinalResItems to {}
		repeat with mode in ResBitMatch
			copy (text items 1 thru 3 of mode) as text to end of displayFinalResItems
		end repeat
		set AppleScript's text item delimiters to tid
		set dialogTempResSelectionVar to dialogTempResSelectionVarRes
		dialogTempResSelection()
		-- If no mode with the same resolution and colour depth as the current mode has been found, generate list containing all modes that have the same FREQUENCY and colour depth as current mode.
	else if (count of ResBitMatch) is 0 then
		set HzBitMatch to {}
		repeat with mode in displayResItems
			if text of {word 5, word 7} of mode is text of {word 5, word 7} of currentMode then
				copy text of mode to end of HzBitMatch
			end if
		end repeat
		if (count of HzBitMatch) is 1 then
			set tempMode to {word 1, word 3} of item 1 of HzBitMatch
		else
			set {tid, AppleScript's text item delimiters} to {AppleScript's text item delimiters, space}
			set displayFinalResItems to {}
			repeat with mode in HzBitMatch
				copy (text items 1 thru 2 of mode) as text to end of displayFinalResItems
			end repeat
			set AppleScript's text item delimiters to tid
			set dialogTempResSelectionVar to dialogTempResSelectionVarFreq
			dialogTempResSelection()
		end if
	end if
	
	-- Write settings to /Applications/Screen Wakener.app/Contents/Resources/ScreenWakenerPrefs.
	set prefsFileContent to (chosenDisplayID & linefeed & "currentMode=" & item 1 of currentMode & linefeed & "tempMode=" & item 1 of tempMode) as string
	do shell script "echo \"" & prefsFileContent & "\" > " & quotedPOSIXAppPath & "Contents/Resources/ScreenWakenerPrefs"
	
	-- Copy Launch Agent to /Library/LaunchAgents
	do shell script "cp " & quotedPOSIXAppPath & "Contents/Resources/org.mabam.ScreenWakener.plist /Library/LaunchAgents/; chown root:wheel /Library/LaunchAgents/org.mabam.ScreenWakener.plist" with administrator privileges
end dialogScreenSelection

-- Let user choose temporary resolution (triggered by dialogScreenSelection if there were more than one applicable temp modes detected):
on dialogTempResSelection()
	if systemLanguage is "de" then
		tell application (path to frontmost application as text) to set tempMode to {word 1, word 3} of item 1 of (choose from list displayFinalResItems with title "Temporäre Einstellung wählen" with prompt "Hier sind die Modi des „Schwarzen Monitors“ mit selber " & dialogTempResSelectionVar & " und Farbtiefe wie bei der jetzigen Einstellung gelistet." & return & return & "Um den Monitor zu aktivieren, muss ihm nach dem Systemstart zuerst eine abweichende Einstellung zugewiesen werden. Danach wird er auf seine jetzige zurückgestellt." & return & return & "Bitte wählen Sie einen temporären Modus:" cancel button name buttonCancel OK button name buttonSelect)
	else
		tell application (path to frontmost application as text) to set tempMode to {word 1, word 3} of item 1 of (choose from list displayFinalResItems with title "Choose temporary setting" with prompt "This list contains those native settings of your “Black Screen” that have the same " & dialogTempResSelectionVar & " and colour depth as the screen’s current setting. (Note that the current setting itself is not listed.)" & return & return & "In order to activate the screen, first a different setting has to be applied after boot. Then it will be set back to its current one." & return & return & "Please pick a temporary setting:" cancel button name buttonCancel OK button name buttonSelect)
	end if
end dialogTempResSelection


-- Hand over to Terminal for removal of Screen Wakener.
on scriptRemoveSW()
	set TerminalActive to "no"
	if application "Terminal" is running then set TerminalActive to "yes"
	tell application "Terminal"
		activate
		try
			if TerminalActive is "no" then
				delay 1
				close window 1
			end if
		end try
		do script "source " & quotedPOSIXAppPath & "Contents/Resources/RemoveScreenWakener && clear && bash -c \"$" & terminalSource & "\""
	end tell
	error number -128 -- stop script execution
end scriptRemoveSW

-- Set second button of options dialog box and prepare text formatting for following dialog.
tell application "Finder" to if exists appPath & "Contents:Resources:ScreenWakenerLog.txt" then
	set buttonLogRemove to buttonStopLogORRemove
	set optionsDialogLineBreak to " "
else if (read file (appPath & "Contents:Resources:ScreenWakenerLogSwitch")) is "logFile=/dev/null" then
	set buttonLogRemove to buttonStartLogORRemove
	set optionsDialogLineBreak to " "
else
	set buttonLogRemove to buttonRemove
	set optionsDialogLineBreak to return & space & space & space
end if

-- If Screen Wakener has not been configured yet, do so using the dialogScreenSelection handler. Otherwise offer different choices.
set agentExists to {}
tell application "Finder" to if not (exists POSIX file "/Library/LaunchAgents/org.mabam.ScreenWakener.plist") then
	set agentExists to "no"
end if

if agentExists is "no" then
	dialogScreenSelection()
else
	if systemLanguage is "de" then
		tell application (path to frontmost application as text) to set userChoice1 to button returned of (display dialog "„Screen Wakener” ist konfiguriert und wird nach jedem Systemstart versuchen, Ihren Monitor zu aktivieren. Entweder" & return & "• im Login Bildschirm, oder" & return & "• nach automatischem Login (falls in den Systemeinstellungen aktiviert)." & return & return & "Damit „Screen Wakener“ funktionieren kann, muss er im „Programme“-Ordner verbleiben." & return & return & "VERSCHIEBEN SIE IHN NICHT." with title "Screen Wakener" buttons {buttonChangeSettings, buttonLogRemove, buttonOK} default button buttonOK)
	else
		tell application (path to frontmost application as text) to set userChoice1 to button returned of (display dialog "“Screen Wakener” is configured and will approach to activate your screen after a fresh boot either" & return & "• while in the Login Window, or" & return & "• after auto login to your account (if activated in System Preferences)." & return & return & "In order for it to work, the “Screen Wakener” app has to stay in the “Applications” folder." & return & return & "DO NOT MOVE IT." with title "Screen Wakener" buttons {buttonChangeSettings, buttonLogRemove, buttonOK} default button buttonOK)
	end if
	if userChoice1 = buttonOK then error number -128 -- stop script execution
	if userChoice1 = buttonChangeSettings then dialogScreenSelection()
	if userChoice1 = buttonRemove then
		if systemLanguage is "de" then
			tell application (path to frontmost application as text) to set removeApp to button returned of (display alert "Sind Sie sicher, dass Sie „Screen Wakener“ (diese App und den zugehörigen Launch Agent) aus dem System entfernen möchten?" message "„Entfernen …“ öffnet ein Fenster in Terminal, wo Sie nach Ihrem Passwort gefragt werden." as critical buttons {buttonCancel, buttonDefRemove} default button buttonCancel)
		else
			tell application (path to frontmost application as text) to set removeApp to button returned of (display alert "Are you sure you want to remove “Screen Wakener” (this app and its Launch Agent) from the system?" message "Clicking “Remove” will open a window in Terminal. There you will be asked for your password." as critical buttons {buttonCancel, buttonDefRemove} default button buttonCancel)
		end if
		if removeApp = buttonCancel then error number -128 -- stop script execution
		if removeApp = buttonDefRemove then scriptRemoveSW()
	end if
	if userChoice1 = buttonStopLogORRemove then
		if systemLanguage is "de" then
			tell application (path to frontmost application as text) to set userChoice2 to button returned of (display dialog "• Haben Sie „Screen Wakener“ erfolgreich getestet?" & return & tab & "➔ Klicken Sie dann auf „Log abschalten“ um:" & return & tab & "     · Keine Log-Datei mehr zu führen." & return & return & "• Möchten Sie „Screen Wakener“ entfernen?" & return & tab & "➔ Klicken Sie dann auf „Entfernen …“ um:" & return & tab & "     · Die App inklusive Einstellungen zu löschen und" & return & tab & "     · den Launch Agent aus dem System zu entfernen." & return & tab & "(Ein Terminal-Fenster wird sich öffnen und Sie um" & return & tab & "Bestätigung bitten.)" with title "Testbetrieb beenden oder „Screen Wakener“ entfernen" buttons {buttonCancel, buttonStopLog, buttonDefRemove} default button buttonCancel)
		else
			tell application (path to frontmost application as text) to set userChoice2 to button returned of (display dialog "• Are you done testing “Screen Wakener”?" & return & tab & "➔ Then click “Stop logging” to:" & return & tab & "     · Stop it to keep a log file any longer." & return & return & "• Do you want to remove “Screen Wakener”?" & return & tab & "➔ Then click “Remove …” to:" & return & tab & "     · Completely delete the app with its settings and" & return & tab & "     · delete the Launch Agent from the system." & return & tab & "(A Terminal window will open and ask you for" & return & tab & "confirmation.)" with title "Finish testing “Screen Wakener” or remove it" buttons {buttonCancel, buttonStopLog, buttonDefRemove} default button buttonCancel)
		end if
		if userChoice2 = buttonCancel then error number -128 -- stop script execution
		if userChoice2 = buttonStopLog then
			do shell script "rm " & quotedPOSIXAppPath & "Contents/Resources/ScreenWakenerLog.txt; printf logFile=/dev/null > " & quotedPOSIXAppPath & "Contents/Resources/ScreenWakenerLogSwitch"
		end if
		if userChoice2 = buttonDefRemove then scriptRemoveSW()
	end if
	if userChoice1 = buttonStartLogORRemove then
		if systemLanguage is "de" then
			tell application (path to frontmost application as text) to set userChoice2 to button returned of (display dialog "• Möchten Sie wieder auf Testbetrieb umstellen?" & return & tab & "➔ Klicken Sie dann auf „Log aufzeichnen“ um:" & return & tab & "     · Nach dem nächsten Systemstart wieder eine" & return & tab & "       Log-Datei zu führen." & return & return & "• Möchten Sie „Screen Wakener“ entfernen?" & return & tab & "➔ Klicken Sie dann auf „Entfernen …“ um:" & return & tab & "     · Die App inklusive Einstellungen zu löschen und" & return & tab & "     · den Launch Agent aus dem System zu entfernen." & return & tab & "(Ein Terminal-Fenster wird sich öffnen und Sie um" & return & tab & "Bestätigung bitten.)" with title "Testbetrieb erneut starten oder „Screen Wakener“ entfernen" buttons {buttonCancel, buttonStartLogging, buttonDefRemove} default button buttonCancel)
		else
			tell application (path to frontmost application as text) to set userChoice2 to button returned of (display dialog "• Do you want to resume testing “Screen Wakener”?" & return & tab & "➔ Then click “Start Logging” to:" & return & tab & "     · Have it keep a log file again after next boot." & return & return & "• Do you want to remove “Screen Wakener”?" & return & tab & "➔ Then click “Remove …” to:" & return & tab & "     · Completely delete the app with its settings and" & return & tab & "     · delete the Launch Agent from the system." & return & tab & "(A Terminal window will open and ask you for" & return & tab & "confirmation.)" with title "Resume testing “Screen Wakener” or remove it" buttons {buttonCancel, buttonStartLogging, buttonDefRemove} default button buttonCancel)
		end if
		if userChoice2 = buttonCancel then error number -128 -- stop script execution
		if userChoice2 = buttonStartLogging then
			do shell script "echo \"logFile=" & escapedPOSIXAppPath & "Contents/Resources/ScreenWakenerLog.txt\" > " & quotedPOSIXAppPath & "Contents/Resources/ScreenWakenerLogSwitch; : | /usr/bin/tee -a " & quotedPOSIXAppPath & "Contents/Resources/ScreenWakenerLog.txt"
		end if
		if userChoice2 = "buttonDefRemove" then scriptRemoveSW()
	end if
end if
