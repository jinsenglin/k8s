# Lab

network plan

* calico pod network 192.168.0.0/16 (default)
* service-cluster-ip-range 10.96.0.0/12 (default)
* -> vm network 10.112.0.0/12

machines

* k8s
  * 4C8G50G
  * 10.112.0.9 (192.168.240.23)
* k8s-ext-lb
  * 1C1G5G
  * 10.112.0.4 (192.168.240.57)
* k8s-ext-es
  * 4C8G50G
  * 10.112.0.3 (192.168.240.63)

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

* "key": "node-role.kubernetes.io/master"
  * "effect": "NoSchedule"

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

Additional Resources

* [centos7使用kubeadm安装kubernetes 1.11版本多主高可用](https://www.kubernetes.org.cn/4256.html)
