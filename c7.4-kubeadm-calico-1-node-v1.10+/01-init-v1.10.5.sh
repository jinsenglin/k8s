#!/bin/bash

set -e
set -o pipefail

function pin_version() {
    if [ $(kubeadm init --dry-run 2>&1 | head -n 1 | awk '{print $5}') == "v1.10.5" ]; then
        echo "pin k8s version [ ok ]"
    else
        echo "pin k8s version [ failed ]"
        exit 1
    fi
}

function init_cluster() {
    kubeadm init --pod-network-cidr=192.168.0.0/16
}

function init_pod_network() {
    kubectl apply --kubeconfig /etc/kubernetes/admin.conf -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
    kubectl apply --kubeconfig /etc/kubernetes/admin.conf -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
}

function main() {
    pin_version
    init_cluster
    init_pod_network
}

main
