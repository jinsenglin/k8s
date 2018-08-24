RELEASE_NAME=fluent-bit-release

function create_nginx_ingress() {
    # [ for kube-dns ]
    # kubectl apply -f Service.yaml
    # helm install stable/fluent-bit --version 0.9.0 --namespace add-on --name $RELEASE_NAME --set backend.type=es --set backend.es.host=ext-es

    # [ for coredns ]
    helm install stable/fluent-bit --version 0.9.0 --namespace add-on --name $RELEASE_NAME --set backend.type=es --set backend.es.host=10.112.0.3
}

function delete_nginx_ingress() {
    # [ for kube-dns ]
    # helm delete --purge $RELEASE_NAME
    # kubectl delete -f Service.yaml

    # [ for coredns ]
    helm delete --purge $RELEASE_NAME
}
