#!/bin/bash

set -e
set -o pipefail

function main() {
    kubectl --kubeconfig /etc/kubernetes/admin.conf cluster-info
    kubectl --kubeconfig /etc/kubernetes/admin.conf get node
    kubectl --kubeconfig /etc/kubernetes/admin.conf get po -n kube-system
}

main
