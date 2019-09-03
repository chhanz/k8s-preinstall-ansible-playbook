#!/bin/bash

kubeadm init --config kubeadm-config_master1.yaml

echo "Default Config"
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

