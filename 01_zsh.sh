cd /home/ubuntu

# installing tmux plugin manager
wget -q https://github.com/tmux-plugins/tpm/archive/refs/heads/master.zip
unzip -q master.zip
rm -rf master.zip 
mkdir -p /home/ubuntu/.tmux/plugins/
mv tpm-master /home/ubuntu/.tmux/plugins/tpm

# installing tmux-yank
#wget https://github.com/tmux-plugins/tmux-yank/archive/refs/heads/master.zip
#unzip -q master.zip
#rm -rf master.zip
#mv tmux-yank-master /home/ubuntu/.tmux/plugins/tmux-yank
"$HOME"/.tmux/plugins/tpm/bin/install_plugins || true

# installing oh-my-zsh
#wget -q https://github.com/ohmyzsh/ohmyzsh/archive/refs/heads/master.zip
#unzip -q master.zip
#rm -rf master.zip
#mv ohmyzsh-master /home/ubuntu/.oh-my-zsh
wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh
bash install.sh


# installing zsh-syntax-highlighting
wget -q https://github.com/zsh-users/zsh-syntax-highlighting/archive/refs/heads/master.zip
unzip -q master.zip
rm -rf master.zip 
mv zsh-syntax-highlighting-master /home/ubuntu/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# installing zsh-autosuggestions
wget -q https://github.com/zsh-users/zsh-autosuggestions/archive/refs/heads/master.zip
unzip -q master.zip
rm -rf master.zip 
mv zsh-autosuggestions-master /home/ubuntu/.oh-my-zsh/custom/plugins/zsh-autosuggestions


wget https://raw.githubusercontent.com/mmg10/cfg/main/.zshrc -O /home/ubuntu/.zshrc
wget https://raw.githubusercontent.com/mmg10/cfg/main/tmux.conf -O /home/ubuntu/.tmux.conf
wget https://raw.githubusercontent.com/mmg10/cfg/main/gmay_mine.omp-ec2.json -O /home/ubuntu/.oh-my-zsh/gmay_mine.omp.json

machine_architecture=$(uname -m)
if [ "$machine_architecture" == "x86_64" ]; then
    echo "x86_64"
    sudo curl -fsSL  "https://proxy.downloadapi.workers.dev/api/download?url=https%3A%2F%2Fgithub.com%2FJanDeDobbeleer%2Foh-my-posh%2Freleases%2Flatest%2Fdownload%2Fposh-linux-amd64" -o /usr/bin/oh-my-posh
    wget https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -O awscliv2.zip
else
    echo "aarch64"
    sudo curl -fsSL  "https://proxy.downloadapi.workers.dev/api/download?url=https%3A%2F%2Fgithub.com%2FJanDeDobbeleer%2Foh-my-posh%2Freleases%2Flatest%2Fdownload%2Fposh-linux-arm64" -o /usr/bin/oh-my-posh
    wget https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip -O awscliv2.zip
fi
unzip -qq awscliv2.zip
rm -rf awscliv2.zip
sudo ./aws/install -i /usr/bin/awscli
rm -rf aws
sudo chmod +x /usr/bin/oh-my-posh


sudo chsh -s /bin/zsh ubuntu
git config --global user.name -
git config --global user.email -
git config --global init.defaultBranch main
#mkdir ~/workefs
#echo "fs-08b7a28281079c1bb.efs.us-west-2.amazonaws.com:/ /home/ubuntu/workefs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" | sudo tee -a /etc/fstab
#sudo mount -a
sudo ln -s /usr/bin/python3 /usr/bin/python
aws s3 cp s3://ec2s/files/ . --recursive
bash setup.sh
sudo chmod 400 ~/.ssh/id_ed25519_mmgxa
sudo chmod 400 ~/.ssh/id_ed25519_mmg10
rm -rf setup.sh id_ed25519_mmgxa id_ed25519_mmg10
