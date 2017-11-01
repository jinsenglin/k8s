#!/bin/bash

set -e

source /root/admin-openrc
source /vagrant/cache/env.rc

# check
#nova-status upgrade check # RUN ON OS-CONTROLLER
openstack network agent list
openstack image list
openstack catalog list
openstack hypervisor list
openstack role assignment list --user kuryr --project service --user-domain Default --project-domain Default
openstack service list

openstack subnet pool list
openstack subnet pool show shared-default-subnetpool

openstack project list
openstack project show demo

openstack network list
openstack network show demo

openstack subnet list
openstack subnet show demo
openstack subnet show k8s-service-subnet

openstack router list
openstack router show demo

openstack port list

# --------------------------------------------------------------------------------------------

source /root/demo-openrc
source /vagrant/cache/env.rc

# create openstack server 'testvm'
#nova boot --flavor m1.nano --image cirros --nic net-id=$DEMO_NET_ID --config-drive=true testvm

# create k8s deployment 'demo' # FAILED
#kubectl run demo --image=demo:demo

#K8S_POD1_NAME=$(kubectl get pods -l run=demo -o jsonpath='{.items[].metadata.name}')
#echo "K8S_POD1_NAME = $K8S_POD1_NAME"

# create k8s service 'demo'
#kubectl expose deployment demo --port=80 --target-port=8080

# scale k8s deployment 'demo'
#kubectl scale deployment demo --replicas=2

# check network traffic between openstack server and k8s pod
kubectl get services demo
kubectl get endpoints demo

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
