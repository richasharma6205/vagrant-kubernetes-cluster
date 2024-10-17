#!/bin/bash

set -euxo pipefail

# disable swap
sudo swapoff -a

# keeps the swaf off during reboot
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true

# DNS Setting
if [ ! -d /etc/systemd/resolved.conf.d ]; then
	sudo mkdir /etc/systemd/resolved.conf.d/
fi
cat <<EOF | sudo tee /etc/systemd/resolved.conf.d/dns_servers.conf
[Resolve]
DNS=${DNS_SERVERS}
EOF

sudo systemctl restart systemd-resolved

# Create the .conf file to load the modules at bootup
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Install container runtime

# Install and configure prerequisites

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Install Docker Desktop on Ubuntu

# Set up Docker's apt repository.

KEYRINGS_DIRECTORY="/etc/apt/keyrings"
if [ ! -d "$KEYRINGS_DIRECTORY" ]; then
  echo "$KEYRINGS_DIRECTORY does not exist."
  sudo mkdir -p -m 755 /etc/apt/keyrings
fi

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
sudo apt-get update -y
# sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo apt-get install -y docker-ce

# Add the user "vagrant" to the "docker" group
usermod -aG docker vagrant

sudo service docker start

# Install cri-dockerd

# Check for latest release version
VER=$(curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest|grep tag_name | cut -d '"' -f 4|sed 's/v//g')

# Download the archive file and untar it
curl -L https://github.com/Mirantis/cri-dockerd/releases/download/v${VER}/cri-dockerd-${VER}.amd64.tgz -o cri-dockerd.tar.gz
tar xzf cri-dockerd.tar.gz

# Move cri-dockerd binary package to /usr/local/bin directory
sudo mv cri-dockerd/cri-dockerd /usr/local/bin/

# Configure systemd units for cri-dockerd
wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service
wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
sudo mv cri-docker.socket cri-docker.service /etc/systemd/system/
sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service

# Start and enable the services
sudo systemctl daemon-reload
sudo systemctl enable cri-docker.service
sudo systemctl enable --now cri-docker.socket

# Install kubectl using native package management

# sudo apt-get update -y

# Update the apt package index and install packages needed to use the Kubernetes apt repository:
sudo apt-get install -y apt-transport-https ca-certificates gnupg gpg

# Download the public signing key for the Kubernetes package repositories
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add the appropriate Kubernetes apt repository
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list # helps tools such as command-not-found to work correctly

# Update the apt package index, install kubelet, kubeadm and kubectl, and pin their version
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
# Disable auto-update services
sudo apt-mark hold kubelet kubeadm kubectl

sudo sed -i "/\[Service\]$/a\Environment=\"KUBELET_EXTRA_ARGS=--node-ip=${VM_IP}\"" /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Enable the kubelet service before running kubeadm
sudo systemctl enable --now kubelet

