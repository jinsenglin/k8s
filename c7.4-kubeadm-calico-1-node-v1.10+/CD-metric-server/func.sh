RELEASE_NAME=metric-server-release

function create_metric_server() {
    helm install stable/metric-server --namespace add-on --name $RELEASE_NAME
}

function delete_metric_server() {
    helm delete --purge $RELEASE_NAME
}
