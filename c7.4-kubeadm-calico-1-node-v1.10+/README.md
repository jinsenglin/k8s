# Lab

network plan

* calico pod network 192.168.0.0/16 (default)
* service-cluster-ip-range 10.96.0.0/12 (default)
* -> vm network 10.112.0.0/12

machines

* k8s
  * 4C8G50G
  * 10.112.0.10 (192.168.240.23), dns 8.8.8.8
* k8s-ext-lb
  * 1C1G5G
  * 10.112.0.4 (192.168.240.57), dns 8.8.8.8
* k8s-ext-es
  * 4C8G50G
  * 10.112.0.3 (192.168.240.63), dns 8.8.8.8

# Note

service-node-port-range 30000-32767 (default)

# v1.10.5

DaemonSet

* calico-node
* kube-proxy

Deployment

* kube-dns

Static Pod

* etcd
* kube-apiserver
* kube-controller-manager
* kube-scheduler

Native Process

* kubelet

# v1.11.1 (a. kube-dns)

Node Taints

* "key": "node-role.kubernetes.io/master"
  * "effect": "NoSchedule"

DaemonSet

* calico-node
* kube-proxy

Deployment

* kube-dns

Static Pod

* etcd
* kube-apiserver
* kube-controller-manager
* kube-scheduler

Native Process

* kubelet

# v1.11.1 (b. coredns)

Node Taints

* "key": "node-role.kubernetes.io/master"
  * "effect": "NoSchedule"

DaemonSet

* calico-node
* kube-proxy

Deployment

* coredns

Static Pod

* etcd
* kube-apiserver
* kube-controller-manager
* kube-scheduler

Native Process

* kubelet

# Additional Resources

* [centos7使用kubeadm安装kubernetes 1.11版本多主高可用](https://www.kubernetes.org.cn/4256.html)
* [Kubernetes v1.11.x HA 全手動苦工安裝教學](https://kairen.github.io/2018/07/09/kubernetes/deploy/manual-v1.11/)
* [Export Kubernetes' events to Elasticsearch](https://github.com/alauda/event-exporter)
