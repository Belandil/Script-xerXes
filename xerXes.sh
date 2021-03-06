#!/usr/bin/bash
#*******************************************************************************|
# Project           : Vulnhub VM scanner					|
# Program name      : xerXes.sh 						|
# Author            : Belandil							|
# Date created      : 20190509							|	
# Purpose           : Scans differents services on the definned target 		|
#			whith its IP and Machine Name in parameter. 		|
#		     Prepare priv-Esc thanks to OS vulnerability search 	|
# 										|
# Revision History  :								|
# Date        	Author      	Ref	Details info				|
# 20190509    	Belandil   	1 	First part is reliable :		|
#					- Nmap + Searchsploit OS + Kernel	|
#  					- Gobuster depending on nmap services  	|
# 20200705	Belandil	2	- Improvment searchsploit		|
#		 								|
#										|									|
#*******************************************************************************|
set -euo pipefail

echo -e "\n ##################################################### DISCLAIMER ################################################ "
echo -e "\n I AM NOT RESPONSIBLE ABOUT WHAT YOU DO WITH THIS SCRIPT."
echo -e "\n THIS SCRIPT IS MADE FOR AUDITORS / PENTESTERS IN ORDER TO SAVE TIME BEFORE ADVANCED STEPS DURING PENTETRATION TESTS."
echo -e "\n BY USING THIS SCRIPT YOU UNDERSTAND AND ARE RESPONSIBLE OF THE CONSEQUENCES."
echo -e "\n ####################################################################################################################"

IFS=$'\n\t'
ip=${1:-}
machineName="${2:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
ENDCOLOR='\e[0m'

if [ -n "$1" ] && [ -n "$2" ]; then
	echo -e "${GREEN} ... ${ENDCOLOR}"
else
	echo -e "${RED}Variables seems to NOT be seted, Script will going wrong ${ENDCOLOR}"
	exit 1
fi

pathName=~/Desktop/vm-vulnhub/"${machineName}"
mkdir -p "${pathName}"
echo "Variables Created"
a=$( touch "${pathName}"/info"${machineName}".txt )
b=$( touch "${pathName}"/flaw"${machineName}".txt )
c=$( touch "${pathName}"/gobuster"${machineName}".txt )
d=$( touch "${pathName}"/nmap"${machineName}".txt )
#echo ""${GREEN}"Empty files Created in the following path : "${pathName}"/ ; suffixed by : "${machineName}" "${ENDCOLOR}""
ls -altr "${pathName}"

########################
### NMAP AREA Starts
########################

echo "****nmap starting********"
nmap -A -T5 -v -p- -sS "${ip}" 1> "${pathName}"/nmap"${machineName}".txt
ls -al "${pathName}"/nmap"${machineName}".txt
echo "****nmap Finished*******"
echo -e "\n\nYour new Nmap File TCP :"
ls -al "${pathName}"/nmap"${machineName}".txt
echo -e "\n"

###########################
### NMAP AREA Finished
###########################

### Comment for next line : grep lines becoming by P || O || U || 0-9|| _ || | then sed OS CPE + Uptime until last line (useless lines) + replace random spaces between words by 1 space 
egrep '^[POU]|^[0-9]|^\||^\_' "$pathName"/nmap"${machineName}".txt | sed '/OS CPE:/d; /Uptime guess:/,$d' | sed -e "s/[[:space:]]\+/ /g" > "${pathName}"/flaw"${machineName}".txt
cat "${pathName}"/flaw"${machineName}".txt

################################
### Searchsploit AREA Starts
################################

OS_VERSION=$( egrep '^OS details:' "${pathName}"/flaw"${machineName}".txt | cut -d ' ' -f 3-4 ) # get the Os and its version in the same variable
VERSION=$( echo "${OS_VERSION}" | cut -d ' ' -f 2 ) # get the OS's version
OS=$( echo "${OS_VERSION}" | cut -d ' ' -f 1 ) # get the OS only
echo "Searchsploit the OS "${OS}" with the VERSION: "${OS_VERSION}""

searchsploit -e "${VERSION}" | grep "${OS}" >  "${pathName}"/vulnerabilities_"${machineName}".txt

serverHeader=$(grep -E 'http-server-header:' "${pathName}"/flaw"${machineName}".txt | cut -d ' ' -f 2 | sed -e 's/\// /g' | sort -u) # get server Headers
echo "Searchsploit with the server(s) Header(s):" "${serverHeader}"
serverHeaderLines=$(grep -E 'http-server-header:' "${pathName}"/flaw"${machineName}".txt | cut -d ' ' -f 2 | sed -e 's/\// /g' | sort -u | wc -l)
echo "serverHeaderLines=$(grep -E 'http-server-header:' "${pathName}"/flaw"${machineName}".txt | cut -d ' ' -f 2 | sed -e 's/\// /g' | sort -u | wc -l)" # get nmumber og server lines ex : Apache + IIS

i=1
while [ "$i" -le "$serverHeaderLines" ]; do

	echo " This is while incrementation value i : $i"
	serverHeaderLineShift=$(grep -E 'http-server-header:' "${pathName}"/flaw"${machineName}".txt | cut -d ' ' -f 2 | sed -e 's/\// /g' ) # get whole server line + its version
	echo "${serverHeaderLineShift}"
	serverHeader_Name=$( echo "${serverHeaderLineShift}" | cut -d ' ' -f 1 ) # get server name only ex : Apache
	serverHeader_Version=$( echo "${serverHeaderLineShift}" | cut -d ' ' -f 2 ) # get server version with all digits ex : 2.2.8
	serverHeader=$( echo $serverHeader_Version | cut -d "." -f 1-2 ) # search with 2 major versions ex : 2.2

	if [ -n "${serverHeaderLineShift}" ]; then
		echo -e "\n *********** Server "${serverHeader_Name}" Vulnerabilities ***********" >>  "${pathName}"/vulnerabilities_"${machineName}".txt
		echo "test"
		set +e # force to run searchsploit whatever happens
		searchsploit -e "${serverHeader_Version}" | grep "${serverHeader_Name}" >> "${pathName}"/vulnerabilities_"${machineName}".txt
		set -e
		echo "searchsploit -e "${serverHeader_Version}" | grep "${serverHeader_Name}" >> "${pathName}"/vulnerabilities_"${machineName}".txt"
		i=$(($i+1))
	else
		echo -e "\n end of Loop"
	fi
done
i=0

#################################
### Searchsploit AREA Finished
#################################

################################
### Search directories with 
### Gobuster on ports found.
################################

numberLines=$(grep -E 'open http|open ssl/http' "${pathName}"/flaw"${machineName}".txt  | cut -d "/" -f 1 | wc -l)
echo "This is numberLines: "${numberLines}""
webPortsOpen=$(grep -E 'open http|open ssl/http' "${pathName}"/flaw"${machineName}".txt  | cut -d "/" -f 1 | tr '\n' ' ')
echo -e "return value: $? webPortsOpen value : "${webPortsOpen}" numberLines value: "${numberLines}""

echo -e "\nThis is webPortsOpen: ""${webPortsOpen}"
echo -e "\n\nThis is number of http|open Lines : "${numberLines}" ; This is webPortsOpen: "${webPortsOpen}" and this is retrurn $?"

echo "${pathName}"/flaw"${machineName}".txt

i=1 #used for browse each http services lines in flaw file
j=1 #used for grab each directories lines in the following file : "$pathName"/gobuster"$machineName"-port"$q".txt
########### grabing HTTP or HTTPS services and checks directories
while [ "$i" -le "$numberLines" ]; do
	q=$(grep -E 'open http|open ssl/http' "${pathName}"/flaw"${machineName}".txt | cut -d "/" -f 1 | head -n "$i" | tail -n1)
	singleWebPort=$(echo This is q: "$q")
	echo "Single port is : "${singleWebPort}""
	echo  "Trying on : http://$ip:$q"
	gobuster dir -u "http://$ip:$q" -w /usr/share/dirbuster/wordlists/directory-list-2.3-small.txt > "${pathName}"/gobuster"${machineName}".txt
	echo -e "\v\v" >> "${pathName}"/gobuster"${machineName}".txt #This is used to carriage return after each gobuster enumeration
	awk 'BEGIN{RS=ORS="\n\n";FS=OFS="\n"}/'$ip:$q'/' "$pathName"/gobuster"${machineName}".txt | grep -E '^/' | sort -k 3,3 >> "${pathName}"/gobuster"${machineName}"-port"$q".txt # This line will write in file all URL repositories found in gobuster's scan, sort by code status
	directroriesTotalLines=$(awk 'BEGIN{RS=ORS="\n\n";FS=OFS="\n"}/'$ip:$q'/' "${pathName}"/gobuster"${machineName}".txt | grep -E '^/' | sort -k 3,3 | wc -l) #same line than upward, returns number of lines
	echo -e "\n number of directories lines: $directroriesTotalLines"
	
	echo -e "\n These are directroriesTotalLines : $directroriesTotalLines and this is j : $j"
	
	while [ "$j" -le "$directroriesTotalLines" ]; do
		getLines=$(grep -E '^/' "${pathName}"/gobuster"${machineName}"-port"$q".txt | sort -k 3,3 | awk '{print $1}' | head -n "$j" | tail -n 1) #browse inside directories file and get each lines depending on j value
		echo -e "\n The value of getLines is : "${getLines}""
		sleep 2s
		firefox -new-tab "http://$ip:$q$getLines"&
		j=$[$j+1]
		echo "New tab opened : http://$ip:$q"${getLines}""
	done
	i=$[$i+1]
done
i=0 # reset i for other incrementation
cat "${pathName}"/gobuster"${machineName}".txt

################################
### Gobuster AREA Finished 
################################


###################################
### Looking for CMS or template (part in construction)
###################################

###########Gobuster is finished, now check if there is a wordpress from Gobuster's results ########### 
#portsGobuster=$(grep Url/Domain "$pathName"/gobuster"$machineName".txt | cut -d ':' -f 4 | cut -d '/' -f 1 | sort -u)
#portGobusterLines=$(grep Url/Domain "$pathName"/gobuster"$machineName".txt | cut -d ':' -f 4 | cut -d '/' -f 1 | sort -u | wc -l)

