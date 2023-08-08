sudo ln -s /usr/bin/python3 /usr/bin/python
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
sudo apt install python3.10-venv -y
python -m pip install virtualenv --user
python -m venv ~/envs/default
