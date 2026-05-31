INSTANCE_IDS=$(aws ec2 run-instances --image-id 'ami-07a00cf47dbbc844c' --region ap-south-1 --instance-type 't3a.medium' --key-name 'ec2cs' --block-device-mappings '{"DeviceName":"/dev/sda1","Ebs":{"Encrypted":false,"DeleteOnTermination":true,"Iops":3000,"SnapshotId":"snap-0d3d6fc1e73ae46ae","VolumeSize":10,"VolumeType":"gp3","Throughput":125}}'  --network-interfaces '{"AssociatePublicIpAddress":true,"DeviceIndex":0,"Groups":["sg-03cdeb64818f226c5"]}' --credit-specification '{"CpuCredits":"unlimited"}' --iam-instance-profile '{"Arn":"arn:aws:iam::350104937619:instance-profile/EC2-Role-S3+ECR"}' --metadata-options '{"HttpEndpoint":"enabled","HttpPutResponseHopLimit":2,"HttpTokens":"required"}' --private-dns-name-options '{"HostnameType":"ip-name","EnableResourceNameDnsARecord":true,"EnableResourceNameDnsAAAARecord":false}'  --count '3' --query 'Instances[*].InstanceId' --output text --user-data  file://gui.sh)

# Convert to array
IFS=$'\t' read -r -a IDS_ARRAY <<< "$INSTANCE_IDS"
NUM_INSTANCES=${#IDS_ARRAY[@]}

# Wait for each instance and fetch public IPs
for i in "${!IDS_ARRAY[@]}"; do
  idx=$((i + 1))
  echo "Waiting for ec2c${idx} (${IDS_ARRAY[$i]})..."
  aws ec2 wait instance-running --instance-ids "${IDS_ARRAY[$i]}" --max-attempts 40

  PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids "${IDS_ARRAY[$i]}" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)
  echo "ec2c${idx} Public IP: $PUBLIC_IP"

  OLD_IP=$(grep -w "Host ec2c${idx}" -A 2 ~/.ssh/config | awk '/HostName/ {print $2}')
  if [[ -n "$OLD_IP" ]]; then
    sed -i "s/$OLD_IP/$PUBLIC_IP/g" ~/.ssh/config
    echo "Public IP updated for ec2c${idx} in SSH config!"
  else
    echo "Host ec2c${idx} not found in SSH config, skipping."
  fi
done
