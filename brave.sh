sudo apt install -y curl
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install -y brave-browser
#sudo sed -i 's:/usr/bin/brave-browser-stable %U:/usr/bin/brave-browser-stable --incognito %U:g' /usr/share/applications/brave-browser.desktop
#cp /usr/share/applications/brave-browser.desktop /home/ubuntu/Desktop/brave-browser.desktop
