#!/bin/bash


RED='\033[0;31m'
NC='\033[0m'


# Check permission

if [ "$EUID" -ne 0 ]
  then echo -e "${RED}Please run as root ${NC}"
  exit
fi


# update yum
echo -e "${RED}UPDATE YUM${NC}"
yum update -y

# Stop Firewalld
echo -e "${RED}TURN OFF FIREWALLD${NC}"
systemctl stop firewalld
systemctl disable firewalld

# uninstall old version docker
echo -e "${RED}REMOVING OLD VERSION DOCKER${NC}"
yum remove -y docker \
docker-client \
docker-client-latest \
docker-common \
docker-latest \
docker-latest-logrotate \
docker-logrotate \
docker-selinux \
docker-engine-selinux \
docker-engine

# SETUP THE REPOSITORY

## Install Required Packages
echo -e "${RED}INSTALL REQUIRED PACKAGES${NC}"
yum install -y yum-utils \
device-mapper-persistent-data \
lvm2

## Setup Repository
echo -e "${RED}SETUP REPOSITORY${NC}"
yum-config-manager \
--add-repo \
https://download.docker.com/linux/centos/docker-ce.repo


# Install Docker
echo -e "${RED}INSTALL DOCKER${NC}"
yum install -y docker-ce

# Start Docker
echo -e "${RED}START DOCKER${NC}"
systemctl start docker
systemctl enable docker

# Add User To Docker Group
echo -e "${RED}ADD CURRENT USER INTO DOCKER GROUP${NC}"
usermod -aG docker $USER

# INSTALL KUBERNETES
echo -e "${RED}INSTALL KUBERNETES${NC}"
bash -c 'cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF'

# Disable Security Linux
echo -e "${RED}TURN OFF SELINUX${NC}"
/sbin/setenforce 0

# Disable SWAP
echo -e "${RED}DISABLE SWAP${NC}"
/sbin/swapoff -a

# Set IP Forward
echo -e "${RED}SET IP FORWARDING${NC}"
echo -e 1 > /proc/sys/net/ipv4/ip_forward

# Network Setting
echo -e "${RED}SET NETWORK CONFIGURATION${NC}"
bash -c 'cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF'
sysctl --system

# Install Kubernetes
echo -e "${RED}INSTALL KUBERNETES${NC}"
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# Start kubelet
echo -e "${RED}START KUBELET${NC}"
systemctl daemon-reload
systemctl restart kubelet
systemctl enable kubelet


