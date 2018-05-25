#!/bin/bash

set -e

wget https://github.com/kubernetes/heapster/archive/v1.5.3.tar.gz
tar -zxf v1.5.3.tar.gz

kubectl apply -f heapster-1.5.3/deploy/kube-config/rbac/
kubectl apply -f heapster-1.5.3/deploy/kube-config/influxdb/
