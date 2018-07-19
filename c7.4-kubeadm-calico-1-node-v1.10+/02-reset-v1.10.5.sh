#!/bin/bash

set -e
set -o pipefail

function main() {
    kubeadm reset
}

main
