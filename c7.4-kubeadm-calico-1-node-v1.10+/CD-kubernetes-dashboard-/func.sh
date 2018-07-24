RELEASE_NAME=kubernetes-dashboard-release

function create_nginx_ingress() {
    helm install stable/kubernetes-dashboard --namespace add-on --name $RELEASE_NAME --set ingress.enabled=true --set rbac.clusterAdminRole=true
}

function delete_nginx_ingress() {
    helm delete --purge $RELEASE_NAME
}
