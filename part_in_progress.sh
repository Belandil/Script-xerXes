<< Comment
i=1
while [ "$i" -le "$portGobusterLines" ]; do
	echo " This is i : $i"
	portGobusterLineShift=$(grep Url/Domain "$pathName"/gobuster"$machineName".txt | cut -d ':' -f 4 | cut -d '/' -f 1 | sort -u | sed -n "$i"p)
	echo "portGobusterLineShift : $portGobusterLineShift"
	sleep 5s
	if [ -n serverHeaderLineShift ]; then
		echo "if loop $portGobusterLineShift"
		i=$[$i+1]
	else
		echo " NUUUUUUL"
	fi
done
i=0

Comment

#set +e # Needed bcause grep could not get a wp word
#grep -E 'wordpress|wp' "$pathName"/gobuster"$machineName"
#valueBackWP=$( echo "$?" )

#joom=$(grep Joomla nmapRTB2_autoXerxes.txt | cut -d ' ' -f 2-3)
#valueBackJOOMLA=$( echo "$?" )
#searchsploit -e $joom
#set -e
#echo "$valueBack"
#

#if [ "$valueBack" -ge "1" ]; then
#	echo -e "There is no worpress or wp folder, grep error : ${valueBack}"
#elif [ "$valueBack" -eq "0" ]; then
#	echo -e "There is a wordpress or wp directory, grep returns : ${valueBack}"
#else 
#	echo -e "Fatal error grep returns error : ${valueBack}"
#fi
