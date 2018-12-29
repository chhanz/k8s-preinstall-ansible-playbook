#!/bin/bash

export KUBERNETES_VER=v1.12.2
export LOAD_BALANCER_DNS=kube.example.com
export LOAD_BALANCER_PORT=6443
export CP1_HOSTNAME=master1.example.com
export CP1_IP=192.168.13.21
export CP2_HOSTNAME=master2.example.com
export CP2_IP=192.168.13.22
export CP3_HOSTNAME=master3.example.com
export CP3_IP=192.168.13.23

scp kubeadm-config_master2.yaml root@$CP2_IP:/root/
scp kubeadm-config_master3.yaml root@$CP3_IP:/root/
scp node2_deploy.sh root@$CP2_IP:/root/
scp node3_deploy.sh root@$CP3_IP:/root/
