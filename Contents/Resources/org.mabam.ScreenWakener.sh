#!/bin/sh


# Set Screen Wakener resources directory:
resourcesDir=/Applications/Screen\ Wakener.app/Contents/Resources


# Import preferences:

source "$resourcesDir"/ScreenWakenerLogSwitch
source "$resourcesDir"/ScreenWakenerPrefs


# Insert a separator under the log entry after last boot and before the
# log entry after present boot. (The separator is inserted if log file
# display.txt exists and its file size is larger than 0.)

if [ -s "$resourcesDir"/ScreenWakenerLog.txt ]; then echo "\n||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\n" >> "$logFile"; elif [ "$logFile" != /dev/null ]; then touch "$logFile"; chown 501:20 "$logFile"; fi


# If user is root (meaning we are in the Login Window), wait until the
# system has recognised all screens:
# Try to verify by looking for the ID # of our “Black Screen” once every
# second (and write a ‘.’ to the # log for every try). If the ID is
# found, wait 3 seconds until the script is continued. If it is not
# found after 10 tries, continue this script:

[ $(id -u) -eq 0 ] && for try in {1..10}; do sleep 1; printf . | tee -a "$logFile"; "$resourcesDir"/displayplacer list | grep "$DisplayID" && break; done && sleep 3


# Log the original settings and mode with date:

date | tee -a "$logFile"
"$resourcesDir"/displayplacer list | awk "/$DisplayID/{print;next}/current mode/{print;exit}" | tee -a "$logFile"


# The following command temporarily sets the “Black Screen” to a
# different resolution:

"$resourcesDir"/displayplacer "id:$DisplayID mode:$tempMode"


# Pause a moment until the second resolution change is performed:

sleep 2


# Set the “Black Screen” back to its original resolution:

"$resourcesDir"/displayplacer "id:$DisplayID mode:$currentMode"