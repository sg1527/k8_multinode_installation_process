# k8-multinode-kubeadm
# Multi-Node Kubernetes Cluster Setup Using Kubeadm Using Containerd Runtime
This readme provides step-by-step instructions for setting up a multi-node Kubernetes cluster using Kubeadm. 
```VIDEO REF:``` https://www.youtube.com/watch?v=6_i1hXXviHw&t=313s
``` REF:``` https://computingforgeeks.com/install-kubernetes-cluster-ubuntu-jammy/
``` REF:``` https://medium.com/@mrdevsecops/set-up-a-kubernetes-cluster-with-kubeadm-508db74028ce
## Overview
This guide provides detailed instructions for setting up a multi-node Kubernetes cluster using Kubeadm. The guide includes instructions for installing and configuring containerd and Kubernetes, disabling swap, initializing the cluster, installing Flannel, and joining nodes to the cluster.

## Prerequisites
Before starting the installation process, ensure that the following prerequisites are met:

- You have at least two Ubuntu 18.04 or higher servers available for creating the cluster.
- Each server has at least 2GB of RAM and 2 CPU cores.
- The servers have network connectivity to each other.
- You have root access to each server.

## Installation Steps
The following are the step-by-step instructions for setting up a multi-node Kubernetes cluster using Kubeadm:

### 1.```YOU CAN EITHER RUN THIS COMMANDS MANUALLY OR USE ANSIBLE``` use this repo as Ref: https://github.com/abhic137/ansible-intro

Update the system's package list and install necessary dependencies using the following commands:

we are runnning the below all commands with sudo.... so we dont need to go to the root user(root@sg-OptiPlex-7000:~# )like this.....
## you can install it in regular user which can be (masternode1@masternode1-VirtualBox:~$ ) like this... 
because of sudo your already installing it with root access so your having all administrative privileges and can execute any command without restrictions.
```
sudo apt-get update
sudo apt install apt-transport-https curl -y
```
## 2. Install Docker
```
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://get.docker.com/ | sh  
apt-cache policy docker-ce
sudo apt install docker-ce
sudo usermod -aG docker ${USER}
sudo systemctl status docker
```
```
docker images
```
this will gives an error like (permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Head "http://%2Fvar%2Frun%2Fdocker.sock/_ping": dial unix /var/run/docker.sock: connect: permission denied
). so we need to give a permission to /var/run/docker.sock by running it with below command
```
sudo chmod 777 /var/run/docker.sock
```
```
docker images
```
if you get below kind of empty output with heading then you can proceed to next step. it means docker has been installed successfully 
masternode1@masternode1-VirtualBox:~$ docker images
 
REPOSITORY              TAG                   IMAGE ID              CREATED                     SIZE

masternode1@masternode1-VirtualBox:~$ 


<!--## Install containerd
To install Containerd, use the following commands:

```
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install containerd.io -y
```
-->
## 3. Create containerd configuration
Next, create the containerd configuration file using the following commands:

```
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
```

## 4. Edit /etc/containerd/config.toml
Edit the containerd configuration file to set SystemdCgroup to true. Use the following command to open the file:

```
sudo nano /etc/containerd/config.toml
```
this will open a nano editor..now do Ctrl + w and SystemdCgroup to find its location
Set SystemdCgroup to true
Save the changes by pressing Ctrl + X, then Y to confirm, and Enter to save.

```
SystemdCgroup = true
```
```OR```
Using single command
```
sudo sed -i 's/\(SystemdCgroup\s*=\s*\)false/\1true/' /etc/containerd/config.toml && sudo cat /etc/containerd/config.toml

```
Restart containerd:
```
sudo systemctl restart containerd
```
## 5. Edit Cgroup (If you want to change cgroup to systemd)
```
 docker info | grep -i cgroup
```
masternode1@masternode1-VirtualBox:~$  docker info | grep -i cgroup

WARNING: bridge-nf-call-iptables is disabled
 Cgroup Driver: systemd
 Cgroup Version: 2
  cgroupns
WARNING: bridge-nf-call-ip6tables is disabled

if above command gives output in this form   Cgroup Driver: systemd
then everything is ok....and you can skip below things and go to Intall Kubernetes

```
        ##  ignore if Cgroup Driver: systemd is present
(ignore it) sudo nano /etc/default/grub
```
#Add below lines - if ....Cgroup Driver: systemd ....is not present otherwise ignore this step.
```
        ##  ignore if Cgroup Driver: systemd is present
(ignore it) GRUB_CMDLINE_LINUX="systemd.unified_cgroup_hierarchy=1"
```
```
        ##  ignore if Cgroup Driver: systemd is present
(ignore it) sudo update-grub
```
```
       ##  ignore if Cgroup Driver: systemd is present
(ignore it) sudo reboot
 ```


## 6. Install Kubernetes
To install Kubernetes, use the following commands
```
sudo apt-get update
```
#apt-transport-https may be a dummy package; if so, you can skip that package
## use only new version. kubernetes packages keep on upgrading so you always need to find/use the latest one to install k8.
```
      ## (ignore it) Old version below
 (ignore it) sudo apt-get install -y apt-transport-https ca-certificates curl gpg 
```
## New Version
```
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg   

```
```
sudo mkdir -p -m 755 /etc/apt/keyrings
```
```
     ## (ignore it) Old packages below (V1.29) 
(ignore it) curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```
## New Packages (V1.31)
```
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```
## allow unprivileged APT programs to read this keyring
```
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```
## .......
.......
```
## (ignore it) (Old Version) below This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list


(ignore it) echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```
## (New Version) This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
```
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```
```
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
```

```
sudo apt-get update
```
```
sudo apt-get install -y kubelet kubeadm kubectl
```
```
sudo apt-mark hold kubelet kubeadm kubectl
```
```
sudo systemctl enable --now kubelet
```
## 7. Disable swap
Disable swap using the following command:

```
sudo swapoff -a
```
## ......If there are any swap entries in the /etc/fstab file, remove them using a text editor such as nano:
```
sudo nano /etc/fstab
```
here you will see a  sentence (#/swapfile                                 none            swap    sw              0       0
) give it # as shown to this one sentence and save it .

## 8. Enable kernel modules
```
sudo modprobe br_netfilter
```

## 9. Add some settings to sysctl
```
sudo sysctl -w net.ipv4.ip_forward=1
```
## 10. .......
Now, Here if you have already finished a master node installation then. and if now your inside your worker node then here you copy-paste your token generated from below step 10.1, token joining and its further explanation is given in step 13 check it out. 
but if you have not finished master node installation then follow below steps.



## 10.1. Initialize the Cluster (Run only on master)


```
#(ignore) if you are using flannel then do below.......

(ignore) sudo kubeadm init --pod-network-cidr=10.244.0.0/16

but
```
#if you are using calio then use below to initialize the kubeadm. here we are using calio as it is reliable for all production level deployments....

```
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```

```
Output:
```

.............
........

now you will see below form of output from here. run below commands you get in this output. and copy the token generated to use it on worker node.

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.27.22.170:6443 --token mgz8ws.iw2ln8d5e8yf4ocj \
--discovery-token-ca-cert-hash sha256:c05759bfed7cad687af8789b25f2ddc75995e533edfa2fabfa7f6e0968df3467 

## ......Create a .kube directory in your home directory:

```
mkdir -p $HOME/.kube
```
## ......Copy the Kubernetes configuration file to your home directory:

``` 
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```

## ......Change ownership of the file:
```  
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```






## 10.2.(ignore this if your working on only one master node) Multi-Master node control plane intallation process
Use this command for retrive the current configuration

```
kubectl -n kube-system get cm kubeadm-config -o yaml > kubeadm-config.yaml
```
Add controlPlaneEndpoint: "EXISTING_MASTER_PRIVATE_IP:6443" below cluster name save it and apply 
kubectl apply -f .
```
kubeadm init phase upload-certs --upload-certs
```
```
kubeadm token create --print-join-command --certificate-key <YOUR_CERTIFICATE_KEY>
```
Use below command in other nodes
```
sudo kubeadm join EXISTING_MASTER_PRIVATE_IP:6443 --token <YOUR_TOKEN> \
    --discovery-token-ca-cert-hash sha256:<YOUR_HASH> \
    --control-plane --certificate-key <YOUR_CERTIFICATE_KEY>
```


## ......If you are using public ip
```
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-cert-extra-sans=PUBLIC_IP_MASTER_NODE
```

## ......Create a .kube directory in your home directory:
```
mkdir -p $HOME/.kube
```

## ......Copy the Kubernetes configuration file to your home directory:
```
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```

## ......Change ownership of the file:
```
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```




## 11.(ignore)Install Flannel (Run only on master node)
Use the following command to install Flannel:

```
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/v0.20.2/Documentation/kube-flannel.yml
```

   ## (ignore)Apply kubectl command
   
 ```
 kubectl apply -f kube-flannel.yaml
```
   ## (ignore)For Multi-Network Edit kube-flannel.yaml file
   
```
wget https://raw.githubusercontent.com/flannel-io/flannel/v0.20.2/Documentation/kube-flannel.yml
```
    ##  .........      instead of flannel use calico


    

## 12. Install Calico Network (Run only on master node)


   ##  ...... Install the operator on your cluster
```
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/tigera-operator.yaml
```
   ##  ...... Download the custom resources necessary to configure Calico.
```
curl https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/custom-resources.yaml -O
```
  ##  ...... Create the manifest to install Calico.
```
kubectl create -f custom-resources.yaml
```
```
(ignore) gedit custom-resources.yaml
```
it will open a file from here take the cidr: 192.168.0.0/16 mentioned here and this u have to run with sudo kubeadm init --pod-network-cidr=192.168.0.0/16
  ## .....  Verify Calico installation in your cluster.
```
watch kubectl get pods -n calico-system
```
  
 ## ......Verify Installation
Verify that all the pods are up and running:

```
kubectl get pods --all-namespaces
```

```
kubectl get pods -A
```
















## 13. Join Nodes (Run only on worker node)

To add nodes to the cluster, run the kubeadm join command with the appropriate arguments on each node. The command will output a token that can be used to join the node to the cluster.

sudo kubeadm join <MASTER_IP>:<MASTER_PORT> --token <TOKEN> --discovery-token-ca-cert-hash sha256:<CA_CERT_HASH>
 
eg: sudo kubeadm join 172.27.22.170:6443 --token mgz8ws.iw2ln8d5e8yf4ocj \
--discovery-token-ca-cert-hash sha256:c05759bfed7cad687af8789b25f2ddc75995e533edfa2fabfa7f6e0968df3467 

#dont forget to use word sudo before your token while copy-pasting it on your worker node. 

## 14.  For other network node  (this is not used yet)
Open this file

sudo nano /var/lib/kubelet/kubeadm-flags.env

Add last KUBELET_KUBEADM_ARGS .....

--node-ip=public_Ip 

systemctl restart kubelet ....(In Master as well as Node)

 systemctl restart docker
 
 sudo systemctl status kubelet

## 15 no need to setup/run the commands given in below 15.2. so ignore 15.2 (this is if u want to setup kubectl on worker node then its useful, but this will make u r worker node as master node which we never do in k8 ususally......solution is create u r deployment and service file on master node and inside deployment file u hv alrrady given a docker hubs image credentials. now mention on which worker node u want to run this deployment and thats it.) 

## (ignore this )15.2. Now to run the pods having containarized application in it you need to follow below steps (see video no. 4 for this)

 first You need to have your kubectl context set to the cluster. So that kubectl can communicate with your Kubernetes API server. Typically, this configuration is found in the ~/.kube/config file on your control plane (master) node.
```
# run this on master node
masternode1@masternode1-VirtualBox:~$        kubectl config view
```
```
# run this on master node
cat ~/ .kube/config
```
You need to copy this configuration file shown the output to your worker node so that kubectl can be used there as well. You will use scp (Secure Copy Protocol) for this in below commands on worker node.



```
# run this on master node
sudo apt install openssh-server
```

```
# run this on master node (workernode1@172.27.22.239..........is a username of your worker node then @ then ip of that worker node)
masternode1@masternode1-VirtualBox:~$       ssh workernode1@172.27.22.239
```


```
# run this on worker node
workernode1@workernode1-VirtualBox:~$       sudo apt install openssh-server
```

```
# run this on worker node
 workernode1@workernode1-VirtualBox:~$      mkdir -p ~/.kube
```

```
# run this on worker node
workernode1@workernode1-VirtualBox:~$       scp masternode1@172.27.22.138:~/.kube/config ~/.kube/config
```


```
# below commands is just to check everything is done well or not. its not compulsory run this on worker node.

workernode1@workernode1-VirtualBox:~$       kubectl run nginx --image=nginx
```
workernode1@workernode1-VirtualBox:~$ kubectl run nginx --image=nginx
.....
#output:pod/nginx created

this means everything is working well.

```
# run this on worker or master node 
workernode1@workernode1-VirtualBox:~$    kubectl get pods 
```

```
# run this on worker or master node 
workernode1@workernode1-VirtualBox:~$    kubectl get pods -o wide
```

```
# run this on worker or master node 
workernode1@workernode1-VirtualBox:~$    kubectl describe pod nginx
```

## 14.  Now after this setup after sometime or later any day if your machines got power off/shutdown ....then first just start your masternode machine then worker node machines and run ''kubectl get nodes'' you will see everything is working well. nothing aything else is required to do.





## Important Links
https://www.youtube.com/watch?v=pcADx8JFUIA
https://www.youtube.com/watch?v=Zxozz8P_l5M
<!--
```
# Multi-Node Kubernetes Cluster Setup Using Kubeadm Using Docker CE Runtime
## 1. Upgrade your Ubuntu servers
```
Provision the servers to be used in the deployment of Kubernetes on Ubuntu 22.04. The setup process will vary depending on the virtualization or cloud environment you’re using.

Once the servers are ready, update them.

sudo apt update
sudo apt -y full-upgrade
[ -f /var/run/reboot-required ] && sudo reboot -f

# 2. Install kubelet, kubeadm and kubectl

Once the servers are rebooted, add Kubernetes repository for Ubuntu 22.04 to all the servers.

sudo apt install curl apt-transport-https -y
curl -fsSL  https://packages.cloud.google.com/apt/doc/apt-key.gpg|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/k8s.gpg
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```
Then install required packages.
```
sudo apt update
sudo apt install wget curl vim git kubelet kubeadm kubectl -y
sudo apt-mark hold kubelet kubeadm kubectl
```
Confirm installation by checking the version of kubectl.
```
$ kubectl version --client
Client Version: v1.28.0
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3

$ kubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"28", GitVersion:"v1.28.0", GitCommit:"855e7c48de7388eb330da0f8d9d2394ee818fb8d", GitTreeState:"clean", BuildDate:"2023-08-15T10:20:15Z", GoVersion:"go1.20.7", Compiler:"gc", Platform:"linux/amd64"}
```
## 3. Disable Swap Space

Disable all swaps from /proc/swaps.
```
sudo swapoff -a 
```
Check if swap has been disabled by running the free command.
```
$ free -h
               total        used        free      shared  buff/cache   available
Mem:           7.7Gi       283Mi       5.9Gi       1.0Mi       1.5Gi       7.2Gi
Swap:             0B          0B          0B
```
Now disable Linux swap space permanently in /etc/fstab. Search for a swap line and add # (hashtag) sign in front of the line.
```
sudo sed -i.bak -r 's/(.+ swap .+)/#\1/' /etc/fstab
```
Or manually edit.
```
$ sudo vim /etc/fstab
#/swap.img	none	swap	sw	0	0
```
Confirm setting is correct
```
sudo mount -a
free -h
```
Enable kernel modules and configure sysctl.

## Enable kernel modules
```
sudo modprobe overlay
sudo modprobe br_netfilter
```
## Add some settings to sysctl
```
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
```
## Reload sysctl
```
sudo sysctl --system
```
## 4. Install Container runtime Docker CE
Docker runtime

If your container runtime of choice is Docker CE, follow steps provided below to configure it.
```
# Add repo and Install packages
sudo apt update
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io docker-ce docker-ce-cli

# Create required directories
sudo mkdir -p /etc/systemd/system/docker.service.d

# Create daemon json config file
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# Start and enable Services
sudo systemctl daemon-reload 
sudo systemctl restart docker
sudo systemctl enable docker

# Configure persistent loading of modules
sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

# Ensure you load modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Set up required sysctl params
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
```
For Docker Engine you need a shim interface. 
 Initialize control plane (run on first master node)

Login to the server to be used as master and make sure that the br_netfilter module is loaded:
```
$ lsmod | grep br_netfilter
br_netfilter           22256  0 
bridge                151336  2 br_netfilter,ebtable_broute
```
Enable kubelet service.
```
sudo systemctl enable kubelet
```
We now want to initialize the machine that will run the control plane components which includes etcd (the cluster database) and the API Server.

Pull container images:
```
$ sudo kubeadm config images pull --v=5
 

[config/images] Pulled registry.k8s.io/kube-apiserver:v1.28.0
[config/images] Pulled registry.k8s.io/kube-controller-manager:v1.28.0
[config/images] Pulled registry.k8s.io/kube-scheduler:v1.28.0
[config/images] Pulled registry.k8s.io/kube-proxy:v1.28.0
[config/images] Pulled registry.k8s.io/pause:3.9
[config/images] Pulled registry.k8s.io/etcd:3.5.9-0
[config/images] Pulled registry.k8s.io/coredns/coredns:v1.10.1
```
Docker
```
sudo kubeadm config images pull --cri-socket /run/cri-dockerd.sock
```
Bootstrap without shared endpoint

To bootstrap a cluster without using DNS endpoint, run:
```
sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16
```
Bootstrap with shared endpoint (DNS name for control plane API)

Set cluster endpoint DNS name or add record to /etc/hosts file.
```
$ sudo vim /etc/hosts
172.29.20.5 k8s-cluster.computingforgeeks.com
```
Create cluster:
```
sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --upload-certs \
  --control-plane-endpoint=k8sapi.computingforgeeks.com
```
Note: If 10.244.0.0/16 is already in use within your network you must select a different pod network CIDR, replacing 10.244.0.0/16 in the above command.

Container runtime sockets:
Runtime	Path to Unix domain socket
Docker	/run/cri-dockerd.sock
containerd	/run/containerd/containerd.sock
CRI-O	/var/run/crio/crio.sock
Configure kubectl using commands in the output:

mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

Check cluster status:

$ kubectl cluster-info
Kubernetes master is running at https://k8s-cluster.computingforgeeks.com:6443
KubeDNS is running at https://k8s-cluster.computingforgeeks.com:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluste
You can optionally pass Socket file for runtime and advertise address depending on your setup.
```
# Docker
# Must do https://computingforgeeks.com/install-mirantis-cri-dockerd-as-docker-engine-shim-for-kubernetes/
sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --cri-socket /run/cri-dockerd.sock  \
  --upload-certs \
  --control-plane-endpoint=k8s-cluster.computingforgeeks.com
```
Configure kubectl using commands in the output:
```
mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
Check cluster status:
```
$ kubectl cluster-info
Kubernetes master is running at https://k8s-cluster.computingforgeeks.com:6443
KubeDNS is running at https://k8s-cluster.computingforgeeks.com:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluste
```
## 6. Install Kubernetes network plugin

In this guide we’ll use Flannel network plugin. You can choose any other supported network plugins. Flannel is a simple and easy way to configure a layer 3 network fabric designed for Kubernetes.

Download installation manifest.
```
wget https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```
If your Kubernetes installation is using custom podCIDR (not 10.244.0.0/16) you need to modify the network to match your one in downloaded manifest.
```
$ vim kube-flannel.yml
net-conf.json: |
    {
      "Network": "10.244.0.0/16",
      "Backend": {
        "Type": "vxlan"
      }
    }
```
Then install Flannel by creating the necessary resources.
```
$ kubectl apply -f kube-flannel.yml
namespace/kube-flannel created
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.apps/kube-flannel-ds created
```
Confirm that all of the pods are running, it may take seconds to minutes before it’s ready.
```
$ kubectl get pods -n kube-flannel
NAME                    READY   STATUS    RESTARTS   AGE
kube-flannel-ds-pppw4   1/1     Running   0          2m16s
```
Confirm master node is ready:
```
kubectl get nodes -o wide
```
## 7. Add worker nodes

With the control plane ready you can add worker nodes to the cluster for running scheduled workloads.

If endpoint address is not in DNS, add record to /etc/hosts.
```
$ sudo vim /etc/hosts
172.29.20.5 k8s-cluster.computingforgeeks.com
```
The join command that was given is used to add a worker node to the cluster.
```
kubeadm join k8s-cluster.computingforgeeks.com:6443 \
  --token sr4l2l.2kvot0pfalh5o4ik \
  --discovery-token-ca-cert-hash sha256:c692fb047e15883b575bd6710779dc2c5af8073f7cab460abd181fd3ddb29a18
```
```
Output:

[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.21" ConfigMap in the kube-system namespace
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.
```
 -->
Run below command on the control-plane to see if the node joined the cluster.
```
$ kubectl get nodes
NAME                                 STATUS   ROLES    AGE   VERSION
k8s-master01.computingforgeeks.com   Ready    master   10m   v1.26.1
k8s-worker01.computingforgeeks.com   Ready    <none>   50s   v1.26.1
k8s-worker02.computingforgeeks.com   Ready    <none>   12s   v1.26.1
```
```
$ kubectl get nodes -o wide
```
# For removing the nodes

```
kubectl drain <your-node-name> --delete-local-data --force --ignore-daemonsets
kubectl delete node <your-node-name>
sudo kubeadm reset
```
# for debugging
When a worker node is in the "NotReady" state, it means that it is not fully operational or not communicating properly with the control plane. To troubleshoot and resolve the issue, follow these steps:

1. **Check Node Status:**
   Run the following command to get more details about the worker node's status:

   ```bash
   kubectl describe node worker2
   ```

   Look for any events or conditions that indicate why the node is not ready.

2. **Check Kubelet Logs:**
   Examine the logs of the `kubelet` service on the worker node for any issues:

   ```bash
   journalctl -u kubelet -n 100 --no-pager
   ```

   Look for any error messages or indications of problems.

3. **Restart Kubelet:**
   Restart the `kubelet` service on the worker node:

   ```bash
   sudo systemctl restart kubelet
   ```

   After restarting, check the node status again:

   ```bash
   kubectl get nodes
   ```

4. **Check Networking:**
   Ensure that there are no network-related issues preventing communication between the master and worker nodes. Check if you can ping the master node from the worker node and vice versa.

5. **Check System Resources:**
   Verify that the worker node has sufficient system resources (CPU, memory) available. Insufficient resources may lead to node instability.

6. **Check for Node Conditions:**
   Use the following command to check for any problematic conditions on the worker node:

   ```bash
   kubectl get nodes -o wide
   ```

   Look for any conditions that may provide more information on the node's status.

7. **Rejoin the Node:**
   If the issue persists, you can try rejoining the worker node to the cluster. On the master node, run the `kubeadm token create` command to generate a new token, and then use the `kubeadm join` command on the worker node:

   ```bash
   kubeadm token create --print-join-command
   ```

   Copy the output and run it on the worker node.

8. **Check Node Events:**
   Examine the events associated with the worker node:

   ```bash
   kubectl get events --field-selector involvedObject.name=worker2
   ```

   Look for any events that might provide insights into the node's condition.

9. **Check for Disk Space Issues:**
   Ensure that there is sufficient disk space available on the worker node. Disk space issues can impact the operation of the node.

10. **Check for Outdated Components:**
    Verify that all Kubernetes components (kubelet, kubeadm, kubectl) on the worker node are of the same version as those on the master node. Mismatched versions can lead to compatibility issues.

After performing these steps, you should have a clearer understanding of the issue affecting the worker node. If the problem persists or you encounter specific error messages, please provide additional details for further assistance.



## If the PCs are Restarted
The error message indicates the problem:

```
E1204 10:05:22.633134 2205 run.go:74] "command failed" err="failed to run Kubelet: running with swap on is not supported, please disable swap! or set --fail-swap-on flag"
```

The kubelet is failing to start because it detects that swap is enabled on the system, and running Kubernetes with swap enabled is not supported.

To resolve this issue, you need to disable swap on your system. Follow these steps:

1. Disable swap temporarily:

    ```bash
    sudo swapoff -a
    ```

2. Comment out the swap entry in the `/etc/fstab` file. Open the file using a text editor:

    ```bash
    sudo nano /etc/fstab
    ```

    Find the line that looks like:

    ```bash
    /swap.img   none    swap    sw    0   0
    ```

    Comment it out by adding a `#` at the beginning of the line:

    ```bash
    # /swap.img   none    swap    sw    0   0
    ```

    Save the file and exit the text editor.

3. Reboot your system:

    ```bash
    sudo reboot
    ```

4. After the system reboots, check that swap is disabled:

    ```bash
    sudo swapon --show
    ```

    This command should not return any output, indicating that swap is disabled.

5. Restart the kubelet:

    ```bash
    sudo systemctl restart kubelet
    ```

Check if the kubelet starts successfully now. If there are any other issues, please share the relevant logs, and I'll assist you further.





## 19. Regarding k8s manifest files creatinon 

.......when you have multiple Kubernetes resource definition files (deployment,service etc) in a directory and want to create all the resources at once then open terminal in that directoy and run below command.......
```
kubectl create -f .
```
when you creat an k8 file (eg: abc.yaml) and then you edit it (using kubectl edit deployment abc
or using vim) make some changes in it. now when u want to apply those changes to that same file use use below apply conmmand

```
kubectl apply -f abc.yaml
```
The kubectl create -f . command is used to create resources in Kubernetes from configuration files (YAML or JSON). The -f . part specifies that all the resource files in the current directory (where the command is executed) should be applied.


...........pod related commands..........

kubectl explain pod (if u want to know how this file should be)

kubectl create -f pod.yaml 

kubectl get nodes -o wide

kubectl get pods -o wide


vim pod.yaml

cat  pod.yaml

kubectl edit pod myapp-pod

kubectl apply -f pod.yaml

.
.
.
............replicaset related commands........

kubectl explain replicaset (if u want to know how this file should be)
kubectl create -f replicaset.yaml 

kubectl get pods

kubectl get replicaset
(replicaset is a part of  command name of an object replicaset ...not any file or folder name)



kubectl delete pod myapp-replicaset-8bqd5

kubectl describe replicaset

kubectl edit replicaset myapp-replicaset
kubectl apply -f fileName.yaml


kubectl scale replicaset myapp-replicaset --replicas=2

kubectl get all

.
.
.
...............depployment related commands............

vim deployment.yaml

cat deployment.yaml

kubectl create -f deployment.yaml

kubectl get deployments

kubectl get pods

kubectl describe deployments myapp-deployment

kubectl edit deployment myapp-deployment

kubectl apply -f fileName.yaml

kubectl get all

kubectl rollout status deployment.apps/myapp-deployment

kubectl delete deployment myapp-deployment

kubectl create -f deployment.yaml

kubectl rollout history deployment.apps/myapp-deployment

kubectl delete deployment myapp-deployment

kubectl create -f deployment.yaml --record

kubectl rollout history deployment.apps/myapp-deployment

kubectl describe deployments myapp-deployment

kubectl edit deployment myapp-deployment --record

kubectl rollout status deployment.apps/myapp-deployment

kubectl describe deployments myapp-deployment

..another way to make changes in the deploymet rather that edit is set.. 

kubectl set deployment myapp-deployment nginx=nginx:1.18-perl 

..then to see the chnages use below command..

 kubectl edit deployment myapp-deployment 
or 
kubectl describe deployments myapp-deployment

kubectl rollout status deployment.apps/myapp-deployment
kubectl rollout history deployment/myapp-deployment

..to delet the last created deploymenr use undo..

kubectl rollout undo deployment/myapp-deployment
kubectl rollout status deployment.apps/myapp-deployment


.
.
.
............services related commands.............

kubectl create -f service.yaml

kubectl get service        or    kubectl get svc
workernode1@workernode1-VirtualBox:~/service$ kubectl get service
NAME            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
kubernetes      ClusterIP   10.96.0.1      <none>        443/TCP        8d
myapp-service   NodePort    10.109.82.94   <none>        80:30004/TCP   18s



now take the port 30004 and your worker node ip (172.27.22.139).....172.27.22.139:30004 now paste this in u r browser u will be able to access the front end page of u r applcation.



kubectl describe svc kubernetes













## 20. Regarding k8s manifest files delete 

## specific Kubernetes resources like a particular pod, deployment, service, etc., you can use the kubectl delete command followed by the type of resource and its name.

Here are examples for different resources:

Delete a specific deployment
To delete a deployment named my-deployment:
```
kubectl delete deployment my-deployment
```

If the deployment is in a specific namespace:
```
kubectl delete deployment my-deployment -n my-namespace
```

## Force delete the pod and all other Kubernetes resources (just add the name of that resource in place of pod rest all is same) 
If a pod is stuck in the Terminating state for too long, you can forcefully delete it:

```
kubectl delete pod nginx --grace-period=0 --force
```
This command will immediately delete the pod without waiting for Kubernetes' usual grace period.
```
kubectl delete pods --all --grace-period=0 --force
```

Check for finalizers
Sometimes, Kubernetes resources have finalizers, which prevent a resource from being deleted until certain conditions are met. To check if your pod has finalizers, use:
```
kubectl get pod nginx -o json | jq '.metadata.finalizers'
```
If the pod has any finalizers, you can manually remove them by editing the pod:
```
kubectl edit pod nginx
kubectl edit svc frontend-service
```
nginx it is the name of the pod....frontend-service it is the name of the service.

1. Delete a specific pod in the default namespace
```
kubectl delete pod <pod-name>
```
2. Delete all pods in the default namespace
```
kubectl delete pods --all
```
3. Delete a specific deployment in the default namespace
```
kubectl delete deployment <deployment-name>
```
4. Delete a specific service in the default namespace
```
kubectl delete service <service-name>
```
## Delete all resources (pods, services, deployments, etc.) in the default namespace
To delete all resources like pods, services, deployments, etc., in the default namespace, you can run:
```
kubectl delete all --all
```
This will delete all pods, services, deployments, replicasets, etc. in the default namespace.

Ensure you are cautious with these commands as they will remove all the specified resources in the default namespace.



## Deleting resources in a specific namespace
If you're targeting a specific namespace (e.g., my-namespace), you can use:

```
# Delete all pods
kubectl delete pods --all -n my-namespace

# Delete all deployments
kubectl delete deployments --all -n my-namespace

# Delete all services
kubectl delete services --all -n my-namespace

# Delete all resources in the namespace
kubectl delete all --all -n my-namespace
```
Deleting resources in all namespaces
To delete resources across all namespaces, you can use:

```
# Delete all pods
kubectl delete pods --all --all-namespaces

# Delete all deployments
kubectl delete deployments --all --all-namespaces

# Delete all services
kubectl delete services --all --all-namespaces

# Delete all resources (pods, services, deployments, etc.) in all namespaces
kubectl delete all --all --all-namespaces
```
Deleting a namespace (including all resources inside it)
If you want to delete an entire namespace, which will also delete all resources inside that namespace:

```
kubectl delete namespace my-namespace
```
Make sure you are cautious with these commands as they will remove all specified resources.

