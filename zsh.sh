sudo apt update
sudo apt install git zsh unzip xclip xsel tmux nfs-common -y
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tmux-yank ~/.tmux/plugins/tmux-yank
cp tmux.conf ~/.tmux.conf
curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
machine_architecture=$(uname -m)
if [ "$machine_architecture" == "x86_64" ]; then
    sudo curl -fsSL  https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -o /usr/bin/oh-my-posh
    wget https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -O awscliv2.zip
    wget https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz
    tar -xf ffmpeg-master-latest-linux64-gpl.tar.xz
    sudo cp ffmpeg-master-latest-linux64-gpl/bin/* /usr/local/bin/
else
    sudo curl -fsSL  https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-arm64 -o /usr/bin/oh-my-posh
    wget https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip -O awscliv2.zip
    wget https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linuxarm64-gpl.tar.xz
    tar -xf ffmpeg-master-latest-linuxarm64-gpl.tar.xz
    sudo cp ffmpeg-master-latest-linuxarm64-gpl/bin/* /usr/local/bin/
fi
unzip -qq awscliv2.zip
sudo ./aws/install -i /usr/bin/awscli
sudo chmod +x /usr/bin/oh-my-posh
cp .zshrc ~/.zshrc
cp gmay_mine.omp-ec2.json ~/.oh-my-zsh/gmay_mine.omp.json
sudo chsh -s /bin/zsh ubuntu
mkdir ~/workefs
echo "fs-0d798ed3766aee010.efs.us-east-2.amazonaws.com:/ /home/ubuntu/workefs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" | sudo tee -a /etc/fstab
sudo mount -a
sudo ln -s /usr/bin/python3 /usr/bin/python
sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
sudo chmod a+rx /usr/local/bin/yt-dlp
cp yt-dlp.conf ~/yt-dlp.conf
