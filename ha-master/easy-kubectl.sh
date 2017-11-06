#!/bin/bash

# Usage: bash easy-kubectl.sh get node -o wide
# Usage: bash easy-kubectl.sh get po -n kube-system -o wide
# Usage: bash easy-kubectl.sh case run_nginx

set -e

function case_run_nginx() {
    source rc
    bash remote-runner.sh $FIPC kubectl run hello-nginx --image=nginx:latest --replicas=1 --port=80
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
