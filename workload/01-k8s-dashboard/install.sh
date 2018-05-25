#!/bin/bash

set -e

wget https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

kubectl apply -f kubernetes-dashboard.yaml
kubectl apply -f create-super-admin.yaml
