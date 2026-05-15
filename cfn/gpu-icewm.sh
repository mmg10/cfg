#!/bin/bash
# DCV + IceWM - Ubuntu 24.04 (x86_64) - Console session with NVIDIA GRID (compact)
#
# Boot flow:
#   1. This script runs on first boot (user data)
#      - Installs DCV + IceWM + LightDM, blacklists Nouveau, creates GPU driver install script
#   2. Instance reboots (dcv-gpu-install.service runs)
#      - Downloads and installs NVIDIA GRID driver from S3
#      - Enables dcv-post-reboot.service, reboots again
#   3. Instance reboots a second time (dcv-post-reboot.service runs)
#      - Runs nvidia-xconfig, sets graphical target, starts dcvserver
#
# Note: IAM role needs s3:GetObject on s3://ec2-linux-nvidia-drivers/*

set -x
exec > >(tee /var/log/userdata.log) 2>&1

# Configuration
LISTEN_PORT=8443

# Bootstrap
export DEBIAN_FRONTEND=noninteractive

systemctl stop apt-daily.timer apt-daily-upgrade.timer
apt-get clean all
apt-get update -q
sleep 20
pkill apt || true
pkill dpkg || true
dpkg --configure -a
apt-get install -q -y wget tmux unzip tar curl sed git zsh xclip xsel rename tree aria2 btop jq


# ssh.sh
if sudo -H -u ubuntu bash -c 'cd ~ && wget -q -O ssh.sh https://raw.githubusercontent.com/mmg10/cfg/main/ssh.sh && bash ssh.sh && rm -rf ssh.sh'; then
    echo "[PASS] ssh.sh"
else
    echo "[FAIL] ssh.sh"
fi

# 01_zsh.sh
if sudo -H -u ubuntu bash -c 'cd ~ && wget -q -O 01_zsh.sh https://raw.githubusercontent.com/mmg10/cfg/main/01_zsh.sh && bash 01_zsh.sh && rm 01_zsh.sh'; then
    echo "[PASS] 01_zsh.sh"
else
    echo "[FAIL] 01_zsh.sh"
fi


# Systemd service units

cat > /etc/systemd/system/dcv-post-reboot.service << 'SCRIPT_EOF'
[Unit]
Description=Post install tasks
After=default.target network.target

[Service]
ExecStart=/bin/sh -c "/opt/dcv-post-reboot.sh 2>&1 | tee -a /var/log/install-sw.log"

[Install]
WantedBy=default.target
SCRIPT_EOF

cat > /etc/systemd/system/dcv-gpu-install.service << 'SCRIPT_EOF'
[Unit]
Description=Install GPU driver
After=default.target network.target

[Service]
ExecStart=/bin/sh -c "/opt/install-gpu-driver 2>&1 | tee -a /var/log/install-gpu-driver.log"

[Install]
WantedBy=default.target
SCRIPT_EOF

# Post-reboot script (runs after second reboot, once GPU driver is installed)
# LISTEN_PORT baked in; runtime vars escaped with \$
cat > /opt/dcv-post-reboot.sh << SCRIPT_EOF
#!/bin/bash
set -x
export DEBIAN_FRONTEND=noninteractive

apt-get update -q
apt-get upgrade -q -y

# UFW firewall rules
if (systemctl status ufw | grep -q Loaded); then
  ufw allow ${LISTEN_PORT}/tcp
  ufw allow ${LISTEN_PORT}/udp
fi

# NVIDIA GRID: configure Xorg for GPU
nvidia-xconfig --preserve-busid --enable-all-gpus \
  --connected-monitor=DFP-0,DFP-1,DFP-2,DFP-3

# Set graphical target, enable console session
systemctl set-default graphical.target && systemctl isolate graphical.target && sleep 2
sed -i "s/^#create-session/create-session/g" /etc/dcv/dcv.conf

systemctl enable dcvserver && systemctl restart dcvserver

rm -f /etc/systemd/system/dcv-post-reboot.service
rm -f \$0
systemctl daemon-reload
SCRIPT_EOF
chmod 755 /opt/dcv-post-reboot.sh

# Override systemd-networkd-wait-online timeout
mkdir -p /etc/systemd/system/systemd-networkd-wait-online.service.d
cat > /etc/systemd/system/systemd-networkd-wait-online.service.d/override.conf << 'SCRIPT_EOF'

[Service]
ExecStart=
ExecStart=/usr/lib/systemd/systemd-networkd-wait-online --timeout=3
SCRIPT_EOF

# Phase 1a: General software setup

cat > /root/install-sw.sh << 'SCRIPT_EOF'
#!/bin/bash
set -x
mkdir -p /tmp/cfn
cd /tmp/cfn
export DEBIAN_FRONTEND=noninteractive

echo "ubuntu:123" | chpasswd

apt-get update -q
apt-get upgrade -q -y
apt-get autoremove -q -y

# DKMS (needed for GPU driver)
apt-get update -q
apt-get install -q -y dkms

# Kernel headers for GPU driver
apt-get install -q -y linux-image-aws
apt-get install -q -y linux-headers-aws
apt-get install -q -y linux-modules-extra-aws

# AWS CLI v2
apt-get remove -q -y awscli
snap install aws-cli --classic
if [ ! -e /snap/bin/aws ]; then
  cd /tmp
  curl https://awscli.amazonaws.com/awscli-exe-linux-$(arch).zip -o awscliv2.zip
  unzip -q -o awscliv2.zip
  ./aws/install --update -b /usr/bin
fi
echo "export AWS_CLI_AUTO_PROMPT=on-partial" >> /home/ubuntu/.bashrc

# Reduce networkd wait-online timeout
if (lsb_release -r -s | grep -q 24); then
  sed -i "s/systemd-networkd-wait-online$/& --timeout=3/g" \
    /usr/lib/systemd/system/systemd-networkd-wait-online.service
else
  rm -f /etc/systemd/system/systemd-networkd-wait-online.service.d/override.conf
fi
systemctl daemon-reload

rm -f $0
SCRIPT_EOF
chmod 740 /root/install-sw.sh
/root/install-sw.sh >> /var/log/install-sw.log 2>&1 || true

# Phase 1b: DCV + IceWM installation

# IceWM .xsession files
cat > /home/ubuntu/.xsession << 'SCRIPT_EOF'
exec icewm-session
SCRIPT_EOF
chown ubuntu:ubuntu /home/ubuntu/.xsession
chmod 755 /home/ubuntu/.xsession

cat > /etc/skel/.xsession << 'SCRIPT_EOF'
exec icewm-session
SCRIPT_EOF
chmod 755 /etc/skel/.xsession

mkdir -p /home/ubuntu/.config /etc/skel/.config
chown -R ubuntu:ubuntu /home/ubuntu/.config

# install-dcv.sh (LISTEN_PORT baked in; runtime vars escaped with \$)
cat > /root/install-dcv.sh << SCRIPT_EOF
#!/bin/bash
set -x
mkdir -p /tmp/cfn
cd /tmp/cfn
export DEBIAN_FRONTEND=noninteractive

# Fix any interrupted dpkg from previous phase
dpkg --configure -a

apt-get update -q
apt-get upgrade -q -y

# X11 + IceWM + LightDM
apt-get install -q -y xorg x11-xserver-utils icewm lightdm

timedatectl set-timezone Asia/Karachi

if sudo -H -u ubuntu bash -c 'cd ~ && wget -q -O brave.sh https://raw.githubusercontent.com/mmg10/cfg/main/brave.sh && bash brave.sh && rm brave.sh'; then
    echo "[PASS] brave.sh"
else
    echo "[FAIL] brave.sh"
fi


# Auto-login ubuntu with IceWM
mkdir -p /etc/lightdm/lightdm.conf.d
cat > /etc/lightdm/lightdm.conf.d/50-autologin.conf << 'INNEREOF'
[Seat:*]
autologin-user=ubuntu
autologin-session=icewm-session
user-session=icewm-session
INNEREOF

apt-get install -q -y dpkg-dev
apt-get install -q -y pulseaudio-utils

# DCV agent needs libdcv.so from non-standard path
echo "/usr/lib/x86_64-linux-gnu/dcv" > /etc/ld.so.conf.d/dcv.conf
ldconfig

# DCV server
curl -s -L -O https://d1uj6qtbmh3dt5.cloudfront.net/NICE-GPG-KEY
gpg --import NICE-GPG-KEY
OS_VERSION=\$(. /etc/os-release;echo \$VERSION_ID | sed -e 's/\.//g')
curl -s -L -O \
  https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-ubuntu\${OS_VERSION}-\$(arch).tgz
tar -xvzf nice-dcv-ubuntu*.tgz && cd nice-dcv-*-\$(arch)
apt-get install -q -y ./nice-dcv-server_*.deb
apt-get install -q -y ./nice-dcv-web-viewer_*.deb
usermod -aG video dcv
apt-get install -q -y ./nice-xdcv_*.deb
if (arch | grep -q x86); then
  apt-get install -q -y ./nice-dcv-gltest_*.deb
fi

# DCV-GL for GPU-accelerated OpenGL in sessions
apt-get install -q -y ./nice-dcv-gl_*.deb

# DCV agent autostart via IceWM startup
mkdir -p /home/ubuntu/.icewm
cat > /home/ubuntu/.icewm/startup << 'INNEREOF'
#!/bin/bash
export XDG_RUNTIME_DIR=/run/user/\$(id -u)
export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/dcv
/usr/lib/x86_64-linux-gnu/dcv/dcvagentlauncher &
INNEREOF
chmod 755 /home/ubuntu/.icewm/startup
chown -R ubuntu:ubuntu /home/ubuntu/.icewm

# QUIC UDP transport
cp /etc/dcv/dcv.conf /etc/dcv/dcv.conf."\$(date +"%Y-%m-%d")"
sed -i "s/^#enable-quic-frontend=true/enable-quic-frontend=true/g" /etc/dcv/dcv.conf

# Listen port
sed -i "/^web-port=/d" /etc/dcv/dcv.conf
sed -i "/^quic-port=/d" /etc/dcv/dcv.conf
sed -i "/^\[connectivity\]/a web-port=${LISTEN_PORT}" /etc/dcv/dcv.conf
sed -i "/^\[connectivity\]/a quic-port=${LISTEN_PORT}" /etc/dcv/dcv.conf

# X11 dummy driver (fallback; GPU replaces this)
apt-get install -q -y xserver-xorg-video-dummy

# Higher web client max resolution
sed -i "/^\[display/a web-client-max-head-resolution=(1920, 1080)" /etc/dcv/dcv.conf

# Target FPS
sed -i 's/^#*target-fps *=.*/target-fps=30/' /etc/dcv/dcv.conf

# Console session owner and storage root
sed -i "/^\[session-management\/automatic-console-session/a owner=\"ubuntu\"\nstorage-root=\"%home%\"" /etc/dcv/dcv.conf

systemctl daemon-reload
chown -R ubuntu:ubuntu /home/ubuntu/.config

rm -f \$0
SCRIPT_EOF
chmod 740 /root/install-dcv.sh
/root/install-dcv.sh > /var/log/install-dcv.log 2>&1 || true

# Phase 1c: X11 dummy config (superseded by nvidia-xconfig after GPU install)
cat > /etc/X11/xorg.conf << 'SCRIPT_EOF'
Section "Device"
    Identifier "DummyDevice"
    Driver "dummy"
    Option "UseEDID" "false"
    VideoRam 512000
EndSection

Section "Monitor"
    Identifier "DummyMonitor"
    HorizSync   5.0 - 1000.0
    VertRefresh 5.0 - 200.0
    Option "ReducedBlanking"
EndSection

Section "Screen"
    Identifier "DummyScreen"
    Device "DummyDevice"
    Monitor "DummyMonitor"
    DefaultDepth 24
    SubSection "Display"
        Viewport 0 0
        Depth 24
        Virtual 1920 1080
    EndSubSection
EndSection
SCRIPT_EOF

# Phase 1d: GPU prep - blacklist Nouveau

cat > /root/install-gpu-sw.sh << 'SCRIPT_EOF'
#!/bin/bash
set -x
export DEBIAN_FRONTEND=noninteractive

apt-get install -q -y unzip gcc make
apt-get install -q -y libglvnd-dev pkg-config

# Disable Nouveau driver
if (! cat /etc/modprobe.d/blacklist.conf | grep -q nouveau); then
  echo "blacklist vga16fb"  >> /etc/modprobe.d/blacklist.conf
  echo "blacklist nouveau"  >> /etc/modprobe.d/blacklist.conf
  echo "blacklist rivafb"   >> /etc/modprobe.d/blacklist.conf
  echo "blacklist nvidiafb" >> /etc/modprobe.d/blacklist.conf
  echo "blacklist rivatv"   >> /etc/modprobe.d/blacklist.conf
fi
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="rdblacklist=nouveau /g' /etc/default/grub
update-grub

systemctl daemon-reload
systemctl enable dcv-gpu-install

rm -f $0
SCRIPT_EOF
chmod 740 /root/install-gpu-sw.sh
/root/install-gpu-sw.sh > /var/log/install-gpu-driver.log 2>&1 || true

# Phase 1e: NVIDIA GRID driver installer (runs after first reboot)

cat > /opt/install-gpu-driver << 'SCRIPT_EOF'
#!/bin/bash
set -x
mkdir -p /tmp/gpu
cd /tmp/gpu
export DEBIAN_FRONTEND=noninteractive

# Download NVIDIA GRID driver from S3
aws s3 cp --recursive s3://ec2-linux-nvidia-drivers/latest/ . --no-sign-request
if [ $? -eq 1 ]; then
  aws s3 cp --recursive s3://ec2-linux-nvidia-drivers/latest/ .
fi
if [ $? -eq 1 ]; then
  aws s3 cp --recursive s3://ec2-linux-nvidia-drivers/latest/ . --region us-east-1
fi
if [ $? -eq 1 ]; then
  curl -s -L -O https://ec2-linux-nvidia-drivers.s3.amazonaws.com/grid-18.4/NVIDIA-Linux-x86_64-570.172.08-grid-aws.run
fi

chmod +x NVIDIA-Linux-x86_64*.run
if (lsb_release -r -s | grep -q 22); then
  CC=/usr/bin/gcc-12 ./NVIDIA-Linux-x86_64*.run -s --skip-module-load
  cd /usr/src/nvidia-*
  sed -i "s/\"'make'/& CC=\/usr\/bin\/gcc-12 IGNORE_CC_MISMATCH=1/" dkms.conf
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 12
  update-alternatives --config gcc
else
  ./NVIDIA-Linux-x86_64*.run -s --skip-module-load
fi

touch /etc/modprobe.d/nvidia.conf
echo "options nvidia NVreg_EnableGpuFirmware=0" | tee --append /etc/modprobe.d/nvidia.conf

systemctl enable dcv-post-reboot
rm -f /etc/systemd/system/dcv-gpu-install.service
rm -f $0
reboot
SCRIPT_EOF
chmod 755 /opt/install-gpu-driver

# Finalize
systemctl set-default multi-user.target
systemctl daemon-reload
systemctl enable dcv-gpu-install

sleep 1 && reboot
