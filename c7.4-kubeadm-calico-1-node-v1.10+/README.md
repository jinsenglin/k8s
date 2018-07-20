# Note

calico will make OpenStack floating IP connection broken.

# v1.10.5

DaemonSet

* calico-node
* kube-proxy

Deployment

* kube-dns

Static Pod

* kube-apiserver
* kube-controller-manager
* kube-scheduler

Native Process

* kubelet

Native Docker Container

* etcd

# v1.11.1

Node Taints

* "effect": "NoSchedule"
* "key": "node-role.kubernetes.io/master"

DaemonSet

* calico-node
* kube-proxy

Deployment

* kube-dns

Static Pod

* kube-apiserver
* kube-controller-manager
* kube-scheduler

Native Process

* kubelet

Native Docker Container

* etcd

Reference

* [centos7使用kubeadm安装kubernetes 1.11版本多主高可用](https://www.kubernetes.org.cn/4256.html)
