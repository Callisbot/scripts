#!/bin/bash

# This is how brew is able to use softwareupdate to only install xcode
/usr/bin/sudo /usr/bin/touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
xcodeVer=$(pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | awk -F"version: " '{print $2}' | awk -v ORS="" '{gsub(/[[:space:]]/,""); print}' | awk -F"." '{print $1"."$2}')
xcodeLatestVer=$(/usr/bin/sudo /usr/sbin/softwareupdate -l | awk -F"Version:" '{ print $1}' | awk -F"Xcode-" '{ print $2 }' | sort -nr | head -n1)

xcodeInstall() {
	#installs xcode commandline tools
	printf "\nInstalling Xcode CommandLine Tools version $xcodeLatestVer\n"
	/usr/bin/sudo /usr/sbin/softwareupdate -i Command\ Line\ Tools\ for\ Xcode-$xcodeLatestVer
	/usr/bin/sudo xcode-select --switch /Library/Developer/CommandLineTools
	printf "\nXcode info:\n$(pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | sed 's/^/\t\t/')\n"
}

if [[ -d "/Library/Developer/CommandLineTools" ]]; then
	printf "\nXCode command line tools version $xcodeVer present."
	if echo $xcodeVer $xcodeLatestVer | awk '{exit !( $1 < $2)}'; then
		printf "\nXcode is outdate, updating Xcode version $xcodeVer to $xcodeLatestVer\n"
		rm -r /Library/Developer/CommandLineTools
		xcodeInstall
	else
		printf "\nxcode is up to date.\n"
	fi
else
	printf "\nXCode command line tools not present.\n"
	xcodeInstall
fi