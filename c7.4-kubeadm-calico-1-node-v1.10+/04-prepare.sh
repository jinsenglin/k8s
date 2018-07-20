#!/bin/bash

set -e
set -o pipefail

function enable_ipvs() {
    yum -y install ipvsadm
    touch /etc/sysconfig/ipvsadm
    systemctl enable ipvsadm && systemctl start ipvsadm

    modprobe ip_vs
    modprobe ip_vs_rr
    modprobe ip_vs_wrr
    modprobe ip_vs_sh
    modprobe nf_conntrack
}

function main() {
    enable_ipvs
}

main
