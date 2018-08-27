RELEASE_NAME=prometheus-node-exporter-release

function create_prometheus_node_exporter() {
    helm install stable/prometheus-node-exporter --version 0.3.0 --namespace add-on --name $RELEASE_NAME
}

function delete_prometheus_node_exporter() {
    helm delete --purge $RELEASE_NAME
}
