#!/bin/bash
# shellcheck disable=SC2086,SC1090,SC2053
#
# Use nsupdate to send a dynamic DNS update to the host's DNS server
# in order to register the host's PTR and preferred A records.
######################################################################
PATH=/sbin:/usr/sbin:/bin:/usr/bin
PROGNAME="$(basename $0)"
DEBUG="${DEBUG:-0}"
DDNSBIN="${DDNSBIN:-/usr/bin/nsupdate}"
DDNSCONF="${DDNSCONF:-/etc/linux-ddns.conf}"
DDNSCMDF="/tmp/.ddns-updates.$(date '+%Y%m%d%H%M')"

##
## Set up an error-logging exit-routine
function err_exit {
   local ERRSTR="${1}"

   logger -s -t "${PROGNAME}" -p kern.crit "${ERRSTR}"

   exit 1
}

## Format PTR record-string
function MakePtr {
   local HOSTIP=($(
         ip addr show eth0 | \
         awk '/ inet /{ print $2 }' | \
         cut -d '/' -f 1
      ))
   HOSTPTR=$(
         echo "${HOSTIP[0]}" | \
         awk -F"." '{printf("%s.%s.%s.%s.in-addr-arpa",$4,$3,$2,$1)}' \
      )
}

## Make Host-IP and formatted PTR available to shell
MakePtr
HOSTNAM=$(hostname --fqdn)

## Read script's config file
source "${DDNSCONF}" || err_exit "Failed reading ${DDNSCONF}"

## Create and execute nsupdate command-document
if [[ -x ${DDNSBIN} ]]
then
   ## Create command-document
   (
     echo "update delete ${HOSTNAM} A"
     echo "update add ${HOSTNAM} ${DDNSTTL} A ${HOSTIP[0]}"
     for CNAME in "${HOSTNAME[@]}"
     do
	if [[ ${CNAME} != ${CNAME/\.*/} ]]
	then
           echo "update add ${CNAME} ${DDNSTTL} CNAME ${HOSTNAM}."
	fi
     done
     echo "update delete ${HOSTPTR} PTR"
     echo "update add ${HOSTPTR} ${DDNSTTL} PTR ${HOSTNAM}."
     echo "send"
    ) > "${DDNSCMDF}" || err_exit "Failed creating ${DDNSCMDF}"

    "${DDNSBIN}" "${DDNSCMDF}" || err_exit "Update request returned errors"
else
   err_exit "Cannot find an executable ${DDNSBIN}"
fi

## Clean up comman-file
rm "${DDNSCMDF}" || err_exit "Faile to clean up ${DDNSCMDF}"
