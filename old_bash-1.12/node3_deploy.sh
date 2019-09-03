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

systemctl stop kubelet

kubeadm alpha phase certs all --config kubeadm-config_master3.yaml
kubeadm alpha phase kubelet config write-to-disk --config kubeadm-config_master3.yaml
kubeadm alpha phase kubelet write-env-file --config kubeadm-config_master3.yaml
kubeadm alpha phase kubeconfig kubelet --config kubeadm-config_master3.yaml

systemctl start kubelet

export KUBECONFIG=/etc/kubernetes/admin.conf 

kubectl exec -n kube-system etcd-${CP1_HOSTNAME} -- etcdctl --ca-file /etc/kubernetes/pki/etcd/ca.crt --cert-file /etc/kubernetes/pki/etcd/peer.crt --key-file /etc/kubernetes/pki/etcd/peer.key --endpoints=https://${CP1_IP}:2379 member add ${CP3_HOSTNAME} https://${CP3_IP}:2380

kubeadm alpha phase etcd local --config kubeadm-config_master3.yaml
kubeadm alpha phase kubeconfig all --config kubeadm-config_master3.yaml
kubeadm alpha phase controlplane all --config kubeadm-config_master3.yaml
kubeadm alpha phase mark-master --config kubeadm-config_master3.yaml

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

