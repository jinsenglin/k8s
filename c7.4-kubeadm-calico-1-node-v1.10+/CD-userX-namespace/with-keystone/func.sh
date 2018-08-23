function create_userX_namespace() {
    kubectl create secret generic keystone-auth-certs --from-file=cert-file=/etc/kubernetes/pki/apiserver.crt --from-file=key-file=/etc/kubernetes/pki/apiserver.key -n kube-system
    kubectl apply -f .
}

function delete_userX_namespace() {
    kubectl delete -f .
    kubectl delete secret keystone-auth-certs -n kube-system
}
