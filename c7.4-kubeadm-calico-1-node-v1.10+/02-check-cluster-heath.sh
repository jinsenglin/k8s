#!/bin/bash

set -e
set -o pipefail

function main() {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl version
    kubectl cluster-info
    kubectl get node

# All Ready
<<OUTPUT
NAME            STATUS    ROLES     AGE       VERSION
k8s.novalocal   Ready     master    2m        v1.10.5
OUTPUT

    kubectl -n kube-system get po

# All Running
<<OUTPUT
NAME                                    READY     STATUS    RESTARTS   AGE
calico-node-zgfm4                       2/2       Running   0          1m
etcd-k8s.novalocal                      1/1       Running   0          51s
kube-apiserver-k8s.novalocal            1/1       Running   0          52s
kube-controller-manager-k8s.novalocal   1/1       Running   0          48s
kube-dns-86f4d74b45-hm25m               3/3       Running   0          1m
kube-proxy-fxd7z                        1/1       Running   0          1m
kube-scheduler-k8s.novalocal            1/1       Running   0          35s
OUTPUT
}

main
