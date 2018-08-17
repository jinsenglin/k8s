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

haproxy (http/https) * ingress (http/https) * svc (http/https) = 8 combinations

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

Pulled Docker Images

```
REPOSITORY                                                       TAG                  IMAGE ID            CREATED             SIZE
k8s.gcr.io/kube-proxy-amd64                                      v1.11.1              d5c25579d0ff        7 days ago          97.8MB
k8s.gcr.io/kube-apiserver-amd64                                  v1.11.1              816332bd9d11        7 days ago          187MB
k8s.gcr.io/kube-scheduler-amd64                                  v1.11.1              272b3a60cd68        7 days ago          56.8MB
k8s.gcr.io/kube-controller-manager-amd64                         v1.11.1              52096ee87d0e        7 days ago          155MB
nginx                                                            1.14.0               8ae4d16b741a        8 days ago          109MB
ubuntu                                                           latest               74f8760a2a8b        8 days ago          82.4MB
busybox                                                          latest               22c2dd5ee85d        8 days ago          1.16MB
gcr.io/kubeflow-images-public/centraldashboard                   v0.2.1               28709f907c23        2 weeks ago         376MB
gcr.io/kubeflow-images-public/tensorflow-1.8.0-notebook-cpu      v0.2.1               36e1ae29232d        2 weeks ago         4.11GB
alpine                                                           3.7                  791c3e2ebfcb        2 weeks ago         4.2MB
nginx                                                            1.15.0               5699ececb21c        4 weeks ago         109MB
gcr.io/kubeflow-images-public/tf_operator                        v0.2.0               482bc6b1f3e1        5 weeks ago         800MB
centos                                                           latest               49f7960eb7e4        7 weeks ago         200MB
gcr.io/kubeflow/jupyterhub-k8s                                   v20180531-3bb991b1   f3c9c0973f76        7 weeks ago         780MB
quay.io/calico/node                                              v3.1.3               7eca10056c8e        7 weeks ago         248MB
quay.io/calico/cni                                               v3.1.3               9f355e076ea7        7 weeks ago         68.8MB
k8s.gcr.io/coredns                                               1.1.3                b3b94275d97c        2 months ago        45.6MB
quay.io/kubernetes-ingress-controller/nginx-ingress-controller   0.15.0               c46bc3e1b53c        2 months ago        265MB
gcr.io/kubernetes-helm/tiller                                    v2.9.1               6253045f26c6        2 months ago        36.1MB
fluent/fluent-bit                                                0.13.0               fe7b4bb55ddc        2 months ago        96.6MB
quay.io/coreos/kube-state-metrics                                v1.3.1               a9c8f313b7aa        3 months ago        22.2MB
k8s.gcr.io/etcd-amd64                                            3.2.18               b8df3b177be2        3 months ago        219MB
golang                                                           1.10.1-alpine3.7     52d894fca6d4        3 months ago        376MB
quay.io/datawire/statsd                                          0.30.1               aa4a9dba9613        4 months ago        75.4MB
quay.io/datawire/ambassador                                      0.30.1               0d265435bf12        4 months ago        113MB
k8s.gcr.io/kubernetes-dashboard-amd64                            v1.8.3               0c60bcf89900        5 months ago        102MB
nginxdemos/hello                                                 plain-text           e6797a8b6cd5        5 months ago        16.8MB
quay.io/kubernetes_incubator/nfs-provisioner                     v1.0.9               53c948301d39        7 months ago        332MB
k8s.gcr.io/pause                                                 3.1                  da86e6ba6ca1        7 months ago        742kB
gcr.io/google_containers/metrics-server-amd64                    v0.2.1               9801395070f3        7 months ago        42.5MB
quay.io/prometheus/node-exporter                                 v0.15.2              ff5ecdcfc4a2        7 months ago        22.8MB
k8s.gcr.io/defaultbackend                                        1.3                  a70ad572a50f        17 months ago       3.62MB
```

Inspect etcd

```
export ETCDCTL_API=3
etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/apiserver-etcd-client.crt --key=/etc/kubernetes/pki/apiserver-etcd-client.key endpoint status
etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/apiserver-etcd-client.crt --key=/etc/kubernetes/pki/apiserver-etcd-client.key endpoint health

etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/apiserver-etcd-client.crt --key=/etc/kubernetes/pki/apiserver-etcd-client.key get / --prefix --keys-only
etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/apiserver-etcd-client.crt --key=/etc/kubernetes/pki/apiserver-etcd-client.key get / --prefix
```

Backup etcd

```
export ETCDCTL_API=3
etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/apiserver-etcd-client.crt --key=/etc/kubernetes/pki/apiserver-etcd-client.key snapshot save etcd-snapshot.db
```

Restore etcd

```
export ETCDCTL_API=3
etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/apiserver-etcd-client.crt --key=/etc/kubernetes/pki/apiserver-etcd-client.key snapshot restore etcd-snapshot.db
rm -rf /var/lib/etcd && mv default.etcd /var/lib/etcd
```

# Additional Resources

* [centos7使用kubeadm安装kubernetes 1.11版本多主高可用](https://www.kubernetes.org.cn/4256.html)
* [Kubernetes v1.11.x HA 全手動苦工安裝教學](https://kairen.github.io/2018/07/09/kubernetes/deploy/manual-v1.11/)
* [Export Kubernetes' events to Elasticsearch](https://github.com/alauda/event-exporter)
