# DISCLAIMER

I AM NOT RESPONSIBLE ABOUT WHAT YOU DO WITH THIS SCRIPT.

THIS SCRIPT IS MADE FOR AUDITORS / PENTESTERS IN ORDER TO SAVE TIME BEFORE ADVANCED STEPS DURING PENTETRATION TESTS.

BY USING THIS SCRIPT YOU UNDERSTAND AND ARE RESPONSIBLE OF THE CONSEQUENCES IF THINGS GOES WRONG.

# DESCRIPTION
Shortly : This script gives you the first picture of the machine that you want to analyse.

Thanks to nmap, xerXes.sh discovers services and their potentials weaknesses on a targeted machine with searchsploit. 

It enumerates for you directories on a web server and open in a Firefox browser directories found.

It creates local directory and stores reports inside. It is a script so that why reports are also supposed to be checked if some informations are missing.


By the way, if some cases of utilisation are missing, or working wired, please let me know.

I have lot of ideas to improve the script, but missing time by those time. 

Thanks to using it and have fun on CTF machines !
# Prior installation
This script is supposed to work on a Kali machine with its wordlists stored in :
      
      /usr/share/dirbuster/wordlists

need  following tools :

      gobuster installed
      
      nmap
      
      searchsploit
      
# USAGE
./xerXes.sh $ip $machineName

$ip is the IP address of the targeted machine

$machineName is the name of directories and files created for a good organisation of reports  

# Exemple
./xerXes.sh 10.0.0.10 vulnhubMachine-Kioptrix
