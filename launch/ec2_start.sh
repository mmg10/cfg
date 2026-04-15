INSTANCE_ID=$(aws ec2 run-instances --image-id 'ami-0d76b909de1a0595d' --instance-type 't3a.large' --key-name 'ec2cs' --block-device-mappings '{"DeviceName":"/dev/sda1","Ebs":{"Encrypted":false,"DeleteOnTermination":true,"Iops":3000,"SnapshotId":"snap-04a0d85ca273ddf23","VolumeSize":20,"VolumeType":"gp3","Throughput":125}}' --launch-template '{"LaunchTemplateId":"lt-0be9274868c39c07e","Version":"4"}' --security-group-ids 'sg-02c25290b4a7ac0cc' --iam-instance-profile '{"Arn":"arn:aws:iam::350104937619:instance-profile/EC2-Role-S3+ECR"}' --metadata-options '{"HttpEndpoint":"enabled","HttpPutResponseHopLimit":2,"HttpTokens":"required"}' --count '1' --query 'Instances[0].InstanceId' --output text)

# Wait until instance is running
# Check if INSTANCE_ID is non-empty and not "None"
if [[ -n "$INSTANCE_ID" && "$INSTANCE_ID" != "None" ]]; then
  aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
else
  echo "Instance ID not found. Exiting."
  exit 1
fi


# Fetch public IP
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)
echo "Public IP: $PUBLIC_IP"
oldip=`grep -w "Host ec2c" -A 2 ~/.ssh/config | awk '/HostName/ {print $2}'`
sed -i "s/$oldip/$PUBLIC_IP/g" ~/.ssh/config
echo "Public IP updated in SSH COnfig!"
