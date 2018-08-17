#!/bin/bash

set -e
set -o pipefail

function pin_version() {
    if [ $(kubeadm init --dry-run 2>&1 | head -n 1 | awk '{print $5}') == "v1.11.1" ]; then
        echo "pin k8s version [ ok ]"
    else
        echo "pin k8s version [ failed ]"
        exit 1
    fi
}

function init_cluster() {
    # a.
    # kubeadm init --pod-network-cidr=192.168.0.0/16 --feature-gates=CoreDNS=false

    # b.
    kubeadm init --pod-network-cidr=192.168.0.0/16
    
    # --apiserver-advertise-address 10.112.0.10
}

function init_pod_network() {
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
    kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml

    # To install calico and a single node etcd
    # kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml
}

function main() {
    pin_version
    init_cluster
    init_pod_network
}

main
