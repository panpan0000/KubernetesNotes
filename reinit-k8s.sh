#!/bin/bash
#######################
# This is a script to help you to `re-start` K8S master
########################
MASTER_IP=$1



sudo kubeadm reset
sudo ifconfig  cni0 down
sudo brctl delbr cni0
sudo ip link delete flannel.1
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address $MASTER_IP 
rm -r $HOME/.kube/config
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/k8s-manifests/kube-flannel-rbac.yml
#kubectl create -f ~/kubernetes-dashboard.yaml
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
#kubectl create -f ~/admin-role.yaml
kubectl create -f https://raw.githubusercontent.com/rootsongjc/kubernetes-handbook/master/manifests/dashboard-1.7.1/admin-role.yaml

git clone https://github.com/kubernetes/heapster.git
cd heapster
kubectl create -f deploy/kube-config/influxdb/
kubectl create -f deploy/kube-config/rbac/heapster-rbac.yaml
cd ..

echo ==========================
CA=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')
echo CA = $CA
echo ===========================
TOKEN=$(sudo kubeadm token list)
echo Boostrap token= $TOKEN
echo --------------------------
ADMIN_TOKEN=$(kubectl -n kube-system describe secret `kubectl -n kube-system get secret|grep admin-token|cut -d " " -f1`|grep "token:"|tr -s " "|cut -d " " -f2)
echo admin toekn = $ADMIN_TOKEN


