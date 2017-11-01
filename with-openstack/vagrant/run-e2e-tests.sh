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

docker ps
netstat -plnt
ps aux | grep python

# --------------------------------------------------------------------------------------------

source /root/demo-openrc
source /vagrant/cache/env.rc

# create openstack server 'testvm'
#nova boot --flavor m1.nano --image cirros --nic net-id=$DEMO_NET_ID --config-drive=true testvm
#openstack server list

# create k8s deployment 'demo'
#kubectl run demo --image=demo:demo
#K8S_POD1_NAME=$(kubectl get pods -l run=demo -o jsonpath='{.items[].metadata.name}')
#kubectl get po $K8S_POD1_NAME # FAILED. STATUS: ContainerCreating

<<LOG
# openstack port list --device-owner kuryr:container
| a0818066-aacc-4e7c-b270-55a072ac28eb | demo-2945424114-5cdwb | fa:16:3e:98:7b:3f | ip_address='10.1.0.5', subnet_id='c73a3ee5-c7fe-4757-b7dc-2927bb109ec2' | DOWN   |

# openstack port list | grep $K8S_POD1_NAME
| a0818066-aacc-4e7c-b270-55a072ac28eb | demo-2945424114-5cdwb | fa:16:3e:98:7b:3f | ip_address='10.1.0.5', subnet_id='c73a3ee5-c7fe-4757-b7dc-2927bb109ec2' | DOWN   |

# describe po

Events:
  FirstSeen LastSeen    Count   From            SubobjectPath   Type        Reason      Message
  --------- --------    -----   ----            -------------   --------    ------      -------
  1m        1m      1   {default-scheduler }            Normal      Scheduled   Successfully assigned demo-2945424114-5cdwb to k8s-master
  54s       1s      27  {kubelet k8s-master}            Warning     FailedSync  Error syncing pod, skipping: failed to "SetupNetwork" for "demo-2945424114-5cdwb_default" with SetupNetworkError: "Failed to setup network for pod \"demo-2945424114-5cdwb_default(e2596a40-bea6-11e7-bf22-080027c6913f)\" using network plugins \"cni\": Failed to plug VIF VIFBridge(active=True,address=fa:16:3e:98:7b:3f,bridge_name='qbra0818066-aa',has_traffic_filtering=True,id=a0818066-aacc-4e7c-b270-55a072ac28eb,network=Network(78f13a6a-586e-43f8-be56-70c5c04239a5),plugin='ovs',port_profile=VIFPortProfileBase,preserve_on_delete=False,vif_name='tapa0818066-aa'). Got error: privsep helper command exited non-zero (1); Traceback (most recent call last):\n  File \"/opt/kuryr-kubernetes/env/local/lib/python2.7/site-packages/kuryr_kubernetes/cni/api.py\", line 84, in run\n    vif = self._plugin.add(params)\n  File \"/opt/kuryr-kubernetes/env/local/lib/python2.7/site-packages/kuryr_kubernetes/cni/main.py\", line 40, in add\n    self._watcher.start()\n  File \"/opt/kuryr-kubernetes/env/local/lib/python2.7/site-packages/kuryr_kubernetes/watcher.py\", line 110, in start\n    self._start_watch(path)\n  File \"/opt/kuryr-kubernetes/env/local/lib/python2.7/site-packages/kuryr_kubernetes/watcher.py\", line 128, in _start_watch\n    self._watch(path)\n  File \"/opt/kuryr-kubernetes/env/local/lib/python2.7/site-packages/kuryr_kubernetes/watcher.py\", line 140, in _watch\n    self._handler(event)\n  File \"/opt/kuryr-kubernetes/env/local/lib/python2.7/site-packages/kuryr_kubernetes/handlers/dispatch.py\", line 110, in __call__\n    self._handler(event)\n  File \"/opt/kuryr-kubernetes/env/local/lib/python2.7/site-packages/kuryr_kubernetes/handlers/dispatch.py\", line 64, in __call__\n    handler(event)\n  File \"/opt/kuryr-kubernetes/env/local/lib/python2.7/site-packages/kuryr_kubernetes/handlers/k8s_base.py\", line 63, in __call__\n    self.on_present(obj)\n  File \"/opt/kuryr-kubernetes/env/local/lib/python2.7/site-packages/kuryr_kubernetes/cni/handlers.py\", line 44, in on_present\n    self.on_vif(pod, vif)\n  File \"/opt/kuryr-kubernetes/env/local/lib/python2.7/site-packages/kuryr_kubernetes/cni/handlers.py\", line 78, in on_vif\n    self._cni.CNI_IFNAME, self._cni.CNI_NETNS)\n  File \"/opt/kuryr-kubernetes/env/local/lib/python2.7/site-packages/kuryr_kubernetes/cni/binding/base.py\", line 61, in connect\n    os_vif.plug(vif, instance_info)\n  File \"/opt/kuryr-kubernetes/env/local/lib/python2.7/site-packages/os_vif/__init__.py\", line 85, in plug\n    raise os_vif.exception.PlugException(vif=vif, err=err)\nPlugException: Failed to plug VIF VIFBridge(active=True,address=fa:16:3e:98:7b:3f,bridge_name='qbra0818066-aa',has_traffic_filtering=True,id=a0818066-aacc-4e7c-b270-55a072ac28eb,network=Network(78f13a6a-586e-43f8-be56-70c5c04239a5),plugin='ovs',port_profile=VIFPortProfileBase,preserve_on_delete=False,vif_name='tapa0818066-aa'). Got error: privsep helper command exited non-zero (1)\n; Skipping pod"

  55s   0s  28  {kubelet k8s-master}        Warning MissingClusterDNS   kubelet does not have ClusterDNS IP configured and cannot create Pod using "ClusterFirst" policy. Falling back to DNSDefault policy.
LOG

#K8S_POD1_NAME=$(kubectl get pods -l run=demo -o jsonpath='{.items[].metadata.name}')
#echo "K8S_POD1_NAME = $K8S_POD1_NAME"

# create k8s service 'demo'
#kubectl expose deployment demo --port=80 --target-port=8080

# scale k8s deployment 'demo'
#kubectl scale deployment demo --replicas=2

# check network traffic between openstack server and k8s pod
#kubectl get services demo
#kubectl get endpoints demo

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
