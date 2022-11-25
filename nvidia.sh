sudo apt-get install linux-headers-$(uname -r)
distribution=$(. /etc/os-release;echo $ID$VERSION_ID | sed -e 's/\.//g')
wget https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/cuda-keyring_1.0-1_all.deb
sudo dpkg -i cuda-keyring_1.0-1_all.deb
sudo apt-get update
sudo apt-get -y install cuda-drivers
echo 'PATH=/usr/local/cuda-11.8/bin${PATH:+:$PATH}' >> ~/.profile
echo 'LD_LIBRARY_PATH=/usr/local/cuda-11.8/lib64\${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}' >> ~/.profile
print after reboot, run \"cat /proc/driver/nvidia/version\"
source ~/.profile
