RELEASE_NAME=kubernetes-dashboard-release

function create_nginx_ingress() {
    helm install stable/kubernetes-dashboard --namespace add-on --name $RELEASE_NAME --set rbac.clusterAdminRole=true
    kubectl apply -f Ingress.yaml 
}

function delete_nginx_ingress() {
    kubectl delete -f Ingress.yaml
    helm delete --purge $RELEASE_NAME
}
