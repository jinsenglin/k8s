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
    #
    # MODIFY the file "/etc/kubernetes/manifests/kube-apiserver.yaml"
    #
    # AS-IS --authorization-mode=Node,RBAC
    # TO-BE --authorization-mode=Node,RBAC,Webhook
    #
    # AS-IS
    # TO-BE --runtime-config=authorization.k8s.io/v1beta1=true
    #
    # AS-IS
    # TO-BE --authorization-webhook-config-file=/etc/kubernetes/webhook.kubeconfig
    # 
    # volumeMounts:
    # ...
    # - mountPath: /etc/kubernetes/webhook.kubeconfig
    #   name: webhook-kubeconfig-file
    #   readOnly: true
    #
    # volumes:
    # ...
    # - hostPath:
    #     path: /etc/kubernetes/authn-authz-webhook/webhook.kubeconfig
    #     type: File
    #   name: webhook-kubeconfig-file
    :
}

function update_enable_authn_token_webhook() {
    #
    # MODIFY the file "/etc/kubernetes/manifests/kube-apiserver.yaml"
    #
    # AS-IS
    # TO-BE --runtime-config=authentication.k8s.io/v1beta1=true
    #
    # AS-IS
    # TO-BE --authentication-token-webhook-config-file=/etc/kubernetes/webhook.kubeconfig
    #
    # AS-IS
    # TO-BE --authentication-token-webhook-cache-ttl=5m
    #
    # volumeMounts:
    # ...
    # - mountPath: /etc/kubernetes/webhook.kubeconfig
    #   name: webhook-kubeconfig-file
    #   readOnly: true
    #
    # volumes:
    # ...
    # - hostPath:
    #     path: /etc/kubernetes/authn-authz-webhook/webhook.kubeconfig
    #     type: File
    #   name: webhook-kubeconfig-kubeconfig
    :
}
