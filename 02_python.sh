set +e

step_pass() { echo "[PASS] $*"; }
step_fail() { echo "[FAIL] $*"; }

if ! command -v nvidia-smi &> /dev/null; then
    echo "Running CPU only machine"
    mkdir -p ~/ven/default
    cd ~/ven/default
    if uv venv > /dev/null 2>&1 && uv init . > /dev/null 2>&1; then
        mv .venv/* .
        rm -rf .venv
        ln -s ~/ven/default .venv
        source bin/activate
        uv add --no-cache-dir pip
    else
        step_fail "CPU venv setup"
    fi
    cd - > /dev/null
else
    echo "Running GPU machine"
    if mkdir -p /opt/dlami/nvme/huggingface && mkdir -p ~/.cache/ && ln -sf /opt/dlami/nvme/huggingface ~/.cache/huggingface 2>/dev/null; then
        step_pass "GPU huggingface cache setup"
    else
        step_fail "GPU huggingface cache setup"
    fi
fi
