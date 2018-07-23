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

function enable_bridge_nf_call_iptables() {
    cat <<EOF >  /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

    sysctl --system
}

function enable_docker() {
    yum install -y docker
    systemctl enable docker && systemctl start docker

    # WARNING : this version is too old to use multi-stage builds
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

function enable_kubelet() {
    cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

    yum install -y kubectl-1.10.5-0 kubeadm-1.10.5-0 kubelet-1.10.5-0 # MUST INSTALL ALL THREE
    systemctl enable kubelet && systemctl start kubelet

    # [ optional ]
    # sed -i "s/cgroup-driver=systemd/cgroup-driver=cgroupfs/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
    # systemctl daemon-reload
    # systemctl restart kubelet

<<NOTE
It's ok that the kubelet state is failed at this moment.

The reason is that kubelet is unable to load client CA file /etc/kubernetes/pki/ca.crt: open /etc/kubernetes/pki/ca.crt: no such file or directory.

The file will be auto-generated after kubeadm init.
NOTE
}

function add_toolbox() {
    yum install -y epel-release
    yum install -y tree wget jq golang

    wget https://kubernetes-helm.storage.googleapis.com/helm-v2.9.1-linux-amd64.tar.gz 
    tar -zxf helm-v2.9.1-linux-amd64.tar.gz && rm -f helm-v2.9.1-linux-amd64.tar.gz
    mv linux-amd64/helm /usr/local/bin/helm && rm -rf linux-amd64

    wget https://github.com/ksonnet/ksonnet/releases/download/v0.11.0/ks_0.11.0_linux_amd64.tar.gz
    tar -zxf ks_0.11.0_linux_amd64.tar.gz && rm -rf ks_0.11.0_linux_amd64.tar.gz
    mv ks_0.11.0_linux_amd64/ks /usr/local/bin/ks && rm -rf ks_0.11.0_linux_amd64

    wget https://github.com/GoogleContainerTools/skaffold/releases/download/v0.10.0/skaffold-linux-amd64
    chmod +x skaffold-linux-amd64
    mv skaffold-linux-amd64 /usr/local/bin/skaffold
}

function main() {
    noswap
    noselinux
    nofirewall
    enable_bridge_nf_call_iptables
    enable_docker
    enable_kubelet
    add_toolbox
}

main
