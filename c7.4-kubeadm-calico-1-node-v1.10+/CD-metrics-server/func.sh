RELEASE_NAME=metrics-server-release

function create_metrics_server() {
    helm install stable/metrics-server --namespace add-on --name $RELEASE_NAME
}

function delete_metrics_server() {
    helm delete --purge $RELEASE_NAME
}
