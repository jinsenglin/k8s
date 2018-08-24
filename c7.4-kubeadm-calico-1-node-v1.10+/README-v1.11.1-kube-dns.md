# Lab

network plan

* calico pod network 192.168.0.0/16 (default)
* service-cluster-ip-range 10.96.0.0/12 (default)
* -> vm network 10.112.0.0/12

machines

* k8s
  * 4C8G50G
  * 10.112.0.10 (192.168.240.23), dns 8.8.8.8
  * hostname: k8s
* k8s-ext-lb
  * 1C1G5G
  * 10.112.0.4 (192.168.240.57), dns 8.8.8.8
* k8s-ext-es
  * 4C8G50G
  * 10.112.0.3 (192.168.240.63), dns 8.8.8.8

# Note

service-node-port-range 30000-32767 (default)

haproxy (http/https) * ingress (http/https) * svc (http/https) = 8 combinations

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
