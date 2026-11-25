#!/bin/bash
set +e
LOGFILE="/home/ubuntu/user-data.log"
exec > >(tee -a "$LOGFILE") 2>&1
echo "[INFO] Starting user data setup at $(date)"

apt update > /dev/null 2>&1
apt install -y curl git zsh unzip xclip xsel tmux rename nfs-common tree aria2 btop jq unrar gdebi timg > /dev/null 2>&1

# ssh.sh
if sudo -H -u ubuntu bash -c 'cd ~ && wget -q -O ssh.sh https://raw.githubusercontent.com/mmg10/cfg/main/ssh.sh && bash ssh.sh && rm -rf ssh.sh'; then
    echo "[PASS] ssh.sh"
else
    echo "[FAIL] ssh.sh"
fi

# 01_zsh.sh
if sudo -H -u ubuntu bash -c 'cd ~ && wget -q -O 01_zsh.sh https://raw.githubusercontent.com/mmg10/cfg/main/01_zsh.sh && bash 01_zsh.sh && rm -f 01_zsh.sh'; then
    echo "[PASS] 01_zsh.sh"
else
    echo "[FAIL] 01_zsh.sh"
fi
# 04_docker.sh
if sudo -H -u ubuntu bash -c 'cd ~ && wget -q -O 04_docker.sh https://raw.githubusercontent.com/mmg10/cfg/main/04_docker.sh && bash 04_docker.sh && rm -f 04_docker.sh'; then
    echo "[PASS] 04_docker.sh"
else
    echo "[FAIL] 04_docker.sh"
fi


# multiple python versions
if (
    add-apt-repository -y ppa:deadsnakes/ppa &&
    (
        NATIVE_PYTHON=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")') &&
        echo "Native Ubuntu Python: $NATIVE_PYTHON" &&
        PACKAGES=() &&
        for VERSION in 3.11 3.12 3.13 3.14; do
            if [[ "$VERSION" == "$NATIVE_PYTHON" ]]; then
                echo "[SKIP] Python $VERSION (native system Python)"
                continue
            fi
            PACKAGES+=("python${VERSION}" "python${VERSION}-dev")
        done &&
        apt-get install -y "${PACKAGES[@]}"
    )
); then
    echo "[PASS] Python versions installed: ${PACKAGES[*]}"
else
    echo "[FAIL] Python installation"
fi


sudo -H -u ubuntu bash -c 'cd ~ && wget -q -O minikube_k8s.sh https://raw.githubusercontent.com/mmg10/cfg/main/minikube_k8s.sh && chmod +x minikube_k8s.sh'
sudo -H -u ubuntu bash -c 'cd ~ && wget -q -O k8s_tools.sh https://raw.githubusercontent.com/mmg10/cfg/main/k8s_tools.sh && chmod +x k8s_tools.sh'
sudo -H -u ubuntu bash -c 'cd ~ && wget -q -O vllm.md https://raw.githubusercontent.com/mmg10/cfg/main/helpers/vllm.md'
sudo -H -u ubuntu bash -c 'cd ~ && wget -q -O dockhand.md https://raw.githubusercontent.com/mmg10/cfg/main/helpers/dockhand.md' 
echo "User data script completed at $(date)"
