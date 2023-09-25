sudo df -h
lsblk
sudo mkfs -t xfs /dev/nvme1n1
sudo mkdir /data
sudo mount /dev/nvme1n1 /data
sudo chown ubuntu /data
sudo cp -r /var/lib/docker/ /data/
sudo chown -R ubuntu /data
sudo rm -rf /var/lib/docker
sudo ln -s /data/docker /var/lib/docker
sudo service docker restart
