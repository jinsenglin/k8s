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
    # HTTP server source code https://github.com/kubernetes/kubernetes/blob/master/pkg/kubelet/server/server.go
    
    # USAGE
    # curl http://localhost:10255/healthz
    # curl http://localhost:10255/metrics/
    # curl http://localhost:10255/metrics/probes
    # curl http://localhost:10255/metrics/cadvisor
    # curl http://localhost:10255/spec/
    # curl http://localhost:10255/pods/
    # curl http://localhost:10255/logs/
    # curl http://localhost:10255/stats/
    # curl http://localhost:10255/stats/summary
    #
    # ABOUT spec/ pods/, metrics/, /metrics/cadvisor
    # * https://medium.com/jorgeacetozi/kubernetes-node-components-service-proxy-kubelet-and-cadvisor-dcc6928ef58c
    #
    # ABOUT spec/ pods/
    # * http://cizixs.com/2016/10/25/kubernetes-intro-kubelet
    #
    # ABOUT healthz, metrics/, metrics/cadvisor, stats/
    # * https://medium.com/@DazWilkin/kubernetes-metrics-ba69d439fac4
    #
    # ABOUT metrics/
    # * https://hk.saowen.com/a/5b2b445e59abe32bac58344cf40d252109cc66cd81657d9929ea990e92ee2586
    # * https://blog.freshtracks.io/a-deep-dive-into-kubernetes-metrics-part-3-container-resource-metrics-361c5ee46e66
    #
    # ABOUT metric 'container_memory_usage_bytes'
    #
    # curl http://localhost:10255/metrics/cadvisor | grep container_memory_usage_bytes
    # prometheus query language
    # * container_memory_usage_bytes{job="cadvisor"}
    #   * only list usage by namespace :: sum(container_memory_usage_bytes{job="cadvisor",namespace=~".+",container_name!~".+"}) by (namespace)  
    #   * only list usage by pod in a given ns :: container_memory_usage_bytes{job="cadvisor",namespace="add-on",container_name!~".+"}
    #   * only list usage by container in a given ns :: container_memory_usage_bytes{job="cadvisor",namespace="add-on",container_name=~".+"}
    #   * only list usage by pod in a given deploy :: NOT AVAILABLE
    #
    # * https://prometheus.io/docs/guides/cadvisor/
    # * https://blog.outlyer.com/top-kubernetes-metrics-to-monitor
    # * https://medium.com/@DazWilkin/kubernetes-metrics-ba69d439fac4
    # * https://hk.saowen.com/a/5b2b445e59abe32bac58344cf40d252109cc66cd81657d9929ea990e92ee2586
    # * https://blog.freshtracks.io/a-deep-dive-into-kubernetes-metrics-part-3-container-resource-metrics-361c5ee46e66
    #
    # ABOUT metric 'container_cpu_usage_seconds_total'
    #
    # curl http://localhost:10255/metrics/cadvisor | grep container_cpu_usage_seconds_total
    # prometheus query language
    # * container_cpu_usage_seconds_total{job="cadvisor"}
    #   * only list usage by namespace :: sum(rate(container_cpu_usage_seconds_total{job="cadvisor",namespace=~".+",container_name!~".+"}[1m])) by (namespace)  
    #   * only list usage by pod in a given ns :: rate(container_cpu_usage_seconds_total{job="cadvisor",namespace="add-on",container_name!~".+"}[1m])
    #   * only list usage by container in a given ns :: rate(container_cpu_usage_seconds_total{job="cadvisor",namespace="add-on",container_name=~".+"}[1m])
    #   * only list usage by pod in a given deploy :: NOT AVAILABLE
    #
    # * https://prometheus.io/docs/guides/cadvisor/
    # * https://blog.outlyer.com/top-kubernetes-metrics-to-monitor
    # * https://blog.freshtracks.io/a-deep-dive-into-kubernetes-metrics-part-3-container-resource-metrics-361c5ee46e66
    #
    # ABOUT metric 'container_network_transmit_bytes_total'
    # curl http://localhost:10255/metrics/cadvisor | grep container_network_transmit_bytes_total
    # prometheus query language
    # * container_network_transmit_bytes_total{job="cadvisor"}
    #   * only list usage by namespace ::
    #   * only list usage by pod in a given ns ::
    #   * only list usage by container in a given ns ::
    #   * only list usage by pod in a given deploy ::
    #
    # * https://prometheus.io/docs/guides/cadvisor/
    # * https://blog.outlyer.com/top-kubernetes-metrics-to-monitor
    # * https://blog.freshtracks.io/a-deep-dive-into-kubernetes-metrics-part-3-container-resource-metrics-361c5ee46e66
    

    systemctl daemon-reload
    systemctl restart kubelet
}
