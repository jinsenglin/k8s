#!/bin/bash

set -e
set -o pipefail

function upgrade_kubeadm() {
    # export VERSION=$(curl -sSL https://dl.k8s.io/release/stable.txt) # or manually specify a released Kubernetes version
    export VERSION=v1.11.1

    export ARCH=amd64 # or: arm, arm64, ppc64le, s390x
    curl -sSL https://dl.k8s.io/release/${VERSION}/bin/linux/${ARCH}/kubeadm > /usr/bin/kubeadm
    chmod a+rx /usr/bin/kubeadm

    kubeadm version
}

function upgrade_control_plane() {
    kubeadm upgrade apply -y --feature-gates=CoreDNS=false v1.11.1
}

function upgrade_kubelet() {
    yum upgrade -y kubelet-1.11.1-0
}

function upgrade_kubectl() {
    yum install -y kubectl-1.11.1-0
}

function main() {
    upgrade_kubeadm
    upgrade_control_plane
    upgrade_kubelet
    upgrade_kubectl
}

main
