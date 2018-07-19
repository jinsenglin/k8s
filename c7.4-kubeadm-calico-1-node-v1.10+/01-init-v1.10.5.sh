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

function main() {
    pin_version
    kubeadm init --pod-network-cidr=192.168.0.0/16
}

main
