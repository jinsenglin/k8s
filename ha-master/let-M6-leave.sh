#!/bin/bash

set -e

function configure() {
    source rc

    bash easy-kubectl.sh drain $M6 --delete-local-data --force --ignore-daemonsets
    bash easy-kubectl.sh delete node $M6

    set +e
    bash remote-runner.sh $FIP6 "kubeadm reset; [ -d /var/lib/kubelet ] && rm -rf /var/lib/kubelet; [ -f /etc/kubernetes/bootstrap-kubelet.conf ] && rm /etc/kubernetes/bootstrap-kubelet.conf"
    set -e
}
configure
