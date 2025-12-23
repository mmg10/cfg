#!/bin/bash

echo "#########################################"
echo "Installing minikube"
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm -f minikube-linux-amd64
if command -v 'sudo nvidia-smi' &> /dev/null
then
    sudo nvidia-ctk runtime configure --runtime=docker && sudo systemctl restart docker
fi


echo "to start minikube, execute:"
if command -v 'sudo nvidia-smi' &> /dev/null
then
    echo "minikube start --driver docker --container-runtime docker --gpus all --memory 28672 --cpus 7 --disk-size 50g --addons=nvidia-device-plugin"
else
    echo "minikube start --driver=docker --memory 28672 --cpus 8 --disk-size 30g"
fi


