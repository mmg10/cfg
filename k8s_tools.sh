#!/bin/bash


echo "#########################################"
echo "Installing kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm -f kubectl

echo "#########################################"
echo "Installing k9s"
wget -q https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz
tar -xzf k9s_Linux_amd64.tar.gz --anchored k9s && rm -f k9s_Linux_amd64.tar.gz
sudo mv k9s /usr/local/bin/k9s
sudo chmod 777 /usr/local/bin/k9s

echo "#########################################"
echo "Installing helm"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm -f get_helm.sh


