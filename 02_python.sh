wget -qO- https://astral.sh/uv/install.sh | sh
if ! command -v nvidia-smi &> /dev/null
then
    echo "Running CPU only machine"
    sudo apt install python3-pip python3-venv -y
    python -m venv ~/envs/default
    echo 'ven default' >> ~/.zshrc
    exit
else
    echo "Running GPU machine"
    mkdir /opt/dlami/nvme/huggingface
    sudo ln -s /opt/dlami/nvme/huggingface ~/.cache/huggingface
fi
