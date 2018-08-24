RELEASE_NAME=kube-state-metrics-release

function create_kube_state_metrics() {
    helm install stable/kube-state-metrics --version 0.8.1 --namespace add-on --name $RELEASE_NAME --set rbac.create=true
    kubectl apply -f Ingress.yaml 
}

function delete_kube_state_metrics() {
    kubectl delete -f Ingress.yaml
    helm delete --purge $RELEASE_NAME
}
