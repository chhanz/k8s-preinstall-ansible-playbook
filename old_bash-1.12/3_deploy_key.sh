#!/bin/bash

## master1 > master2,3

echo "Start Scp Key"
echo > /tmp/keyscp.txt

for host in 192.168.13.22 192.168.13.23; do
echo " 	ssh root@$host mkdir -p /etc/kubernetes/pki/etcd" >> /tmp/keyscp.txt
echo "	scp /etc/kubernetes/pki/ca.crt root@$host:/etc/kubernetes/pki/"  >> /tmp/keyscp.txt
echo " 	scp /etc/kubernetes/pki/ca.key root@$host:/etc/kubernetes/pki/"  >> /tmp/keyscp.txt
echo " 	scp /etc/kubernetes/pki/sa.key root@$host:/etc/kubernetes/pki/"  >> /tmp/keyscp.txt
echo " 	scp /etc/kubernetes/pki/sa.pub root@$host:/etc/kubernetes/pki/"  >> /tmp/keyscp.txt
echo "	scp /etc/kubernetes/pki/front-proxy-ca.crt root@$host:/etc/kubernetes/pki/"  >> /tmp/keyscp.txt
echo "	scp /etc/kubernetes/pki/front-proxy-ca.key root@$host:/etc/kubernetes/pki/"  >> /tmp/keyscp.txt
echo "	scp /etc/kubernetes/pki/etcd/ca.crt root@$host:/etc/kubernetes/pki/etcd/"  >> /tmp/keyscp.txt
echo "	scp /etc/kubernetes/pki/etcd/ca.key root@$host:/etc/kubernetes/pki/etcd/"  >> /tmp/keyscp.txt
echo " 	scp /etc/kubernetes/admin.conf	root@$host:/etc/kubernetes/admin.conf"  >> /tmp/keyscp.txt
done

sh -x /tmp/keyscp.txt


