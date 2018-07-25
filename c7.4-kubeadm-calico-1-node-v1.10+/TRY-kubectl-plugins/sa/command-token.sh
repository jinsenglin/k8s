#!/bin/bash

SECRETE_NAME=$(kubectl get sa/super-admin -n kube-system -o jsonpath={.secrets[0].name})
kubectl get secret/$SECRETE_NAME -n kube-system -o jsonpath={.data.token} | base64 -d
