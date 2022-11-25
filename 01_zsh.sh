sudo apt-get install git zsh unzip -y
curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
sudo curl -fsSL  https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -o /usr/bin/oh-my-posh
sudo chmod +x /usr/bin/oh-my-posh
cp .zshrc ~/.zshrc
cp gmay_mine.omp-ec2.json ~/.oh-my-zsh/gmay_mine.omp.json
