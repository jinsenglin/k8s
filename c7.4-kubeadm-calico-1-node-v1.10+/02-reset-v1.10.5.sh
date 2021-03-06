#!/bin/bash

set -e
set -o pipefail

function clean_iptables() {
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -t nat -F
    iptables -t mangle -F
    iptables -F
    iptables -X
}

function main() {
    kubeadm reset
    clean_iptables
}

main
