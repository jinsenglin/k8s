RELEASE_NAME=prometheus-release

function create_prometheus() {
    helm install stable/prometheus --version 7.0.2 --namespace add-on --name $RELEASE_NAME
    kubectl apply -f Ingress.yaml
}

function delete_prometheus() {
    kubectl delete -f Ingress.yaml
    helm delete --purge $RELEASE_NAME
}
