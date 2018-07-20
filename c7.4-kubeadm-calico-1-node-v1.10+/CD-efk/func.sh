function create_efk() {
    # installed in the namespace kube-system
    kubectl apply -f ../v1.11.1-addons/fluentd-elasticsearch/
    kubectl label nodes k8s.novalocal beta.kubernetes.io/fluentd-ds-ready=true
}

function delete_efk() {
    kubectl label nodes k8s.novalocal beta.kubernetes.io/fluentd-ds-ready-
    kubectl delete -f ../v1.11.1-addons/fluentd-elasticsearch/
}
