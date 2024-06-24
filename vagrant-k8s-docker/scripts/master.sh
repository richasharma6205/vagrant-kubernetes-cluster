#!/bin/bash

set -euxo pipefail

NODENAME=$(hostname -s)
VAGRANT_USER_HOME=/home/vagrant
VAGRANT_MOUNT_DIR=/vagrant
CONFIG_DIR=$VAGRANT_MOUNT_DIR/configs

# Function to create directory with optional content deletion
create_dir_with_clean() {
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
mkdir -p $VAGRANT_USER_HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $VAGRANT_USER_HOME/.kube/config
sudo chown vagrant:vagrant $VAGRANT_USER_HOME/.kube/config

# Save Configs to shared /Vagrant location

# For Vagrant re-runs, check if there is existing configs in the location and delete it for saving new configuration.

# Prepare config directory
create_dir_with_clean "$CONFIG_DIR"

sudo cp -i /etc/kubernetes/admin.conf $CONFIG_DIR/config
touch $CONFIG_DIR/joincluster.sh
chmod +x $CONFIG_DIR/joincluster.sh

JOIN_CMD=$(kubeadm token create --print-join-command)
echo "$JOIN_CMD --cri-socket=unix:///var/run/cri-dockerd.sock" > $CONFIG_DIR/joincluster.sh
# kubeadm token create --print-join-command | sed 's/$/ --cri-socket=unix:///var/run/cri-dockerd.sock/' > $CONFIG_DIR/joincluster.sh

# Installing a Pod network add-on
su - vagrant -c "kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"