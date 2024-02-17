#sudo mkfs -t ext4 /dev/nvme2n1
mkdir ~/sdd
echo "/dev/nvme2n1   /home/ubuntu/sdd  ext4   defaults,nofail   0   2" | sudo tee -a /etc/fstab
sudo mount -a
#sudo chown ubuntu -R ~/sdd
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
python -m pip install virtualenv --user
sudo ln -s ~/sdd/envs ~/envs
if [ ! -d ~/envs/default ]; then
    python -m venv ~/envs/default
fi
echo 'ven default' >> ~/.zshrc
sudo ln -s ~/sdd ~/.cache/huggingface
