RELEASE_NAME=fluent-bit-release

function create_nginx_ingress() {
    helm install stable/fluent-bit --namespace add-on --name $RELEASE_NAME --set backend.type=es --set backend.es.host=10.112.0.3
}

function delete_nginx_ingress() {
    helm delete --purge $RELEASE_NAME
}
