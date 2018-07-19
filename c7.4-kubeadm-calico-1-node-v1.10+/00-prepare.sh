#!/bin/bash

set -e
set -o pipefail

function noswap() {
    if [ $(cat /proc/swaps | wc -l) -eq 1 ]; then
        echo "no swap [ ok ]"
    else
        echo "no swap [ failed ]"
        exit 1
    fi
}

function noselinux() {
    if [ $(getenforce) == "Permissive" ]; then
        echo "no selinux [ ok ]"
    else
        echo "no selinux [ failed ]"
        exit 1
    fi
}

function nofirewall() {
    if [ $(iptables -L | wc -l) -eq 8 ]; then
        echo "no firewall::filter [ ok ]"
    else
        echo "no firewall::filter [ failed ]"
        exit 1
    fi

    if [ $(iptables -t nat -L | wc -l) -eq 11 ]; then
        echo "no firewall::nat [ ok ]"
    else
        echo "no firewall::nat [ failed ]"
        exit 1
    fi
}

function enable_docker() {
    yum install -y docker
    systemctl enable docker && systemctl start docker

<<VERSION
Client:
 Version:         1.13.1
 API version:     1.26
 Package version: docker-1.13.1-68.gitdded712.el7.centos.x86_64
 Go version:      go1.9.4
 Git commit:      dded712/1.13.1
 Built:           Tue Jul 17 18:34:48 2018
 OS/Arch:         linux/amd64

Server:
 Version:         1.13.1
 API version:     1.26 (minimum version 1.12)
 Package version: docker-1.13.1-68.gitdded712.el7.centos.x86_64
 Go version:      go1.9.4
 Git commit:      dded712/1.13.1
 Built:           Tue Jul 17 18:34:48 2018
 OS/Arch:         linux/amd64
 Experimental:    false
VERSION
}

function main() {
    noswap
    noselinux
    nofirewall
    enable_docker
}

main
