#!/bin/bash

echo "#########################################"
echo "Installing minikube"
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm -f minikube-linux-amd64
if ! command -v 'sudo nvidia-smi' &> /dev/null
then
    sudo nvidia-ctk runtime configure --runtime=docker && sudo systemctl restart docker
fi

echo "#########################################"
echo "Installing kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm -f kubectl

echo "#########################################"
echo "Installing k9s"
release=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | jq -r '.tag_name')
wget -q https://github.com/derailed/k9s/releases/download/$release/k9s_Linux_amd64.tar.gz
tar -xzf k9s_Linux_amd64.tar.gz --anchored k9s && rm -f k9s_Linux_amd64.tar.gz
sudo mv k9s /usr/local/bin/k9s
sudo chmod 777 /usr/local/bin/k9s

echo "#########################################"
echo "Installing helm"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm -f get_helm.sh


echo "to start minikube, execute:"
if ! command -v 'sudo nvidia-smi' &> /dev/null
then
    echo "minikube start --driver docker --container-runtime docker --gpus all --memory 28672 --cpus 7 --disk-size 50g"
else
    echo "minikube start --driver=docker --memory 28672 --cpus 8 --disk-size 30g"
fi


