#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

sudo sysctl net.ipv4.ip_forward=1

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
EOF

sudo modprobe overlay

sudo apt-get update
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

{
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
}

sudo apt-get update
sudo apt-get -y install containerd.io

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

sudo sed -i "s/SystemdCgroup = false/SystemdCgroup = true/g" /etc/containerd/config.toml
sudo sed -i "s/pause:3.8/pause:3.10/g" /etc/containerd/config.toml

sudo systemctl restart containerd

export K8S_MINOR_VERSION=1.33 # K8S_MINOR_VERSION tag

curl -fsSL https://pkgs.k8s.io/core:/stable:/v$K8S_MINOR_VERSION/deb/Release.key | sudo gpg --dearmor --yes --batch -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_MINOR_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

export K8S_VERSION=1.33.4 # K8S_VERSION tag
sudo apt-get install -y kubelet=$K8S_VERSION-1.1 kubeadm=$K8S_VERSION-1.1 kubectl=$K8S_VERSION-1.1
sudo apt-mark hold kubelet kubeadm kubectl


kubectl version --client=true
kubeadm version
kubelet --version
