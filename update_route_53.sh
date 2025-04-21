#!/bin/bash

DOMAIN_NAME="aws.cts.care."
EC2_MACHINE="ansible-Levi"
TAG_NAME="Name"
SUB_DOMAIN_PREFIX="levi"

TOKEN=$(curl -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 3600" http://169.254.169.254/latest/api/token)
echo $TOKEN
curl http://169.254.169.254/latest/meta-data -H "X-aws-ec2-metadata-token: $TOKEN"
IP_PUBLIC=$(curl http://169.254.169.254/latest/meta-data/public-ipv4 -H "X-aws-ec2-metadata-token: $TOKEN")
echo $IP_PUBLIC

ROUTE53_MAIN_DOMAIN_ID="/hostedzone/Z1015433RZV9CXS5NKKV"

FULL_DOMAIN="${SUB_DOMAIN_PREFIX}.${DOMAIN_NAME}"

CURRENT_ROUTE53_IP=$(aws route53 list-resource-record-sets --hosted-zone-id "$ROUTE53_MAIN_DOMAIN_ID" \
  | jq -r --arg name "$FULL_DOMAIN" '.ResourceRecordSets[] | select(.Name==$name) | .ResourceRecords[].Value')


if [[ "$IP_PUBLIC" != "$CURRENT_ROUTE53_IP" && -n "$IP_PUBLIC" ]]; then
  aws route53 change-resource-record-sets --hosted-zone-id "$ROUTE53_MAIN_DOMAIN_ID" --change-batch "$(
    cat <<EOF
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${FULL_DOMAIN}",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "$IP_PUBLIC"
          }
        ]
      }
    }
  ]
}
EOF
  )"
else
  echo "No update needed."
fi
