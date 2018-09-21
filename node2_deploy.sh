#!/bin/bash


export KUBERNETES_VER=v1.11.3
export LOAD_BALANCER_DNS=cp.demo.com
export LOAD_BALANCER_PORT=6443
export CP1_HOSTNAME=cp1.demo.com
export CP1_IP=192.168.13.61
export CP2_HOSTNAME=cp2.demo.com
export CP2_IP=192.168.13.62
export CP3_HOSTNAME=cp3.demo.com
export CP3_IP=192.168.13.63


systemctl stop kubelet

kubeadm alpha phase certs all --config kubeadm-config_master2.yaml
kubeadm alpha phase kubelet config write-to-disk --config kubeadm-config_master2.yaml
kubeadm alpha phase kubelet write-env-file --config kubeadm-config_master2.yaml
kubeadm alpha phase kubeconfig kubelet --config kubeadm-config_master2.yaml

systemctl start kubelet

export KUBECONFIG=/etc/kubernetes/admin.conf 


kubectl exec -n kube-system etcd-${CP1_HOSTNAME} -- etcdctl --ca-file /etc/kubernetes/pki/etcd/ca.crt --cert-file /etc/kubernetes/pki/etcd/peer.crt --key-file /etc/kubernetes/pki/etcd/peer.key --endpoints=https://${CP1_IP}:2379 member add ${CP1_HOSTNAME} https://${CP2_IP}:2380

kubeadm alpha phase etcd local --config kubeadm-config_master2.yaml
kubeadm alpha phase kubeconfig all --config kubeadm-config_master2.yaml
kubeadm alpha phase controlplane all --config kubeadm-config_master2.yaml
kubeadm alpha phase mark-master --config kubeadm-config_master2.yaml

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

