RELEASE_NAME=prometheus-node-exporter-release

function create_prometheus_node_exporter() {
    helm install stable/prometheus-node-exporter --namespace add-on --name $RELEASE_NAME
    kubectl apply -f Ingress.yaml 
}

function delete_prometheus_node_exporter() {
    kubectl delete -f Ingress.yaml
    helm delete --purge $RELEASE_NAME
}
