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
    
    # ABOUT PORT 10255
    # The read-only port for the Kubelet to serve on with no authentication/authorization (set to 0 to disable)
    
    # USAGE
    # curl http://localhost:10255/metrics/
    # curl http://localhost:10255/metrics/cadvisor
    # curl http://localhost:10255/spec/
    # curl http://localhost:10255/pods/
    # curl http://localhost:10255/stats/
    # curl http://localhost:10255/stats/summary
    #
    # ABOUT metrics/cadvisor
    # * https://prometheus.io/docs/guides/cadvisor/
    # * https://medium.com/@DazWilkin/kubernetes-metrics-ba69d439fac4
    # * https://hk.saowen.com/a/5b2b445e59abe32bac58344cf40d252109cc66cd81657d9929ea990e92ee2586
    # * https://blog.freshtracks.io/a-deep-dive-into-kubernetes-metrics-part-3-container-resource-metrics-361c5ee46e66
    # * curl http://localhost:10255/metrics/cadvisor | grep container_memory_usage_bytes

    systemctl daemon-reload
    systemctl restart kubelet
}
