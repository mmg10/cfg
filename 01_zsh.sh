cd /home/ubuntu

# installing tmux-yank
wget https://github.com/tmux-plugins/tmux-yank/archive/refs/heads/master.zip
unzip -q master.zip
rm -rf master.zip
mkdir -p /home/ubuntu/.tmux/plugins/
mv tmux-yank-master /home/ubuntu/.tmux/plugins/tmux-yank
#"$HOME"/.tmux/plugins/tpm/bin/install_plugins || true

# installing tmux-better mouse mode
wget https://github.com/NHDaly/tmux-better-mouse-mode/archive/refs/heads/master.zip
unzip -q master.zip
rm -rf master.zip
mv tmux-better-mouse-mode-master /home/ubuntu/.tmux/plugins/tmux-better-mouse-mode

# installing oh-my-zsh
wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh
bash install.sh
rm -rf install.sh

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


wget https://raw.githubusercontent.com/mmg10/cfg/main/tmux.conf -O /home/ubuntu/.tmux.conf
wget https://raw.githubusercontent.com/mmg10/cfg/main/gmay_mine.omp-ec2.json -O /home/ubuntu/.oh-my-zsh/gmay_mine.omp.json
wget https://raw.githubusercontent.com/mmg10/cfg/main/yt-dlp.conf -O /home/ubuntu/yt-dlp.conf

machine_architecture=$(uname -m)
if [ "$machine_architecture" == "x86_64" ]; then
    echo "x86_64"
    sudo curl -fSLsS  "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64" -o /usr/bin/oh-my-posh
    wget -nv https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -O awscliv2.zip
else
    echo "aarch64"
    sudo curl -fSLsS  "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-arm64" -o /usr/bin/oh-my-posh
    wget -nv https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip -O awscliv2.zip
fi
unzip -qq awscliv2.zip
rm -rf awscliv2.zip
sudo ./aws/install -i /usr/bin/awscli
rm -rf aws
sudo chmod +x /usr/bin/oh-my-posh

sudo curl -fSLsS https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
sudo chmod a+rx /usr/local/bin/yt-dlp

sudo chsh -s /bin/zsh ubuntu
git config --global user.name -
git config --global user.email -
git config --global init.defaultBranch main
git config --global pager.log false
git config --global core.pager delta
#mkdir ~/workefs
#echo "fs-08b7a28281079c1bb.efs.us-west-2.amazonaws.com:/ /home/ubuntu/workefs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" | sudo tee -a /etc/fstab
#sudo mount -a
sudo ln -s /usr/bin/python3 /usr/bin/python
aws s3 cp s3://ec2s/files/ . --recursive
bash setup.sh
sudo chmod 400 ~/.ssh/id_rsa1
sudo chmod 400 ~/.ssh/id_rsa2
mv .zshrc /home/ubuntu/.zshrc
rm -rf setup.sh
