#!/bin/bash

# Usage: bash easy-kubectl.sh get node -o wide
# Usage: bash easy-kubectl.sh get po -n kube-system -o wide
# Usage: bash easy-kubectl.sh case run_nginx

set -e

function case_run_nginx() {
    source rc
    bash remote-runner.sh $FIPC kubectl run hello-nginx --image=nginx:latest --replicas=1 --port=80
}

function case_scale_nginx() {
    source rc
    bash remote-runner.sh $FIPC kubectl scale deployment/hello-nginx --replicas=3
}

function case_expose_nginx() {
    source rc
    bash remote-runner.sh $FIPC kubectl expose deployment/hello-nginx --target-port=80
}

function case_del_nginx() {
    source rc
    bash remote-runner.sh $FIPC kubectl delete deployment/hello-nginx
    bash remote-runner.sh $FIPC kubectl delete service/hello-nginx
}

function case_curl_nginx() {
    source rc
    bash remote-runner.sh $FIPC screen -dmS kubectl-proxy kubectl proxy
    sleep 1
    bash remote-runner.sh $FIPC curl -s http://127.0.0.1:8001/api/v1/namespaces/default/services/hello-nginx/proxy/
    bash remote-runner.sh $FIPC screen -X -S kubectl-proxy quit
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
