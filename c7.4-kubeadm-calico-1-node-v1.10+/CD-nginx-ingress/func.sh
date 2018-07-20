RELEASE_NAME=nginx-ingress-release

function create_nginx_ingress() {
    helm install stable/nginx-ingress --namespace add-on --name $RELEASE_NAME --set=controller.service.type=NodePort
}

function delete_nginx_ingress() {
    helm delete --purge $RELEASE_NAME
}
