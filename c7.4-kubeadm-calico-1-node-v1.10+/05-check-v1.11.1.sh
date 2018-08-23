#!/bin/bash

set -e
set -o pipefail

function check_helm() {
    export KUBECONFIG=/etc/kubernetes/admin.conf

    #
    # The tiller pod's status is pending because it doesn't tolerate the taints
    #
    # [ option 1: remove the taint ]
    # kubectl taint nodes k8s node-role.kubernetes.io/master-
    #
    # [ option 2: tolerate the taint ]
    #
    kubectl taint nodes k8s node-role.kubernetes.io/master-

    #
    # Error: configmaps is forbidden: User "system:serviceaccount:kube-system:default" cannot list configmaps in the namespace "kube-system"
    #
    # [ option 1: specify service account ]
    # helm init --service-account super-admin
    #
    # [ option 2: permit user "system:serviceaccount:kube-system:default" ]
    #
    source CD-super-admin/func.sh
    create_super_admin

        # installed in the namespace kube-system
        helm init --service-account super-admin
        helm reset

    delete_super_admin
    kubectl taint nodes k8s node-role.kubernetes.io/master=:NoSchedule
}

function check_pod() {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl -n kube-system get po

# All Running
<<OUTPUT
# a. kube-dns

NAME                                    READY     STATUS    RESTARTS   AGE
calico-node-zgfm4                       2/2       Running   0          1m
etcd-k8s.novalocal                      1/1       Running   0          51s
kube-apiserver-k8s                      1/1       Running   0          52s
kube-controller-manager-k8s             1/1       Running   0          48s
kube-dns-86f4d74b45-hm25m               3/3       Running   0          1m
kube-proxy-fxd7z                        1/1       Running   0          1m
kube-scheduler-k8s                      1/1       Running   0          35s

# b. coredns

NAME                                    READY     STATUS    RESTARTS   AGE
calico-node-s47zx                       2/2       Running   0          1m
coredns-78fcdf6894-4b6j6                1/1       Running   0          3m
coredns-78fcdf6894-cwblh                1/1       Running   0          3m
etcd-k8s                                1/1       Running   0          3m
kube-apiserver-k8s                      1/1       Running   0          2m
kube-controller-manager-k8s             1/1       Running   0          2m
kube-proxy-6bh65                        1/1       Running   0          3m
kube-scheduler-k8s                      1/1       Running   0          2m
OUTPUT
}

function check_node() {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl get node

# All Ready
<<OUTPUT
NAME      STATUS    ROLES     AGE       VERSION
k8s       Ready     master    7m        v1.11.1
OUTPUT
}

function check_cluster() {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl cluster-info

<<OUTPUT
Kubernetes master is running at https://192.168.33.8:6443
KubeDNS is running at https://192.168.33.8:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
OUTPUT
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
