sudo apt update
sudo apt install git zsh unzip xclip xsel tmux nfs-common -y
wget https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -O awscliv2.zip
unzip -qq awscliv2.zip
sudo ./aws/install -i /usr/bin/awscli
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tmux-yank ~/.tmux/plugins/tmux-yank
cp tmux.conf ~/.tmux.conf
curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
sudo curl -fsSL  https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -o /usr/bin/oh-my-posh
sudo chmod +x /usr/bin/oh-my-posh
cp .zshrc ~/.zshrc
cp gmay_mine.omp-ec2.json ~/.oh-my-zsh/gmay_mine.omp.json
sudo chsh -s /bin/zsh ubuntu
git config --global user.name -
git config --global user.email -
git config --global init.defaultBranch main
mkdir ~/workefs
echo "fs-08b7a28281079c1bb.efs.us-west-2.amazonaws.com:/ /home/ubuntu/workefs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" | sudo tee -a /etc/fstab
sudo mount -a
aws s3 cp s3://ec2s/files/ . --recursive
bash setup.sh
sudo chmod 400 ~/.ssh/id_ed25519_mmgxa
sudo chmod 400 ~/.ssh/id_ed25519_mmg10
sudo ln -s /usr/bin/python3 /usr/bin/python
if ! command -v conda &> /dev/null
then
    echo "conda could not be found"
    wget https://bootstrap.pypa.io/get-pip.py
    python get-pip.py
    sudo apt install python3.10-venv -y
    python -m pip install virtualenv --user
    python -m venv ~/envs/default
    echo 'ven default' >> ~/.zshrc
    exit
else
    echo "conda found"
    conda init zsh
    echo 'conda activate pytorch' >> ~/.zshrc
    exit
fi
