# Author: Miguel Morgado
# Date Created: 2023-06-27
# Date Modified: 2023-06-29
# Description: Bash script to ping the porkbun API and the current A record. Updates A record as needed.
# Usage: Make script executable: "chmod +x porkbun-dyndns.sh"; Execute script: "./porkbun-dyndns.sh"
#!/bin/bash
#
# Timestamp variable
TIMESTAMP=$(date +%Y-%m-%d-%H:%M:%S)
# Porkbun API
PORKBUN_API='https://porkbun.com/api/json/v3'
#
# define functions
# 01. Ping API
ping_api()
{
  IP=$(curl -s -S -X POST -H "Content-Type: application/json" -d \
       @porkbun_api.json $PORKBUN_API/ping | jq -r .yourIp)
  echo $TIMESTAMP - "Current IP Address:" $IP
}
# 02. Get current A record
get_record()
{
  PORKBUN_RECORD=$(curl -s -S -X POST -H "Content-Type: application/json" -d @porkbun_api.json $PORKBUN_API/dns/retrieve/<DOMAIN>/<DOMAIN_ID> | jq -r .records | grep content | tr -d '",' | awk '{print $2}')
  echo $TIMESTAMP - "Current A Record:" $PORKBUN_RECORD
}
# 03. Compare IP with PORKBUN_RECORD, Update A record if they do not match
compare_ip()
{
  PORKBUN=$(echo "$IP" | grep -q "$PORKBUN_RECORD" && echo "1" || echo "0")
  if [ $PORKBUN -eq  1 ]; then
    echo $TIMESTAMP - "IP Address is current, no update needed at this time." ; exit 0
  else
    echo $TIMESTAMP - "Updating IP Address..." ; sed -i "s/$PORKBUN_RECORD/$IP/g" porkbun_update.json
    PORKBUN_UPDATE=$(curl -s -S -X POST -H "Content-Type: application/json" -d \
                           @porkbun_update.json $PORKBUN_API/dns/edit/<DOMAIN>/<DOMAIN_ID> \
                           | jq -r .status)
    if [ $PORKBUN_UPDATE = SUCCESS ]; then
      echo $TIMESTAMP - "Record Update Status:" $PORKBUN_UPDATE ; exit 0
    else
      echo $TIMESTAMP - "Record Update Status:" $PORKBUN_UPDATE ; exit 1
    fi
  fi
}
# main
while : ; do
  ping_api
  get_record $@
  compare_ip $@
done
