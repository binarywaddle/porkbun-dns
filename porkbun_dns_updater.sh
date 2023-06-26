# !/bin/sh
# 01. Ping API
export IP=$(curl -X POST -H "Content-Type: application/json" -d @porkbun_ping.json https://porkbun.com/api/json/v3/ping | jq -r .yourIp)

# 02. Get current IP in porkbun_update.json
export PORKBUN_IP=$(cat porkbun_update.json | grep content | tr -d '",' | awk '{print $2}')

# 03. Compare IP with PORKBUN_IP, Update A record if they do not match
export PORKBUN=$(echo "$IP" | grep -q "$PORKBUN_IP" && echo "true" || echo "false")
if [ $PORKBUN -eq  1 ]
then
  echo "IP Address is current"
else
  echo "Updating IP Address..."
  sed -i "s/$PORKBUN_IP/$IP/g" porkbun_update.json
  PORKBUN_UPDATE=$(curl -s -X POST -H "Content-Type: application/json" -d @porkbun_update.json -o porkbun_update.log https://porkbun.com/api/json/v3/dns/editByNameType/<DOMAIN>/<TYPE>/<SUBDOMAIN>)
