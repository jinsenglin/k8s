#!/bin/bash

set -e
set -o pipefail

function update_enable_resource_quota() {
    #
    # MODIFY the file "/etc/kubernetes/manifests/kube-apiserver.yaml"
    #
    # AS-IS --enable-admission-plugins=NodeRestriction
    # TO-BE --enable-admission-plugins=NodeRestriction,ResourceQuota
    #
    :
}
