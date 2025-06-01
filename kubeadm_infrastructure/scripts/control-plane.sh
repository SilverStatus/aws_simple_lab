#!/bin/bash

# Kubernetes Installation Script for Ubuntu 24.04
# Usage: sudo ./install-k8s.sh [master|worker]

set -e

# Validate user is root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

# Check argument
if [[ $# -eq 0 ]]; then
  echo "Usage: $0 [master|worker]"
  exit 1
fi

ROLE=$1
HOSTNAME=$(hostname)

echo "╔══════════════════════════════════════════════╗"
echo "║ Starting Kubernetes Installation ($ROLE)      ║"
echo "╚══════════════════════════════════════════════╝"

# Function to print section headers
section() {
  echo ""
  echo "╓─────[ $1 ]─────╖"
  echo ""
}

# 1. System Preparation
section "System Preparation"
apt update && apt upgrade -y
timedatectl set-timezone UTC

# Disable swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# 2. Kernel Modules
section "Kernel Modules Setup"
cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# 3. Network Configuration
section "Network Configuration"
cat <<EOF | tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system

# 4. Install Containerd
section "Installing Containerd"
apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y containerd.io

# Configure Containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml >/dev/null
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

# 5. Install Kubernetes Components
section "Installing Kubernetes"
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list

apt update
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║ Master Node Setup Complete!                  ║"
echo "║                                              ║"
echo "║ To join worker nodes, use the command:       ║"
echo "║ shown above from 'kubeadm init' output.      ║"
echo "╚══════════════════════════════════════════════╝"