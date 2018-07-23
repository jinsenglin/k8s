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

Installed Helm Releases

```
NAME                                REVISION    UPDATED                     STATUS      CHART                           NAMESPACE
fluent-bit-release                  1           Mon Jul 23 05:44:59 2018    DEPLOYED    fluent-bit-0.6.0                add-on   
kube-state-metrics-release          1           Mon Jul 23 06:50:38 2018    DEPLOYED    kube-state-metrics-0.8.1        add-on   
metrics-server-release              1           Mon Jul 23 06:48:37 2018    DEPLOYED    metrics-server-0.0.2            add-on   
nfs-provisioner-release             1           Mon Jul 23 03:38:53 2018    DEPLOYED    nfs-server-provisioner-0.1.5    add-on   
nginx-ingress-release               1           Mon Jul 23 03:40:03 2018    DEPLOYED    nginx-ingress-0.23.0            add-on   
prometheus-node-exporter-release    1           Mon Jul 23 06:53:40 2018    DEPLOYED    prometheus-node-exporter-0.2.0  add-on   
```

# Additional Resources

* [centos7使用kubeadm安装kubernetes 1.11版本多主高可用](https://www.kubernetes.org.cn/4256.html)
* [Kubernetes v1.11.x HA 全手動苦工安裝教學](https://kairen.github.io/2018/07/09/kubernetes/deploy/manual-v1.11/)
* [Export Kubernetes' events to Elasticsearch](https://github.com/alauda/event-exporter)
