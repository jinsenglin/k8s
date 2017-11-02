#!/bin/bash

source rc
kubectl --kubeconfig=/etc/kubernetes/admin.conf drain $M1 --delete-local-data --force --ignore-daemonsets
kubectl --kubeconfig=/etc/kubernetes/admin.conf delete ds kube-proxy -n kube-system
kubectl --kubeconfig=/etc/kubernetes/admin.conf delete ds kube-flannel-ds -n kube-system
kubectl --kubeconfig=/etc/kubernetes/admin.conf delete node $M1
kubeadm reset
rm -rf /var/lib/kubelet
