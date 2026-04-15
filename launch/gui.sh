#!/bin/bash
set +e
LOGFILE="/home/ubuntu/user-data.log"
exec > >(tee -a "$LOGFILE") 2>&1
echo "[INFO] Starting user data setup at $(date)"

# ssh.sh
if sudo -H -u ubuntu bash -c 'cd ~ && wget -q -O ssh.sh https://raw.githubusercontent.com/mmg10/cfg/main/ssh.sh && bash ssh.sh && rm -rf ssh.sh'; then
    echo "[PASS] ssh.sh"
else
    echo "[FAIL] ssh.sh"
fi

apt update > /dev/null 2>&1
apt install -y git zsh unzip xclip xsel tmux rename nfs-common tree aria2 btop jq > /dev/null 2>&1

# 01_zsh.sh
if sudo -H -u ubuntu bash -c 'cd ~ && wget -q -O 01_zsh.sh https://raw.githubusercontent.com/mmg10/cfg/main/01_zsh.sh && bash 01_zsh.sh && rm 01_zsh.sh'; then
    echo "[PASS] 01_zsh.sh"
else
    echo "[FAIL] 01_zsh.sh"
fi
# 04_docker.sh
if sudo -H -u ubuntu bash -c 'cd ~ && wget -q -O 04_docker.sh https://raw.githubusercontent.com/mmg10/cfg/main/04_docker.sh && bash 04_docker.sh && rm 04_docker.sh'; then
    echo "[PASS] 04_docker.sh"
else
    echo "[FAIL] 04_docker.sh"
fi
echo "User data script completed at $(date)"

# gui.sh
if sudo -H -u ubuntu bash -c 'cd ~ && wget -q -O gui.sh https://raw.githubusercontent.com/mmg10/cfg/main/gui.sh && bash gui.sh && rm gui.sh'; then
    echo "[PASS] gui.sh"
else
    echo "[FAIL] gui.sh"
fi

# brave.sh
if sudo -H -u ubuntu bash -c 'cd ~ && wget -q -O brave.sh https://raw.githubusercontent.com/mmg10/cfg/main/brave.sh && bash brave.sh && rm brave.sh'; then
    echo "[PASS] brave.sh"
else
    echo "[FAIL] brave.sh"
fi
echo "User data script completed at $(date)"
