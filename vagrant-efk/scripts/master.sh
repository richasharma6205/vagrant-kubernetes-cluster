#!/bin/bash

set -euxo pipefail

NODENAME=$(hostname -s)
VAGRANT_USER_HOME=/home/vagrant
VAGRANT_MOUNT_DIR=/vagrant
CONFIG_DIR=$VAGRANT_MOUNT_DIR/configs

# Function to create directory with optional content deletion
recreate_dir() {
  local dir_path="$1"
  if [ -d "$dir_path" ]; then
    echo "Directory '$dir_path' already exists. Cleaning up..."
    rm -f "$dir_path"/*
  else
    echo "Creating directory '$dir_path'..."
    mkdir -p "$dir_path"
  fi
}

# Initialize the control plane
sudo kubeadm init --apiserver-advertise-address=$MASTER_IP --pod-network-cidr=$POD_CIDR --node-name=$NODENAME --cri-socket=unix:///var/run/cri-dockerd.sock

# To start using the cluster
whoami
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Save Configs to shared /Vagrant location

# For Vagrant re-runs, check if there is existing configs in the location and delete it for saving new configuration.

# Prepare config directory
recreate_dir "$CONFIG_DIR"

sudo cp -i /etc/kubernetes/admin.conf $CONFIG_DIR/config
touch $CONFIG_DIR/joincluster.sh
chmod +x $CONFIG_DIR/joincluster.sh

JOIN_CMD=$(kubeadm token create --print-join-command)
echo "$JOIN_CMD --cri-socket=unix:///var/run/cri-dockerd.sock" > $CONFIG_DIR/joincluster.sh
# kubeadm token create --print-join-command | sed 's/$/ --cri-socket=unix:///var/run/cri-dockerd.sock/' > $CONFIG_DIR/joincluster.sh

sudo -i -u vagrant bash << EOF
whoami
mkdir -p $VAGRANT_USER_HOME/.kube
sudo cp -i $CONFIG_DIR/config $VAGRANT_USER_HOME/.kube/
sudo chown 1000:1000 $VAGRANT_USER_HOME/.kube/config
EOF

# Installing a Pod network add-on
su - vagrant -c "kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"

# add parameter for worker ip
# sed -i "s/$/ --node-ip=\$1/" $VAGRANT_MOUNT_DIR/configs/joincluster.sh
