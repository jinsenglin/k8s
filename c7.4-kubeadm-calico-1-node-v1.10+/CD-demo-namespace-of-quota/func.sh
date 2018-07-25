function create_demo_namespace_of_quota() {
    kubectl apply -f .
}

function delete_demo_namespace_of_quota() {
    kubectl delete -f .
}
