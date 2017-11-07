#!/bin/bash

# Usage: bash easy-etcdctl.sh member list
# Usage: bash easy-etcdctl.sh cluster-health

set -e

CMD=$1

case $CMD in
    "case")
        shift
        CASE=$1
        case_$CASE
        ;;
    *)
        source rc
        bash remote-runner.sh $FIP0 docker exec etcd etcdctl $@
        ;;
esac
