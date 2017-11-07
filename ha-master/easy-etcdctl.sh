#!/bin/bash

# Usage: bash easy-etcdctl.sh member list
# Usage: bash easy-etcdctl.sh cluster-health
# Usage: bash easy-etcdctl.sh case all_kvs
# Usage: bash easy-etcdctl.sh case all_ks

set -e

function case_all_kvs() {
    source rc
    bash remote-runner.sh $FIPC ETCDCTL_API=3 etcdctl --endpoints=http://$PIP0:2379 get --prefix /registry
}

function case_all_ks() {
    source rc
    bash remote-runner.sh $FIPC ETCDCTL_API=3 etcdctl --endpoints=http://$PIP0:2379 get / --prefix --keys-only
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
        bash remote-runner.sh $FIP0 docker exec etcd etcdctl $@
        ;;
esac
