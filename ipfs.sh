machine_architecture=$(uname -m)
if [ "$machine_architecture" == "x86_64" ]; then
    wget https://dist.ipfs.io/go-ipfs/v0.20.0/go-ipfs_v0.20.0_linux-amd64.tar.gz
    tar xfz go-ipfs_v0.20.0_linux-amd64.tar.gz
    rm -rf go-ipfs_v0.20.0_linux-amd64.tar.gz
else
    wget https://dist.ipfs.io/go-ipfs/v0.20.0/go-ipfs_v0.20.0_linux-arm64.tar.gz
    tar xfz go-ipfs_v0.20.0_linux-arm64.tar.gz
    rm -rf go-ipfs_v0.20.0_linux-arm64.tar.gz
fi
sudo ./go-ipfs/install.sh
ipfs version
echo 'export IPFS_PATH=/home/ubuntu/.ipfs' >> ~/.profile
source ~/.profile
ipfs init --profile server

ipfs config Datastore.StorageMax 80GB
ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/8080
sudo tee -a /lib/systemd/system/ipfs.service >/dev/null <<-EOF
[Unit]
Description=ipfs daemon
[Service]
ExecStart=/usr/local/bin/ipfs daemon --enable-gc
Restart=always
User=ubuntu
Group=ubuntu
Environment="IPFS_PATH=/home/ubuntu/.ipfs"
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable ipfs.service
sudo systemctl start ipfs
sudo systemctl status ipfs
