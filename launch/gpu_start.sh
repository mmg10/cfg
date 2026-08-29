REGION=us-west-2

INSTANCE_ID=$(aws ec2 run-instances --image-id 'ami-09b010b33f6e301e8' --region $REGION --instance-type 'g4dn.xlarge' --key-name 'ec2cs' --network-interfaces '{"AssociatePublicIpAddress":true,"DeviceIndex":0,"Groups":["sg-02c25290b4a7ac0cc"]}' --iam-instance-profile '{"Arn":"arn:aws:iam::350104937619:instance-profile/EC2-Role-S3+ECR"}' --metadata-options '{"HttpEndpoint":"enabled","HttpPutResponseHopLimit":2,"HttpTokens":"required"}' --private-dns-name-options '{"HostnameType":"ip-name","EnableResourceNameDnsARecord":true,"EnableResourceNameDnsAAAARecord":false}' --count '1' --user-data  file://default.sh \
  --query 'Instances[0].InstanceId' \
  --output text)

# Wait until instance is running
# Check if INSTANCE_ID is non-empty and not "None"
if [[ -n "$INSTANCE_ID" && "$INSTANCE_ID" != "None" ]]; then
  aws ec2 wait instance-running --region $REGION --instance-ids "$INSTANCE_ID"
else
  echo "Instance ID not found. Exiting."
  exit 1
fi

# Fetch public IP
PUBLIC_IP=$(aws ec2 describe-instances \
  --region $REGION \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)
echo "Public IP: $PUBLIC_IP"

if [[ -n "$PUBLIC_IP" && "$PUBLIC_IP" != "None" ]]; then
    oldip=$(grep -w "Host ec2c" -A 2 ~/.ssh/config | awk '/HostName/ {print $2}')
    sed -i "s/$oldip/$PUBLIC_IP/g" ~/.ssh/config
    echo "Public IP updated in SSH config!"
else
    echo "Public IP is empty/None. SSH config was not modified."
fi
