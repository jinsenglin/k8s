# Note

setup client/management node is out of this scope.

# Usage

Step 1: bring-up-5-machines-1-vip.sh

Step 2: push 'rc' file to git server

Step 3: remote-runner-wrapper.sh git_clone

Step 4: remote-runner-wrapper.sh copy_pkgs

Step 5: remote-runner-wrapper.sh configure

Step 6: copy kubeconfig file from k8s-master1 then change server IP "$PIP1:6443" with "$PIP0:8443"

# Diff Info

Linux version: CentOS 7.3.1611 vs. 16.04.2 LTS (Xenial Xerus)

docker version: 1.12.6 vs. ce 17.09

kubeadm version: v1.7.0 vs. 1.8.0

kubelet version: v1.7.0 vs. 1.8.0

container images versions:

(required)
gcr.io/google_containers/kube-proxy-amd64 v1.7.0 vs. v1.8.2
gcr.io/google_containers/kube-apiserver-amd64 v1.7.0 vs. v1.8.2
gcr.io/google_containers/kube-controller-manager-amd64 v1.7.0 vs. v1.8.2
gcr.io/google_containers/kube-scheduler-amd64 v1.7.0 vs. v1.8.2
gcr.io/google_containers/k8s-dns-sidecar-amd64 1.14.4 vs. 1.14.5
gcr.io/google_containers/k8s-dns-kube-dns-amd64 1.14.4 vs. 1.14.5
gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64 1.14.4 vs. 1.14.5
nginx latest vs. latest
quay.io/coreos/flannel v0.7.1-amd64 vs. v0.8.0-amd64
gcr.io/google_containers/etcd-amd64 3.0.17 vs. 3.0.17
gcr.io/google_containers/pause-amd64 3.0 vs. 3.0

(option)
gcr.io/google_containers/kubernetes-dashboard-amd64 v1.6.1 vs. 1.7.1
gcr.io/google_containers/heapster-amd64 v1.3.0 vs. 1.4.3
gcr.io/google_containers/heapster-grafana-amd64 v4.0.2 vs. 4.4.3
gcr.io/google_containers/heapster-influxdb-amd64 v1.1.1 vs. 1.3.3

# e2e Tests

```pass
kubectl run hello-nginx --image=nginx:latest --replicas=1 --port=80
kubectl get po -o wide

kubectl delete deployment hello-nginx
kubectl get po -o wide
```

```
openstack server suspend $M1

kubectl get node # $M1 -> NotReady

kubectl run hello-nginx --image=nginx:latest --replicas=1 --port=80
kubectl get po -o wide

kubectl delete deployment hello-nginx
kubectl get po -o wide

openstack server resume $M1
```

```
openstack server suspend $M2

kubectl get node # $M2 -> NotReady

kubectl run hello-nginx --image=nginx:latest --replicas=1 --port=80
kubectl get po -o wide

kubectl delete deployment hello-nginx
kubectl get po -o wide

openstack server resume $M2
```

```
openstack server suspend $M3

kubectl get node # $M3 -> NotReady

kubectl run hello-nginx --image=nginx:latest --replicas=1 --port=80
kubectl get po -o wide

kubectl delete deployment hello-nginx
kubectl get po -o wide

openstack server resume $M3
```

```
openstack server suspend $M4

kubectl get node # $M4 -> NotReady

kubectl run hello-nginx --image=nginx:latest --replicas=1 --port=80
kubectl get po -o wide

kubectl delete deployment hello-nginx
kubectl get po -o wide

openstack server resume $M4
```

```
openstack server suspend $M5

kubectl get node # $M5 -> NotReady

kubectl run hello-nginx --image=nginx:latest --replicas=1 --port=80
kubectl get po -o wide

kubectl delete deployment hello-nginx
kubectl get po -o wide

openstack server resume $M5
```
