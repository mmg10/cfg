for USERDATA in cpu-gnome.sh cpu-icewm.sh; do
    INSTANCE_ID=$(aws ec2 run-instances --image-id 'ami-0d76b909de1a0595d' --instance-type 't3a.large' --key-name 'ec2cs' --block-device-mappings '{"DeviceName":"/dev/sda1","Ebs":{"Encrypted":false,"DeleteOnTermination":true,"Iops":3000,"SnapshotId":"snap-04a0d85ca273ddf23","VolumeSize":15,"VolumeType":"gp3","Throughput":125}}' --launch-template '{"LaunchTemplateId":"lt-0be9274868c39c07e","Version":"3"}' --security-group-ids 'sg-02c25290b4a7ac0cc' --iam-instance-profile '{"Arn":"arn:aws:iam::350104937619:instance-profile/EC2-Role-S3+ECR"}' --metadata-options '{"HttpEndpoint":"enabled","HttpPutResponseHopLimit":2,"HttpTokens":"required"}' --count '1' --user-data "file://${USERDATA}" --query 'Instances[0].InstanceId' --output text)
    aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
    PUBLIC_IP=$(aws ec2 describe-instances \
      --instance-ids "$INSTANCE_ID" \
      --query 'Reservations[0].Instances[0].PublicIpAddress' \
      --output text)
    echo "$USERDATA Public IP: $PUBLIC_IP"
done
