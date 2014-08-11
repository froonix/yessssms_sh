#!/bin/bash
# Fill out your Yesss Number and password.
# Send SMS from your prepaid SIM via the web.
# $ ./yessssms.sh 0043681123456789 "your messsage in quotes"
# that's it

# NOTE: this script does NOT validate your balance.
# last tested on: 2014-08-11

yesss_number="0681XXXXXXXXXX"
yesss_pw="YOUR_SECRET_YESSS_WEBLOGIN"

UA="Mozilla/5.0 (Windows; U; Windows NT 6.1; de; rv:1.9.1.4) Gecko/20091017 SeaMonkey/2.0"
KMURL="https://www.yesss.at/kontomanager.at/kundendaten.php"
mess=`echo "$2" | cut -b -160`
num=$1
RES1=`curl -s -i -A "$UA" -d "login_rufnummer=$yesss_number&login_passwort=$yesss_pw" https://www.yesss.at/kontomanager.at/index.php`
SESSID=`echo $RES1 | grep Set-Cookie | grep PHPSESSID | sed 's/.*\(PHPSESSID=.*\);.*/\1/g'`
BAL=`curl -s -A "$UA" -b "$SESSID" $KMURL | grep -A 2 -i Guthaben |  grep -i EUR | sed 's/.*\(EUR [0-9]*,[0-9]*\).*/\1/g'` 

if [ $? -gt 0 ]; then
  echo "error logging in"
  exit -1;
fi
#echo "session ID: $SESSID"
echo "balance: $BAL"
sleep 1 # a chance to abort!

if ! test -z $1; then
  test -z $2 && echo "$0 <number with 0043650...> \"message in quotes\"" && exit -4

  echo "sending SMS:"
  echo "number: $num"
  echo "message: $mess"

  curl -s -A "$UA" -b "$SESSID" -o /dev/null -d "to_nummer=$num&nachricht=$mess" https://www.yesss.at/kontomanager.at/websms_send.php
  if [ $? -gt 0 ]; then
    echo "error sending message"
    exit -2;
  fi
  sleep 4 # wait a little before logging out
fi
#echo "logging out"
curl -s -o /dev/null -A "$UA" -b "$SESSID" https://www.yesss.at/kontomanager.at/index.php?dologout=2
if [ $? -gt 0 ]; then
  echo "error logging out"
  exit -3;
fi
