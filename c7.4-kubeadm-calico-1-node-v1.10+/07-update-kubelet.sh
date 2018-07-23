#!/bin/bash

set -e
set -o pipefail

function open_10255() {
    #
    # MODIFY the file "/etc/systemd/system/kubelet.service.d/10-kubeadm.conf"
    #
    # AS-IS ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
    # TO-BE ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS --read-only-port=10255
    #

    systemctl daemon-reload
    systemctl restart kubelet
}
