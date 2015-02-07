#!/usr/bin/env bash
# Version: 0.0.5
# Author: Szymon Błaszczyński <simone@neosb.net>

# This script simply helps you to update your ip on noip.com server
# After this your host can be resolved by human-readble dns name like example.ddns.net
# For further information please refer to www.noip.com

# To fully use this, put it in cron directory of your choice (maybe cron.daily)
# make it executable, and you're good to go.

# Please change this to reflect your credentials
USER=username
PASSWD=password
HOST=your.ddns.net

TIMEOUT=3 # Switch to another ip service after TIMEOUT seconds

# Don't change this
COUNTER=0
declare -a IPSEEK

# Array of services allowing you to resolve your external ip in simple curl
# You can add new, but the format it accepts is "x.x.x.x" without quotation
# Example output of curl icanhazip.com is 1.2.3.4
IPSEEK=(icanhazip.com curlmyip.com l2.io/ip ip.appspot.com eth0.me myexternalip/raw ifconfig.co ifconfig.me/ip)

# This is the program
function main() {
  # Exit when no more services to check
  if (( $COUNTER>=${#IPSEEK[@]} )) ; then
    echo "Couldn't resolve your external ip address, exiting..."
    exit 1
  fi
  # Get you external ip
  MYIP=$(curl --silent --max-time $TIMEOUT ${IPSEEK[$COUNTER]}) && SUCCESS=1
  # Update noip database
  if [ SUCCESS==1 ] ; then
    RESULT=$(curl --silent --user-agent "neosb update script/0.0.5 simone@neosb.net" \
      https://$USER:$PASSWD@dynupdate.no-ip.com/nic/update?hostname=$HOST&myip=$MYIP)
    OUTPUT="noip.com update result: $RESULT"
    logger $OUTPUT && echo $OUTPUT
  # If something went wrong, repeat
  else
    COUNTER=$((COUNTER+1))
    main
  fi
}

# Start a program
main

