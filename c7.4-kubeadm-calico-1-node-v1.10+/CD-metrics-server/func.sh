RELEASE_NAME=metrics-server-release

function create_metrics_server() {
    helm install stable/metrics-server --version 1.1.0 --namespace add-on --name $RELEASE_NAME
}

function delete_metrics_server() {
    helm delete --purge $RELEASE_NAME
}
