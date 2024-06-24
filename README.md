# Vagrant projects for setting up Kubernetes cluster
## List of projects
### 1. vagrant-k8s-docker
Vagrant project to setup a Kubernetes cluster using docker as the container runtime. Check `vagrant-k8s-docker` directory for more info.

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