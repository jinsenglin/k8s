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

logs pipeline starts from docker

metrics pipeline starts from kubelet (cadvisor)

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
fluent-bit-release                  1           Thu Aug 23 10:53:39 2018    DEPLOYED    fluent-bit-0.9.0                add-on   
kube-state-metrics-release          1           Thu Aug 23 11:10:34 2018    DEPLOYED    kube-state-metrics-0.8.1        add-on   
metrics-server-release              1           Thu Aug 23 10:56:37 2018    DEPLOYED    metrics-server-1.1.0            add-on   
nfs-provisioner-release             1           Thu Aug 23 11:09:57 2018    DEPLOYED    nfs-server-provisioner-0.1.5    add-on   
nginx-ingress-release               2           Thu Aug 23 10:40:47 2018    DEPLOYED    nginx-ingress-0.25.1            add-on   
prometheus-node-exporter-release    1           Thu Aug 23 10:57:49 2018    DEPLOYED    prometheus-node-exporter-0.3.0  add-on   
```

Pulled Docker Images

```
REPOSITORY                                                       TAG                 IMAGE ID            CREATED             SIZE
k8scloudprovider/k8s-keystone-auth                               latest              e48cd8d0c44d        20 hours ago        26.9MB
k8s.gcr.io/kube-controller-manager-amd64                         v1.11.2             38521457c799        2 weeks ago         155MB
k8s.gcr.io/kube-apiserver-amd64                                  v1.11.2             821507941e9c        2 weeks ago         187MB
k8s.gcr.io/kube-proxy-amd64                                      v1.11.2             46a3cd725628        2 weeks ago         97.8MB
k8s.gcr.io/kube-scheduler-amd64                                  v1.11.2             37a1403e6c1a        2 weeks ago         56.8MB
quay.io/kubernetes-ingress-controller/nginx-ingress-controller   0.17.1              8410cbcd825d        5 weeks ago         360MB
nginx                                                            stable              8ae4d16b741a        5 weeks ago         109MB
quay.io/calico/node                                              v3.1.3              7eca10056c8e        2 months ago        248MB
quay.io/calico/cni                                               v3.1.3              9f355e076ea7        2 months ago        68.8MB
k8s.gcr.io/coredns                                               1.1.3               b3b94275d97c        3 months ago        45.6MB
gcr.io/kubernetes-helm/tiller                                    v2.9.1              6253045f26c6        3 months ago        36.1MB
fluent/fluent-bit                                                0.13.0              fe7b4bb55ddc        3 months ago        96.6MB
quay.io/coreos/kube-state-metrics                                v1.3.1              a9c8f313b7aa        4 months ago        22.2MB
k8s.gcr.io/etcd-amd64                                            3.2.18              b8df3b177be2        4 months ago        219MB
quay.io/kubernetes_incubator/nfs-provisioner                     v1.0.9              53c948301d39        8 months ago        332MB
k8s.gcr.io/pause                                                 3.1                 da86e6ba6ca1        8 months ago        742kB
gcr.io/google_containers/metrics-server-amd64                    v0.2.1              9801395070f3        8 months ago        42.5MB
quay.io/prometheus/node-exporter                                 v0.15.2             ff5ecdcfc4a2        8 months ago        22.8MB
k8s.gcr.io/defaultbackend                                        1.4                 846921f0fe0e        10 months ago       4.84MB
stephenhsu/keystone                                              9.1.0               60ab60813d93        18 months ago       1.09GB
```

Inspect etcd

```
export ETCDCTL_API=3
etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/apiserver-etcd-client.crt --key=/etc/kubernetes/pki/apiserver-etcd-client.key endpoint status
etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/apiserver-etcd-client.crt --key=/etc/kubernetes/pki/apiserver-etcd-client.key endpoint health

etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/apiserver-etcd-client.crt --key=/etc/kubernetes/pki/apiserver-etcd-client.key get / --prefix --keys-only
etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/apiserver-etcd-client.crt --key=/etc/kubernetes/pki/apiserver-etcd-client.key get / --prefix
```
# Additional Resources

* [centos7使用kubeadm安装kubernetes 1.11版本多主高可用](https://www.kubernetes.org.cn/4256.html)
* [Kubernetes v1.11.x HA 全手動苦工安裝教學](https://kairen.github.io/2018/07/09/kubernetes/deploy/manual-v1.11/)
* [Export Kubernetes' events to Elasticsearch](https://github.com/alauda/event-exporter)
