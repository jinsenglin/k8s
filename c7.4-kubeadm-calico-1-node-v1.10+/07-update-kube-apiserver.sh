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

function update_enable_authz_webhook() {
    # We reuse the folder /etc/kubernetes/pki/ because it's already mounted and accessible by API server pod.
    cat <<EOF > /etc/kubernetes/pki/webhookconfig.yaml
---
apiVersion: v1
kind: Config
preferences: {}
clusters:
  - cluster:
      insecure-skip-tls-verify: true
      server: https://k8s-keystone-auth-service:8443/webhook
    name: webhook
users:
  - name: webhook
contexts:
  - context:
      cluster: webhook
      user: webhook
    name: webhook
current-context: webhook
EOF

    #
    # MODIFY the file "/etc/kubernetes/manifests/kube-apiserver.yaml"
    #
    # AS-IS
    # TO-BE --authorization-webhook-config-file=/etc/kubernetes/pki/webhookconfig.yaml
    #
    # AS-IS --authorization-mode=Node,RBAC
    # TO-BE --authorization-mode=Node,RBAC,Webhook
    :
}

function update_enable_authn_token_webhook() {
    # We reuse the folder /etc/kubernetes/pki/ because it's already mounted and accessible by API server pod.
    cat <<EOF > /etc/kubernetes/pki/webhookconfig.yaml
---
apiVersion: v1
kind: Config
preferences: {}
clusters:
  - cluster:
      insecure-skip-tls-verify: true
      server: https://k8s-keystone-auth-service:8443/webhook
    name: webhook
users:
  - name: webhook
contexts:
  - context:
      cluster: webhook
      user: webhook
    name: webhook
current-context: webhook
EOF

    #
    # MODIFY the file "/etc/kubernetes/manifests/kube-apiserver.yaml"
    #
    # AS-IS
    # TO-BE --authentication-token-webhook-config-file=/etc/kubernetes/pki/webhookconfig.yaml
    :
}
