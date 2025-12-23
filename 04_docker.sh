if ! command -v docker &> /dev/null
then
    echo "installing docker"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
    rm -rf get-docker.sh
else
    echo "docker already installed!"
fi
if command -v nvidia-smi &> /dev/null; then
  echo "GPU present!"
  sudo nvidia-ctk runtime configure --runtime=docker && sudo systemctl restart docker
  sudo cp -r /var/lib/docker/ /opt/dlami/nvme

  # Ensure daemon.json exists
  sudo mkdir -p /etc/docker
  sudo touch /etc/docker/daemon.json

  # Safely merge: set .["data-root"]
  sudo jq '."data-root" = "/opt/dlami/nvme/docker"' \
    /etc/docker/daemon.json | sudo tee /etc/docker/daemon.json.tmp >/dev/null

  sudo mv /etc/docker/daemon.json.tmp /etc/docker/daemon.json

  sudo systemctl restart docker
else
  echo "No GPU present!"
fi
