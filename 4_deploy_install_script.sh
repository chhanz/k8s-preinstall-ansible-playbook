#!/bin/bash

scp kubeadm-config_master2.yaml root@cp2.demo.com:/root/
scp kubeadm-config_master3.yaml root@cp3.demo.com:/root/
scp node2_deploy.sh root@cp2.demo.com:/root/
scp node3_deploy.sh root@cp3.demo.com:/root/
