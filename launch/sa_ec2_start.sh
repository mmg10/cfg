REGION=sa-east-1

INSTANCE_ID=$(aws ec2 run-instances --region $REGION --image-id 'ami-05401e1394491333f' --instance-type 't3a.medium' --key-name 'ec2c_se1' --block-device-mappings '{"DeviceName":"/dev/sda1","Ebs":{"Encrypted":false,"DeleteOnTermination":true,"Iops":3000,"SnapshotId":"snap-061cb22ed3d5124fa","VolumeSize":8,"VolumeType":"gp3","Throughput":125}}' --security-group-ids 'sg-09d47553d5f9b7c8c' --iam-instance-profile '{"Arn":"arn:aws:iam::350104937619:instance-profile/EC2-Role-S3+ECR"}' --metadata-options '{"HttpEndpoint":"enabled","HttpPutResponseHopLimit":2,"HttpTokens":"required"}' --count '1' --query 'Instances[0].InstanceId' --output text --user-data  file://gui.sh)

echo "Instance has ID: $INSTANCE_ID"

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
