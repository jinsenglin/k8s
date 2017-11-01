#!/bin/bash

set -e

# Check if kubernetes-controller-manager and kubernetes-scheduler are running
docker ps

# docker start kubernetes-controller-manager
# docker start kubernetes-scheduler

# Check if kuryr kubernetes controller is running
ps aux | grep python

# --------------------------------------------------------------------------------------------

source /root/demo-openrc
source /vagrant/cache/env.rc

# Create openstack server 'testvm'
#nova boot --flavor m1.nano --image cirros --nic net-id=$DEMO_NET_ID --config-drive=true testvm
#openstack server show testvm

# Create k8s deployment 'demo'
#kubectl run demo --image=demo:demo
#K8S_POD1_NAME=$(kubectl get pods -l run=demo -o jsonpath='{.items[].metadata.name}')
#kubectl get po $K8S_POD1_NAME

<<LOG
# openstack port list --device-owner kuryr:container
| a0818066-aacc-4e7c-b270-55a072ac28eb | demo-2945424114-5cdwb | fa:16:3e:98:7b:3f | ip_address='10.1.0.5', subnet_id='c73a3ee5-c7fe-4757-b7dc-2927bb109ec2' | DOWN   |

# openstack port list | grep $K8S_POD1_NAME
| a0818066-aacc-4e7c-b270-55a072ac28eb | demo-2945424114-5cdwb | fa:16:3e:98:7b:3f | ip_address='10.1.0.5', subnet_id='c73a3ee5-c7fe-4757-b7dc-2927bb109ec2' | DOWN   |
LOG

# Create k8s service 'demo'
#kubectl expose deployment demo --port=80 --target-port=8080

# Scale k8s deployment 'demo'
#kubectl scale deployment demo --replicas=2

# Check endpoints
#kubectl get services demo
#kubectl get endpoints demo

# check network traffic between openstack server and k8s pod
#kubectl exec -it $DEMO_POD_NAME -- bash

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
