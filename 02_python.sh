wget -qO- https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
if ! command -v nvidia-smi &> /dev/null
then
    echo "Running CPU only machine"
    mkdir -p ~/ven/default
    cd ~/ven/default
    uv venv
    uv init .
    mv .venv/* .
    rm -rf .venv
    ln -s ~/ven/default .venv
    source bin/activate
    uv add --no-cache-dir pip
    echo 'source ~/ven/default/bin/activate' >> ~/.zshrc
    cd - > /dev/null
else
    echo "Running GPU machine"
    mkdir /opt/dlami/nvme/huggingface
    ln -s /opt/dlami/nvme/huggingface ~/.cache/huggingface
fi
