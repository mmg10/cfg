wget -qO- https://astral.sh/uv/install.sh | sh
if ! command -v nvidia-smi &> /dev/null
then
    echo "Running CPU only machine"
    #sudo apt install python3-pip python3-venv -y
    cd ~/ven/default
    uv venv
    uv init .
    mv .venv/* .
    rm -rf .venv
    ln -s ~/ven/default .venv
    python -m venv ~/ven/default
    source bin/activate
    uv add --no-cache-dir pip
    #echo 'ven default' >> ~/.zshrc
    echo 'source ~/ven/default/bin/activate' >> ~/.zshrc
    cd - > /dev/null
    exit
else
    echo "Running GPU machine"
    mkdir /opt/dlami/nvme/huggingface
    sudo ln -s /opt/dlami/nvme/huggingface ~/.cache/huggingface
fi
