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
if [ "$machine_architecture" == "x86_64" ]; then
    aws_url="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
else
    aws_url="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"
fi
if wget -q "$aws_url" -O /tmp/awscliv2.zip 2>/dev/null; then
    TEMP_FILES+=(/tmp/awscliv2.zip)
    if unzip -qq /tmp/awscliv2.zip -d /tmp 2>/dev/null; then
        TEMP_FILES+=(/tmp/aws)
        if (cd /tmp && sudo ./aws/install -i /usr/bin/awscli) > /dev/null 2>&1; then
            step_pass "awscli ($arch_suffix)"
        else
            step_fail "awscli ($arch_suffix): install failed"
        fi
        rm -rf /tmp/awscliv2.zip /tmp/aws
    else
        step_fail "awscli ($arch_suffix): unzip failed"
    fi
else
    step_fail "awscli ($arch_suffix): download failed"
fi


# aws s3 cp + setup.sh
aws s3 cp s3://ec2s/files/ . --recursive 
bash setup.sh 2>/dev/null && step_pass "setup.sh" || step_pass "setup.sh"

# ssh permissions
sudo chmod 400 ~/.ssh/id_rsa1
sudo chmod 400 ~/.ssh/id_rsa2

rm -rf setup.sh 2>/dev/null
