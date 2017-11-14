#!/bin/bash

# Usage: bash easy-kubectl.sh get node -o wide
# Usage: bash easy-kubectl.sh get po -n kube-system -o wide
# Usage: bash easy-kubectl.sh case run_nginx

set -e

function case_get_default_token() {
    source rc
    echo "namespace = default | token = default-token-xxxx"
    bash remote-runner.sh $FIPC "kubectl describe secret \$(kubectl get secrets | grep default-token | cut -f1 -d ' ') | grep -E '^token' | cut -f2 -d':' | tr -d '\t'"
    echo "namespace = kube-system | token = default-token-xxxx"
    bash remote-runner.sh $FIPC "kubectl describe secret \$(kubectl get secrets -n kube-system | grep default-token | cut -f1 -d ' ') -n kube-system | grep -E '^token' | cut -f2 -d':' | tr -d '\t'"
    echo "namespace = kube-system | token = kubernetes-dashboard-xxxx"
    bash remote-runner.sh $FIPC "kubectl describe secret \$(kubectl get secrets -n kube-system | grep kubernetes-dashboard | cut -f1 -d ' ') -n kube-system | grep -E '^token' | cut -f2 -d':' | tr -d '\t'"
}

function case_insecure_private_registry() {
    source rc
    bash remote-runner.sh $FIPC kubectl run hello-registry --image=192.168.240.5:5000/registry:2.6.2 --replicas=1 --port=5000
}

function case_run_nginx() {
    source rc
    bash remote-runner.sh $FIPC kubectl run hello-nginx --image=nginx:latest --replicas=1 --port=80
}

function case_scale_nginx() {
    source rc
    bash remote-runner.sh $FIPC kubectl scale deployment/hello-nginx --replicas=3
}

function case_expose_nginx() {
    # default type = ClusterIP
    source rc
    bash remote-runner.sh $FIPC kubectl expose deployment/hello-nginx --target-port=80
}

function case_expose_nginx_nodeport() {
    source rc
    bash remote-runner.sh $FIPC kubectl expose deployment/hello-nginx --type=NodePort --target-port=80
}

function case_del_nginx() {
    source rc
    bash remote-runner.sh $FIPC kubectl delete deployment/hello-nginx
    bash remote-runner.sh $FIPC kubectl delete service/hello-nginx
}

function case_curl_nginx() {
    # When service was exposed with type of ClusterIP
    # Accessing services running on the cluster :: Access services, nodes, or pods using the Proxy Verb. :: Manually constructing apiserver proxy URLs
    source rc
    bash remote-runner.sh $FIPC screen -dmS kubectl-proxy kubectl proxy # --address='0.0.0.0' will cause an error 'http: proxy error: unexpected EOF' in query
    sleep 1
    bash remote-runner.sh $FIPC curl -s http://127.0.0.1:8001/api/v1/namespaces/default/services/hello-nginx/proxy/
    bash remote-runner.sh $FIPC screen -X -S kubectl-proxy quit
}

function case_curl_k8s_dashboard() {
    # Prerequisite
    # - install kubeadm-ha/kubernetes-dashboard.yaml
    source rc
    bash remote-runner.sh $FIPC screen -dmS kubectl-proxy kubectl proxy
    sleep 1
    bash remote-runner.sh $FIPC curl -s http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
    bash remote-runner.sh $FIPC screen -X -S kubectl-proxy quit

    # Notes
    # ssh -L8001:localhost:8001 $FIPC
}

function case_curl_heapster_grafana() {
    # Prerequisite
    # - install kubeadm-ha/heapster/
    source rc
    bash remote-runner.sh $FIPC screen -dmS kubectl-proxy kubectl proxy
    sleep 1
    bash remote-runner.sh $FIPC curl -s http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/monitoring-grafana/proxy/
    bash remote-runner.sh $FIPC screen -X -S kubectl-proxy quit

    # Notes
    # ssh -L8001:localhost:8001 $FIPC
}

CMD=$1

case $CMD in
    "case")
        shift
        CASE=$1
        case_$CASE
        ;;
    *)
        source rc
        bash remote-runner.sh $FIPC kubectl $@
        ;;
esac
