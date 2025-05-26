#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-069a28d699aae9b90"
INSTANCES=("mongodb" "redis" "mySQL" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z03545723JPI3NUQJEQ82"
DOMAIN_NAME="adhikya.site"


for instance in ${INSTANCES[@]}
do 
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t2.micro --security-group-ids sg-069a28d699aae9b90 --tag-specifications "ResourceType=instance, 
    Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
    if [$instance != "frontend"]
    then 
         IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text) 
    fi
    echo "$instance IP address: $IP"   

    aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch     

    {
    "Comment": "Creating or Updating Route 53 DNS records",
    "Changes": [{
        "Action": "UPSERT",
        "ResourceRecordSet": {
            "Name": "'$instance'.'$DOMAIN_NAME'",
            "Type": "A",
            "TTL": 1
            "ResourceRecords": [{ "Value": "$IP" }]
        }
    }]
}                                 

done  