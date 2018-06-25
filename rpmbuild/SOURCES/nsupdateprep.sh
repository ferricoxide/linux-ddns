#!/bin/bash
#
# Script to ensure that $(hostname --fqdn) returns correctly
#
#################################################################
BASEIPADDR=$( /sbin/ip route show | head -1 sed 's/#/.*$##' )
SHORTNAME=$( hostname -s )
DOMNAME=$( hostname -d )

"# Make sure we know our domain-name
if [[ -z ${DOMNAME} ]]
then
   printf "Guessing domain from resolv.conf "
   DOMNAME=$( awk '/search/{ print $2 }' /etc/resolv.conf )
   echo "[${DOMNAME}]"
fi

# See if we're good to go...
if [[ $( hostname --fqdn > /dev/null 2>&1 )$? -eq 0 ]]
then
   echo '`hostname --fqdn` returns success.'
elif [[ $( grep -q ${BASEIPADDR} /etc/hosts )$? -eq 0 ]]
then
   if [[ $( grep -q ${SHORNAME}.${DOMNAME} /etc/hosts )$? -eq 0 ]]
   then
      echo "Hostname/IP-mapping already present in /etc/hosts"
   else
      printf "Found ${BASEIPADDR} in /etc/hosts: adding entry for "
      printf "${SHORNAME}.${DOMNAME} "
      sed -i '/'${BASEIPADDR}'/s/$/ ' '${SHORTNAME}'.'${DOMNAME}'/' /etc/hosts 
      if [[ $? -eq 0 ]]
      then
         echo "...Success!"
      else
         echo "...Failed!"
	 exit 1
      fi
   fi
else
   printf "Adding host/IP binding ${BASEIPADDR} ${SHORTNAME}.${DOMNAME} "
   printf "to /etc/hosts "
   printf "%s\t%s.%s\n" "${BASEIPADDR}" "${SHORTNAME}" "${DOMNAME}" |
     >> /etc/hosts
   if [[ $? -eq 0 ]]
   then
      echo "...Success!"
   else
      echo "...Failed!"
	 exit 1
   fi
fi
