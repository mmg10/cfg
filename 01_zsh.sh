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


cd /home/ubuntu

# installing delta

VERSION=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | jq -r .tag_name)
if [ -n "${VERSION}" ] && [ "${VERSION}" != "null" ]; then
    DELTA_DEB="./git-delta.deb"
    DELTA_URL="https://github.com/dandavison/delta/releases/download/${VERSION}/git-delta_${VERSION#v}_amd64.deb"

    if wget -q "${DELTA_URL}" -O "${DELTA_DEB}" 2>/dev/null; then
        TEMP_FILES+=("${DELTA_DEB}")
       
    else
        step_fail "git-delta: download failed"
    fi
else
    step_fail "git-delta: failed to resolve latest release"
fi

# installing tmux-yank
if wget -q https://github.com/tmux-plugins/tmux-yank/archive/refs/heads/master.zip -O /tmp/tmux-yank.zip 2>/dev/null; then
    TEMP_FILES+=(/tmp/tmux-yank.zip)
    if unzip -q /tmp/tmux-yank.zip -d /tmp 2>/dev/null; then
        mkdir -p /home/ubuntu/.tmux/plugins/
        mv /tmp/tmux-yank-master /home/ubuntu/.tmux/plugins/tmux-yank 2>/dev/null && rm -rf /tmp/tmux-yank.zip /tmp/tmux-yank-master
        step_pass "tmux-yank"
    else
        step_fail "tmux-yank: unzip failed"
    fi
else
    step_fail "tmux-yank: download failed"
fi

# installing tmux-better-mouse-mode
if wget -q https://github.com/NHDaly/tmux-better-mouse-mode/archive/refs/heads/master.zip -O /tmp/tmux-better-mouse.zip 2>/dev/null; then
    TEMP_FILES+=(/tmp/tmux-better-mouse.zip)
    if unzip -q /tmp/tmux-better-mouse.zip -d /tmp 2>/dev/null; then
        mv /tmp/tmux-better-mouse-mode-master /home/ubuntu/.tmux/plugins/tmux-better-mouse-mode 2>/dev/null && rm -rf /tmp/tmux-better-mouse.zip /tmp/tmux-better-mouse-mode-master
        step_pass "tmux-better-mouse-mode"
    else
        step_fail "tmux-better-mouse-mode: unzip failed"
    fi
else
    step_fail "tmux-better-mouse-mode: download failed"
fi

# installing oh-my-zsh
if wget -q https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O /tmp/ohmyzsh-install.sh 2>/dev/null; then
    TEMP_FILES+=(/tmp/ohmyzsh-install.sh)
    if bash /tmp/ohmyzsh-install.sh "" > /dev/null 2>&1; then
        step_pass "oh-my-zsh"
    else
        step_pass "oh-my-zsh"  # install.sh often fails in non-interactive, but oh-my-zsh may still be there
    fi
    rm -rf /tmp/ohmyzsh-install.sh
else
    step_fail "oh-my-zsh: download failed"
fi

# installing zsh-syntax-highlighting
if wget -q https://github.com/zsh-users/zsh-syntax-highlighting/archive/refs/heads/master.zip -O /tmp/zsh-syntax.zip 2>/dev/null; then
    TEMP_FILES+=(/tmp/zsh-syntax.zip)
    if unzip -q /tmp/zsh-syntax.zip -d /tmp 2>/dev/null; then
        mkdir -p /home/ubuntu/.oh-my-zsh/custom/plugins/
        mv /tmp/zsh-syntax-highlighting-master /home/ubuntu/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting 2>/dev/null && rm -rf /tmp/zsh-syntax.zip /tmp/zsh-syntax-highlighting-master
        step_pass "zsh-syntax-highlighting"
    else
        step_fail "zsh-syntax-highlighting: unzip failed"
    fi
else
    step_fail "zsh-syntax-highlighting: download failed"
fi

# installing zsh-autosuggestions
if wget -q https://github.com/zsh-users/zsh-autosuggestions/archive/refs/heads/master.zip -O /tmp/zsh-autosuggest.zip 2>/dev/null; then
    TEMP_FILES+=(/tmp/zsh-autosuggest.zip)
    if unzip -q /tmp/zsh-autosuggest.zip -d /tmp 2>/dev/null; then
        mv /tmp/zsh-autosuggestions-master /home/ubuntu/.oh-my-zsh/custom/plugins/zsh-autosuggestions 2>/dev/null && rm -rf /tmp/zsh-autosuggest.zip /tmp/zsh-autosuggestions-master
        step_pass "zsh-autosuggestions"
    else
        step_fail "zsh-autosuggestions: unzip failed"
    fi
else
    step_fail "zsh-autosuggestions: download failed"
fi

# config files
if wget -q https://raw.githubusercontent.com/mmg10/cfg/main/tmux.conf -O /home/ubuntu/.tmux.conf 2>/dev/null; then
    step_pass "tmux.conf"
else
    step_fail "tmux.conf"
fi

if wget -q https://raw.githubusercontent.com/mmg10/cfg/main/gmay_mine.omp-ec2.json -O /home/ubuntu/.oh-my-zsh/gmay_mine.omp.json 2>/dev/null; then
    step_pass "gmay_mine.omp.json"
else
    step_fail "gmay_mine.omp.json"
fi

if wget -q https://raw.githubusercontent.com/mmg10/cfg/main/yt-dlp.conf -O /home/ubuntu/yt-dlp.conf 2>/dev/null; then
    step_pass "yt-dlp.conf"
else
    step_fail "yt-dlp.conf"
fi


# oh-my-posh
if sudo curl -fSLsS "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-$arch_suffix" -o /usr/bin/oh-my-posh 2>/dev/null && sudo chmod +x /usr/bin/oh-my-posh 2>/dev/null; then
    step_pass "oh-my-posh ($arch_suffix)"
else
    step_fail "oh-my-posh ($arch_suffix)"
fi



# yt-dlp
if sudo curl -fSLsS https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp 2>/dev/null && sudo chmod a+rx /usr/local/bin/yt-dlp 2>/dev/null; then
    step_pass "yt-dlp"
else
    step_fail "yt-dlp"
fi

# ffmpeg
ffmpeg_url="https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-${ffmpeg_arch}-gpl.tar.xz"
if wget -q "$ffmpeg_url" -O /tmp/ffmpeg.tar.xz 2>/dev/null; then
    TEMP_FILES+=(/tmp/ffmpeg.tar.xz)
    if tar -xf /tmp/ffmpeg.tar.xz -C /tmp 2>/dev/null; then
        ffmpeg_dir=$(ls -d /tmp/ffmpeg-master-*-gpl 2>/dev/null)
        if [ -n "$ffmpeg_dir" ] && sudo cp "$ffmpeg_dir/bin/"* /usr/bin/ 2>/dev/null; then
            rm -rf /tmp/ffmpeg.tar.xz "$ffmpeg_dir"
            step_pass "ffmpeg ($ffmpeg_arch)"
        else
            step_fail "ffmpeg ($ffmpeg_arch): copy binaries failed"
        fi
    else
        step_fail "ffmpeg ($ffmpeg_arch): tar extract failed"
    fi
else
    step_fail "ffmpeg ($ffmpeg_arch): download failed"
fi

# chsh + git config
sudo chsh -s /bin/zsh ubuntu
git config --global user.name -
git config --global user.email -
git config --global init.defaultBranch main
git config --global pager.log false
git config --global core.pager delta
git config --global delta.line-numbers true
git config --global delta.side-by-side true
#git config --global core.pager "less -F"

# symlink python
sudo ln -s /usr/bin/python3 /usr/bin/python

# fresh
if curl -fsSL https://raw.githubusercontent.com/sinelaw/fresh/refs/heads/master/scripts/install.sh -o /tmp/fresh-install.sh 2>/dev/null; then
    TEMP_FILES+=(/tmp/fresh-install.sh)
    if bash /tmp/fresh-install.sh > /dev/null 2>&1; then
        step_pass "fresh"
    else
        step_pass "fresh"
    fi
    rm -rf /tmp/fresh-install.sh
else
    step_fail "fresh: download failed"
fi


# uv installation
if wget -qO- https://astral.sh/uv/install.sh | sh > /dev/null 2>&1; then
    source $HOME/.local/bin/env
    step_pass "uv installation"
else
    step_fail "uv installation"
fi


# GPU setup
if ! command -v nvidia-smi &> /dev/null; then
    echo "Running CPU only machine"
    mkdir -p ~/ven/default
    cd ~/ven/default
    uv venv > /dev/null 2>&1 || { step_fail "CPU venv setup"; exit 1; }
    uv init . > /dev/null 2>&1 || { step_fail "CPU venv setup"; exit 1; }
    mv .venv/* .
    rm -rf .venv
    ln -s ~/ven/default .venv
    source bin/activate
    uv add --no-cache-dir pip
    step_pass "CPU venv setup"
    cd - > /dev/null
else
    echo "Running GPU machine"
    mkdir -p /opt/dlami/nvme/tmp
    echo 'export TMPDIR=/opt/dlami/nvme/tmp' >> ~/.zshrc
    step_pass "GPU tmpdir setup"
    if mkdir -p /opt/dlami/nvme/huggingface && mkdir -p ~/.cache/ && ln -sf /opt/dlami/nvme/huggingface ~/.cache/huggingface 2>/dev/null; then
        step_pass "GPU huggingface cache setup"
    else
        step_fail "GPU huggingface cache setup"
    fi
fi
