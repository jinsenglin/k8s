function create_userX_namespace() {
    kubectl apply -f Namespace.yaml
    kubectl apply -f .
}

function delete_userX_namespace() {
    kubectl delete -f .
}
