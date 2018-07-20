function create_super_admin() {
    kubectl apply -f .
}

function delete_super_admin() {
    kubectl delete -f .
}
