RELEASE_NAME=kube-state-metrics-release

function create_kube_state_metrics() {
    helm install stable/kube-state-metrics --namespace add-on --name $RELEASE_NAME --set rbac.create=true
}

function delete_kube_state_metrics() {
    helm delete --purge $RELEASE_NAME
}
