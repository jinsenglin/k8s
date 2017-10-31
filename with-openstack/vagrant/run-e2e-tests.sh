#!/bin/bash

set -e

CACHE=/vagrant/cache

source /root/demo-openrc
source $CACHE/env.rc

# create openstack server 'testvm'
#nova boot --flavor m1.nano --image cirros --nic net-id=$DEMO_NET_ID --config-drive=true testvm

# create k8s deployment 'demo'
#kubectl run demo --image=demo:demo

K8S_POD1_NAME=$(kubectl get pods -l run=demo -o jsonpath='{.items[].metadata.name}')
echo "K8S_POD1_NAME = $K8S_POD1_NAME"

# create k8s service 'demo'
#kubectl expose deployment demo --port=80 --target-port=8080

# scale k8s deployment 'demo'
#kubectl scale deployment demo --replicas=2

# check network traffic between openstack server and k8s pod
kubectl get services demo
kubectl get endpoints demo

kubectl exec -it $DEMO_POD_NAME -- bash

<<SOP
export PS1='POD # '
curl http://127.0.0.1:8080   # local server
curl http://10.1.0.3:8080    # remote server using Pod IP
curl http://10.1.0.4:8080    # local server using Pod IP
curl http://10.1.0.110       # service
curl http://10.1.0.110       # service

ssh cirros@10.1.0.8          # password: cubswin:)

export PS1='VM # '
hostname
curl http://10.1.0.3:8080
curl http://10.1.0.4:8080
curl http://10.1.0.110
curl http://10.1.0.110
exit # logout vm

exit # logout pod
SOP
