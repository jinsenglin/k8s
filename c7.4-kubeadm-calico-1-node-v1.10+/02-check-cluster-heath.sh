#!/bin/bash

set -e
set -o pipefail

function check_helm() {
    helm init
    # tiller pod's status is pending because it doesn't tolerate the taints
    helm reset
}

function check_pod() {
    export KUBECONFIG=/etc/kubernetes/admin.conf
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

function check_node() {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl get node

# All Ready
<<OUTPUT
NAME            STATUS    ROLES     AGE       VERSION
k8s.novalocal   Ready     master    2m        v1.10.5
OUTPUT
}

function check_cluster() {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl cluster-info
}

function check_version() {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl version
}

function main() {
    check_version
    check_cluster
    check_node
    check_pod
    check_helm
}

main
