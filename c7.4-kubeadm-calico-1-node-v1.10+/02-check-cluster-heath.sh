#!/bin/bash

set -e
set -o pipefail

function main() {
    kubectl --kubeconfig /etc/kubernetes/admin.conf get node
}

main
