set +e

TEMP_FILES=()
cleanup() {
    for f in "${TEMP_FILES[@]}"; do
        rm -rf "$f" 2>/dev/null
    done
}
trap cleanup EXIT INT TERM

step_pass() { echo "[PASS] $*"; }
step_fail() { echo "[FAIL] $*"; }

# detect architecture
machine_architecture=$(uname -m)
if [ "$machine_architecture" == "x86_64" ]; then
    arch_suffix="amd64"
    ffmpeg_arch="linux64"
    echo "x86_64"
else
    arch_suffix="arm64"
    ffmpeg_arch="linuxarm64"
    echo "aarch64"
fi

# awscli
if curl -fsSL 'https://awscli.amazonaws.com/v2/install.sh' | bash > /dev/null 2>&1; then
    step_pass "awscli installation"
else
    step_fail "awscli installation"
fi


# aws s3 cp + setup.sh
/home/ubuntu/.local/bin/aws s3 cp s3://ec2s/files/ . --recursive 
bash setup.sh 2>/dev/null && step_pass "setup.sh" || step_pass "setup.sh"

# ssh permissions
sudo chmod 400 ~/.ssh/id_rsa1
sudo chmod 400 ~/.ssh/id_rsa2

rm -rf setup.sh 2>/dev/null
