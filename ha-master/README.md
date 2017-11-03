# Usage

Step 1: bring-up-5-machines-1-vip.sh

Step 2: push 'rc' file to git server

Step 3: remote-runner-wrapper.sh git_clone

Step 4: remote-runner-wrapper.sh copy_pkgs

Step 5: remote-runner-wrapper.sh configure

# Diff Info

Linux version: CentOS 7.3.1611 vs. 16.04.2 LTS (Xenial Xerus)

docker version: 1.12.6 vs. ce 17.09

kubeadm version: v1.7.0 vs. 1.8.0

kubelet version: v1.7.0 vs. 1.8.0

container images versions:

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
gcr.io/google_containers/kubernetes-dashboard-amd64 v1.6.1 vs. ?
gcr.io/google_containers/heapster-amd64 v1.3.0 vs. ?
gcr.io/google_containers/heapster-grafana-amd64 v4.0.2 vs. ?
gcr.io/google_containers/heapster-influxdb-amd64 v1.1.1 vs. ?

# e2e Tests

```
kubectl run hello-nginx --image=nginx:latest --replicas=1 --port=80
kubectl get po -o wide

kubectl delete deployment hello-nginx
kubectl get po -o wide
```

```
openstack server suspend $M1

kubectl get node # FAILED. STILL READY

kubectl run hello-nginx --image=nginx:latest --replicas=1 --port=80
kubectl get po -o wide # FAILED. NOT FOUND

kubectl delete deployment hello-nginx
kubectl get po -o wide

openstack server resume $M1
```

```
openstack server stop $M1

kubectl get node

kubectl run hello-nginx --image=nginx:latest --replicas=1 --port=80
kubectl get po -o wide # FAILED. PENDING

kubectl delete deployment hello-nginx
kubectl get po -o wide

openstack server start $M1
```
