echo "removing conda..."
sudo rm -rf /opt/conda/
sudo rm -rf /usr/local/bin/conda
mkdir ~/workefs 
echo "fixing git..."
git config --global user.name -
git config --global user.email -
git config --global init.defaultBranch main
echo "Updating system..."
sudo apt update && sudo apt upgrade -y
echo "Installing utils..."
sudo apt-get install git zsh unzip xclip tmux nfs-common -y
wget https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -O awscliv2.zip
unzip -qq awscliv2.zip
sudo ./aws/install -i /usr/bin/awscli
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cp tmux.conf ~/.tmux.conf
curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
sudo curl -fsSL  https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -o /usr/bin/oh-my-posh
sudo chmod +x /usr/bin/oh-my-posh
cp .zshrc ~/.zshrc
cp gmay_mine.omp-ec2.json ~/.oh-my-zsh/gmay_mine.omp.json
sudo chsh -s /bin/zsh ubuntu
echo "Installing packages..."
sudo ln -s /usr/bin/python3 /usr/bin/python
sudo apt install python3.8-venv -y
python -m venv ~/envs/default
source ~/envs/default/bin/activate
pip install --no-cache-dir numpy pandas matplotlib seaborn jupyter scikit-learn rich optuna --upgrade
ipython kernel install --name default --user
if [[ "command -v nvidia-smi &> /dev/null" ]]
then
    echo "GPU Present!!!"
    pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
else
    echo "GPU Missing!!!"
    pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
fi
pip install --no-cache-dir torchtext
pip install --no-cache-dir tensorboard timm albumentations
pip install --no-cache-dir torchmetrics pytorch_lightning 
pip install --no-cache-dir huggingface datasets --upgrade
