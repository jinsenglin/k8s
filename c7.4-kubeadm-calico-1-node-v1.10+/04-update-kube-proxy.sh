#!/bin/bash

set -e
set -o pipefail

function enable_ipvs_based_proxy() {
    yum -y install ipvsadm
    touch /etc/sysconfig/ipvsadm
    systemctl enable ipvsadm && systemctl start ipvsadm

    modprobe ip_vs
    modprobe ip_vs_rr
    modprobe ip_vs_wrr
    modprobe ip_vs_sh
    modprobe nf_conntrack

    export KUBECONFIG=/etc/kubernetes/admin.conf
    podname=$(kubectl -n kube-system get po -l k8s-app=kube-proxy -o jsonpath={.items[0].metadata.name})
    kubectl -n kube-system delete po $podname

    # logs show something wrong
    # kubectl -n kube-system logs $podname
}

function main() {
    enable_ipvs_based_proxy
}

main
