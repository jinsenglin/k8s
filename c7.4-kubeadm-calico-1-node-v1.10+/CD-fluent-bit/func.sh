RELEASE_NAME=fluent-bit-release

function create_nginx_ingress() {
    kubectl apply -f Service.yaml
    helm install stable/fluent-bit --namespace add-on --name $RELEASE_NAME --set backend.type=es --set backend.es.host=ext-es
}

function delete_nginx_ingress() {
    helm delete --purge $RELEASE_NAME
    kubectl delete -f Service.yaml
}
