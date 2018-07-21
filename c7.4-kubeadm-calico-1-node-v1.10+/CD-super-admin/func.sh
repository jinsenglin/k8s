function create_super_admin() {
    # installed in the namespace kube-system
    kubectl apply -f .
}

function delete_super_admin() {
    kubectl delete -f .
}
