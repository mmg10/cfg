if ! command -v conda &> /dev/null
then
    echo "conda could not be found"
    sudo apt install python3-pip python3-venv -y
    python -m venv ~/envs/default
    echo 'ven default' >> ~/.zshrc
    exit
else
    echo "conda found"
    conda init zsh
    echo 'conda activate pytorch' >> ~/.zshrc
    mkdir /opt/dlami/nvme/huggingface
    sudo ln -s /opt/dlami/nvme/huggingface ~/.cache/huggingface
    sudo cp -r /var/lib/docker/ /opt/dlami/nvme
    # sudo rm -rf /var/lib/docker
    # sudo ln -s /opt/dlami/nvme/docker /var/lib/docker
    echo '{
    "data-root": "/opt/dlami/nvme/docker"
}' | sudo tee /etc/docker/daemon.json >/dev/null
    sudo service docker restart
fi
