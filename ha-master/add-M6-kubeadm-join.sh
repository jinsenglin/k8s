#!/bin/bash

set -e

function configure() {
    source rc

    ssh -o StrictHostKeyChecking=false $M1 "grep 'kubeadm join' k8s/ha-master/kubeadm-init.log" | sed "s/$PIP1/$PIP0/" | bash

    echo "wait 20 seconds for file '/etc/kubernetes/kubelet.conf' created"
    i=20; while [ $i -gt 0 ]; do echo "wait for $i seconds"; i=$(( $i - 1 )); sleep 1; done

    sed -i "s|^\(    server: https:\/\/\).*|\1$PIP0:8443|" /etc/kubernetes/kubelet.conf
    sed -i "s|^\(    server: https:\/\/\).*|\1$PIP0:8443|" /etc/kubernetes/bootstrap-kubelet.conf

    systemctl restart kubelet
}
configure
