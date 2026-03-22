set +e

step_pass() { echo "[PASS] $*"; }
step_fail() { echo "[FAIL] $*"; }

TEMP_FILES=()
cleanup() {
    for f in "${TEMP_FILES[@]}"; do
        rm -rf "$f" 2>/dev/null
    done
}
trap cleanup EXIT INT TERM

if ! command -v docker &> /dev/null; then
    echo "installing docker"
    if curl -fsSL https://get.docker.com -o /tmp/get-docker.sh 2>/dev/null; then
        TEMP_FILES+=(/tmp/get-docker.sh)
        if sudo sh /tmp/get-docker.sh > /dev/null 2>&1; then
            step_pass "docker installation"
        else
            step_fail "docker installation"
        fi
        sudo groupadd docker 2>/dev/null
        sudo usermod -aG docker $USER 2>/dev/null
        newgrp docker 2>/dev/null
        step_pass "docker user groups"
    else
        step_fail "docker install script download"
    fi
else
    step_pass "docker already installed"
fi

if command -v nvidia-smi &> /dev/null; then
    echo "GPU present!"
    if sudo nvidia-ctk runtime configure --runtime=docker > /dev/null 2>&1 && sudo systemctl restart docker > /dev/null 2>&1; then
        step_pass "nvidia-ctk docker runtime"
    else
        step_fail "nvidia-ctk docker runtime"
    fi

    if sudo cp -r /var/lib/docker/ /opt/dlami/nvme/ 2>/dev/null; then
        step_pass "docker data copy to nvme"
    else
        step_fail "docker data copy to nvme"
    fi

    # Ensure daemon.json exists and configure data-root
    sudo mkdir -p /etc/docker
    sudo touch /etc/docker/daemon.json

    if sudo jq '."data-root" = "/opt/dlami/nvme/docker"' /etc/docker/daemon.json | sudo tee /etc/docker/daemon.json.tmp > /dev/null 2>&1 && sudo mv /etc/docker/daemon.json.tmp /etc/docker/daemon.json 2>/dev/null; then
        step_pass "docker data-root config"
    else
        step_fail "docker data-root config"
    fi

    if sudo systemctl restart docker > /dev/null 2>&1; then
        step_pass "docker restart"
    else
        step_fail "docker restart"
    fi
else
    echo "No GPU present!"
fi
