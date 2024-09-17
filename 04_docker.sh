if ! command -v docker &> /dev/null
then
    echo "installing docker"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
    exit
else
    echo "docker already installed!"
    exit
fi
if nvidia-smi; then
  echo "GPU present!"
  sudo nvidia-ctk runtime configure --runtime=docker && sudo systemctl restart docker
else
  echo "No GPU present!"
fi

