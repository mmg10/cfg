sudo apt-get install git zsh -y
curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
sudo curl -fsSL  https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -o /usr/bin/oh-my-posh
sudo chmod +x /usr/bin/oh-my-posh
wget https://raw.githubusercontent.com/mmg10/cfg/main/zshrc -O ~/.zshrc
wget https://raw.githubusercontent.com/mmg10/cfg/main/gmay_mine.omp-ec2.json -O ~/.oh-my-zsh/gmay_mine.omp.json
sudo chsh -s $(which zsh)
