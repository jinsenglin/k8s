#!/bin/bash

set -e
set -o pipefail

function main() {
    kubectl --kubeconfig /etc/kubernetes/admin.conf cluster-info

    kubectl --kubeconfig /etc/kubernetes/admin.conf get node

# All Ready
<<OUTPUT
NAME            STATUS    ROLES     AGE       VERSION
k8s.novalocal   Ready     master    2m        v1.10.5
OUTPUT

    kubectl --kubeconfig /etc/kubernetes/admin.conf get po -n kube-system

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
