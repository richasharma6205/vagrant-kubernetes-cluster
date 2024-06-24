# Vagrant project for Kubernetes Cluster with Docker

This vagrantfile will set up a kubernetes cluster with one master and workers as per the configuration in vagrantfile. It will use latest versions of all packages.

## Get started

#### 1. Prerequisites
1. Make sure you have vagrant and Oracle VM VirtualBox installed
2. Before starting the vagrant project, make sure VirtualBox is opened in the background

#### 2. Useful commands
This project contains an init.bat file that accepts the below arguments:
1. `start`    : To create vagrant VMs from scratch or to boot up VMs from shutdown state
2. `resume`   : Wake up all VMs from sleep state
3. `sleep`    : Pause all running VMs
4. `shutdown` : Shuts down all running VMs
5. `destroy`  : Destroy all running VMs

Therefore, if you are running a vagrant project for the first time, use `init start`. Otherwise, `init <argument>`

To ssh into a VM, use the command `vagrant ssh <vm_name>`.

#### 3. Configurations
Modifiable properties in the vagrantfile:

| Property in vagrantfile | Default Value | Description |
| ------ | ------| ------ |
| `IMAGE_NAME` | ubuntu/jammy64 | Vagrant box to use |
| `MASTER_IP` | 10.0.0.11 | IP of master VM |
| `WORKER_NODE_COUNT` | 1 | No. of worker VMs to create |
| `WORKER_IP_START` | 10.0.0. | Prefix for worker VM IPs. (Last group of bits in worker IP address are dynamic and starts from 21 i.e. first worker VM's IP will end with `.21`) |
| `MASTER_MEM` | 2048 | Memory for master VM |
| `MASTER_CPUS` | 2 | No. of CPUs for master VM |
| `WORKER_MEM` | 2048 | Memory for master VM |
| `WORKER_CPUS` | 1 | No. of CPUs for master VM |
| `POD_CIDR` | 10.244.0.0/16 | POD Network CIDR to ue when initializing the control plane node |
