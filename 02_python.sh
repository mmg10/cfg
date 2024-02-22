if ! command -v conda &> /dev/null
then
    echo "conda could not be found"
    wget https://bootstrap.pypa.io/get-pip.py
    python get-pip.py
    sudo apt install python3.10-venv -y
    python -m pip install virtualenv --user
    python -m venv ~/envs/default
    echo 'ven default' >> ~/.zshrc
    exit
else
    echo "conda found"
    conda init zsh
    echo 'conda activate pytorch' >> ~/.zshrc
    sudo ln -s /opt/dlami/nvme ~/.cache/huggingface
    exit
fi
