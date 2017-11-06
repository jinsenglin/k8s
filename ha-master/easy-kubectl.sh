#!/bin/bash

set -e

CMD=$1
shift

function get_node() {
    source rc
    bash remote-runner.sh $FIPC kubectl get node
}

function get_po() {
    source rc
    bash remote-runner.sh $FIPC kubectl get po
}

$CMD $@
