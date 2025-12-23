sudo apt-add-repository -y ppa:x2go/stable
sudo apt install -y icewm geany x2goserver x2goserver-xsession
sudo usermod --password $(echo 123 | openssl passwd -1 -stdin) ubuntu
#cp /usr/share/applications/mate-terminal.desktop /home/ubuntu/Desktop/mate-terminal.desktop
#cp /usr/share/applications/debian-xterm.desktop  /home/ubuntu/Desktop/debian-xterm.desktop
sudo timedatectl set-timezone Asia/Karachi
