# k8s-install-script

+ File list (v1.15.3)
```console
├── README.md 
├── inventory
├── old_bash-1.12                         ## Old Bash Script (v1.12)
│   ├── 0_preinstall_base.sh
│   ├── 1_mk_master.yml
│   ├── 2_master1_install.sh
│   ├── 3_deploy_key.sh
│   ├── 4_deploy_install_script.sh
│   ├── 5_network_plugin.sh 
│   ├── kube-flannel.yml
│   ├── kubeadm-config_master1.yaml
│   ├── kubeadm-config_master2.yaml
│   ├── kubeadm-config_master3.yaml
│   ├── node2_deploy.sh
│   └── node3_deploy.sh
└── preinstall.yaml                       ## Preinstaller (ansible)

1 directory, 15 files
```

## Kubernetes Preinstaller
### Change Inventory (3 node example)
```console
[all]  
fastvm-centos-7-6-22    ansible_host=192.168.200.22
fastvm-centos-7-6-23    ansible_host=192.168.200.23
fastvm-centos-7-6-24    ansible_host=192.168.200.24

[all:vars]
ansible_ssh_user=root
ansible_ssh_pass=password
docker_package_version=docker-ce-18.06.1.ce
kubernetes_package_version=1.15.3-0
```

### Use 
```bash
$ ansible-playbook -i inventory preinstall.yaml
```
### Complete 
* Example
<center><img src="/assets/image1.png" style="max-width: 100%; height: auto;"></center>   

```bash
$ reboot
```
***Please `Reboot` System.***

## Create Example Kubernetes Cluster ( 1 Master, 2 Worker)

### Initializing control-plane node
```bash
$ kubeadm init --apiserver-advertise-address=<<control-plane node IP>>
```
* Example
<center><img src="/assets/image2.png" style="max-width: 100%; height: auto;"></center>   

* Create `kubeconfig`
```console
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
```

### Installing a pod network add-on
Recommend Document : [https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)

* Example - Calico CNI
```bash
# kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml 
configmap/calico-config created 
customresourcedefinition.apiextensions.k8s.io/felixconfigurations.crd.projectcalico.org created 
customresourcedefinition.apiextensions.k8s.io/ipamblocks.crd.projectcalico.org created 
customresourcedefinition.apiextensions.k8s.io/blockaffinities.crd.projectcalico.org created 
customresourcedefinition.apiextensions.k8s.io/ipamhandles.crd.projectcalico.org created 
customresourcedefinition.apiextensions.k8s.io/ipamconfigs.crd.projectcalico.org created 
customresourcedefinition.apiextensions.k8s.io/bgppeers.crd.projectcalico.org created 
customresourcedefinition.apiextensions.k8s.io/bgpconfigurations.crd.projectcalico.org created 
customresourcedefinition.apiextensions.k8s.io/ippools.crd.projectcalico.org created 
customresourcedefinition.apiextensions.k8s.io/hostendpoints.crd.projectcalico.org created 
customresourcedefinition.apiextensions.k8s.io/clusterinformations.crd.projectcalico.org created 
customresourcedefinition.apiextensions.k8s.io/globalnetworkpolicies.crd.projectcalico.org created 
customresourcedefinition.apiextensions.k8s.io/globalnetworksets.crd.projectcalico.org created 
customresourcedefinition.apiextensions.k8s.io/networkpolicies.crd.projectcalico.org created 
customresourcedefinition.apiextensions.k8s.io/networksets.crd.projectcalico.org created 
clusterrole.rbac.authorization.k8s.io/calico-kube-controllers created 
clusterrolebinding.rbac.authorization.k8s.io/calico-kube-controllers created 
clusterrole.rbac.authorization.k8s.io/calico-node created
clusterrolebinding.rbac.authorization.k8s.io/calico-node created 
daemonset.apps/calico-node created 
serviceaccount/calico-node created 
deployment.apps/calico-kube-controllers created 
serviceaccount/calico-kube-controllers created
```
* Deploy CNI
```bash
$ kubectl get pod -n kube-system 
NAME                                               READY   STATUS    RESTARTS   AGE 
pod/calico-kube-controllers-65b8787765-brdv7       1/1     Running   0          117s
pod/calico-node-lggxn                              1/1     Running   0          117s
pod/coredns-5c98db65d4-m6svd                       1/1     Running   0          23m
pod/coredns-5c98db65d4-x7gcb                       1/1     Running   0          23m
pod/etcd-fastvm-centos-7-6-22                      1/1     Running   1          22m
pod/kube-apiserver-fastvm-centos-7-6-22            1/1     Running   1          22m
pod/kube-controller-manager-fastvm-centos-7-6-22   1/1     Running   5          22m
pod/kube-proxy-82v78                               1/1     Running   1          23m
pod/kube-scheduler-fastvm-centos-7-6-22            1/1     Running   5          22m
```
 
### Join Worker node
```bash
$ kubeadm join 192.168.200.22:6443 --token cdw8cj.4guf1fr9e7shc7u8 \
  --discovery-token-ca-cert-hash sha256:bc3604fb648338821d84ddf5b5259064ae5ceb2ee159f708d6741b2d1e7c65a2
```
* Example
<center><img src="/assets/image3.png" style="max-width: 100%; height: auto;"></center>   

### Complete Deploy
* Example
<center><img src="/assets/image4.png" style="max-width: 100%; height: auto;"></center>   

### Test Run APP
* run deploy
```bash
$ kubectl run test-httpd --image=httpd  
deployment.apps/test-httpd created 
```

* check status
```bash
$ kubectl get po  
NAME                          READY   STATUS    RESTARTS   AGE 
test-httpd-7dd7c96c8f-hvbzl   1/1     Running   0          31s 
```

* expose service
```bash
$ kubectl expose deployment.apps/test-httpd --port 80 
service/test-httpd exposed 
```

* curl httpd
```bash
$ curl 10.97.176.30 
<html><body><h1>It works!</h1></body></html>
```

# Recommend Document
- [https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
- [https://docs.projectcalico.org/v3.8/getting-started/kubernetes/installation/calico](https://docs.projectcalico.org/v3.8/getting-started/kubernetes/installation/calico)
