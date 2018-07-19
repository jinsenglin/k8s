#!/bin/bash

set -e
set -o pipefail

function upgrade_kubeadm() {
    yum install -y kubeadm-1.11.1-0
}

function upgrade_control_plane() {
    kubeadm upgrade apply -y v1.11.1
}

function upgrade_kubelet() {
    yum install -y kubelet-1.11.1-0
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
