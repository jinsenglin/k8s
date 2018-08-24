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
    
    # USAGE
    # http://localhost:10255/metrics/           # kubelet internal server
    # http://localhost:10255/metrics/cadvisor   # kubelet internal server
    # http://localhost:10255/pods/              # kubelet internal server
    # http://localhost:10255/stats/             # kubelet internal server
    # http://localhost:10255/stats/summary      # kubelet internal server
    #
    # ABOUT metrics/cadvisor
    # * https://prometheus.io/docs/guides/cadvisor/
    # * curl http://localhost:10255/metrics/cadvisor | grep container_memory_usage_bytes

    systemctl daemon-reload
    systemctl restart kubelet
}
