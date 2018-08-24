RELEASE_NAME=nginx-ingress-release

function create_nginx_ingress() {
    helm install stable/nginx-ingress --version 0.25.1 --namespace add-on --name $RELEASE_NAME --set=controller.service.type=NodePort --set=controller.service.nodePorts.http=32280
}

function update_nginx_ingress() {
    helm upgrade $RELEASE_NAME stable/nginx-ingress --version 0.25.1 --set=controller.service.type=NodePort --set=controller.service.nodePorts.http=32080 --set=controller.service.nodePorts.https=32443
}

function delete_nginx_ingress() {
    helm delete --purge $RELEASE_NAME
}
