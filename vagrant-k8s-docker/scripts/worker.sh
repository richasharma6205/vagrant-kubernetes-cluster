#!/bin/bash

set -euxo pipefail

NODENAME=$(hostname -s)
VAGRANT_USER_HOME=/home/vagrant
VAGRANT_MOUNT_DIR=/vagrant
CONFIG_DIR=$VAGRANT_MOUNT_DIR/configs

# Join worker nodes to the Kubernetes cluster
/bin/bash $CONFIG_DIR/joincluster.sh -v=5

sudo -i -u vagrant bash << EOF
whoami
mkdir -p $VAGRANT_USER_HOME/.kube
sudo cp -i $CONFIG_DIR/config $VAGRANT_USER_HOME/.kube/
sudo chown 1000:1000 $VAGRANT_USER_HOME/.kube/config
kubectl label node $NODENAME node-role.kubernetes.io/worker=worker
EOF

echo "===================================="
echo 'run command: vagrant ssh master -c "kubectl get nodes -o wide"'
echo "===================================="