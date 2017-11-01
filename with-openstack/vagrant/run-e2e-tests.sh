#!/bin/bash

set -e

source /root/admin-openrc
source /vagrant/cache/env.rc

# check

docker ps
# if kubernetes-controller-manager and kubernetes-scheduler are not running, start them by:
# docker start kubernetes-controller-manager
# docker start kubernetes-scheduler
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

# kuryr-kubernetes controller
2017-11-01 02:05:58.142 28546 ERROR kuryr_kubernetes.handlers.logging [-] Failed to handle event {u'object': {u'status': {u'phase': u'Pending', u'conditions': [{u'status': u'True', u'lastProbeTime': None, u'type': u'Initialized', u'lastTransitionTime': u'2017-11-01T01:49:22Z'}, {u'status': u'False', u'lastTransitionTime': u'2017-11-01T01:49:22Z', u'reason': u'ContainersNotReady', u'lastProbeTime': None, u'message': u'containers with unready status: [demo]', u'type': u'Ready'}, {u'status': u'True', u'lastProbeTime': None, u'type': u'PodScheduled', u'lastTransitionTime': u'2017-11-01T01:49:22Z'}], u'containerStatuses': [{u'restartCount': 0, u'name': u'demo', u'image': u'demo:demo', u'imageID': u'', u'state': {u'waiting': {u'reason': u'ContainerCreating'}}, u'ready': False, u'lastState': {}}], u'startTime': u'2017-11-01T01:49:22Z', u'hostIP': u'10.0.0.51'}, u'kind': u'Pod', u'spec': {u'dnsPolicy': u'ClusterFirst', u'securityContext': {}, u'serviceAccountName': u'default', u'serviceAccount': u'default', u'terminationGracePeriodSeconds': 30, u'restartPolicy': u'Always', u'volumes': [{u'secret': {u'defaultMode': 420, u'secretName': u'default-token-5qwaq'}, u'name': u'default-token-5qwaq'}], u'containers': [{u'terminationMessagePath': u'/dev/termination-log', u'name': u'demo', u'image': u'demo:demo', u'volumeMounts': [{u'readOnly': True, u'mountPath': u'/var/run/secrets/kubernetes.io/serviceaccount', u'name': u'default-token-5qwaq'}], u'imagePullPolicy': u'IfNotPresent', u'resources': {}}], u'nodeName': u'k8s-master'}, u'apiVersion': u'v1', u'metadata': {u'name': u'demo-2945424114-5cdwb', u'labels': {u'pod-template-hash': u'2945424114', u'run': u'demo'}, u'namespace': u'default', u'ownerReferences': [{u'kind': u'ReplicaSet', u'controller': True, u'name': u'demo-2945424114', u'apiVersion': u'extensions/v1beta1', u'uid': u'e2574d6d-bea6-11e7-bf22-080027c6913f'}], u'resourceVersion': u'1526', u'generateName': u'demo-2945424114-', u'creationTimestamp': u'2017-11-01T01:49:22Z', u'annotations': {u'openstack.org/kuryr-vif': u'{"versioned_object.data": {"active": false, "address": "fa:16:3e:98:7b:3f", "bridge_name": "qbra0818066-aa", "has_traffic_filtering": true, "id": "a0818066-aacc-4e7c-b270-55a072ac28eb", "network": {"versioned_object.data": {"bridge": "br-int", "id": "78f13a6a-586e-43f8-be56-70c5c04239a5", "label": "demo", "mtu": 1450, "multi_host": false, "should_provide_bridge": false, "should_provide_vlan": false, "subnets": {"versioned_object.data": {"objects": [{"versioned_object.data": {"cidr": "10.1.0.0/26", "dns": [], "gateway": "10.1.0.1", "ips": {"versioned_object.data": {"objects": [{"versioned_object.data": {"address": "10.1.0.5"}, "versioned_object.name": "FixedIP", "versioned_object.namespace": "os_vif", "versioned_object.version": "1.0"}]}, "versioned_object.name": "FixedIPList", "versioned_object.namespace": "os_vif", "versioned_object.version": "1.0"}, "routes": {"versioned_object.data": {"objects": []}, "versioned_object.name": "RouteList", "versioned_object.namespace": "os_vif", "versioned_object.version": "1.0"}}, "versioned_object.name": "Subnet", "versioned_object.namespace": "os_vif", "versioned_object.version": "1.0"}]}, "versioned_object.name": "SubnetList", "versioned_object.namespace": "os_vif", "versioned_object.version": "1.0"}}, "versioned_object.name": "Network", "versioned_object.namespace": "os_vif", "versioned_object.version": "1.1"}, "plugin": "ovs", "port_profile": {"versioned_object.data": {"interface_id": "a0818066-aacc-4e7c-b270-55a072ac28eb"}, "versioned_object.name": "VIFPortProfileOpenVSwitch", "versioned_object.namespace": "os_vif", "versioned_object.version": "1.0"}, "preserve_on_delete": false, "vif_name": "tapa0818066-aa"}, "versioned_object.name": "VIFBridge", "versioned_object.namespace": "os_vif", "versioned_object.version": "1.0"}', u'kubernetes.io/created-by': u'{"kind":"SerializedReference","apiVersion":"v1","reference":{"kind":"ReplicaSet","namespace":"default","name":"demo-2945424114","uid":"e2574d6d-bea6-11e7-bf22-080027c6913f","apiVersion":"extensions","resourceVersion":"1511"}}\n'}, u'selfLink': u'/api/v1/namespaces/default/pods/demo-2945424114-5cdwb', u'uid': u'e2596a40-bea6-11e7-bf22-080027c6913f'}}, u'type': u'ADDED'}
2017-11-01 02:05:58.142 28546 ERROR kuryr_kubernetes.handlers.logging Traceback (most recent call last):
2017-11-01 02:05:58.142 28546 ERROR kuryr_kubernetes.handlers.logging   File "/opt/kuryr-kubernetes/env/local/lib/python2.7/site-packages/kuryr_kubernetes/handlers/logging.py", line 37, in __call__
2017-11-01 02:05:58.142 28546 ERROR kuryr_kubernetes.handlers.logging     self._handler(event)
2017-11-01 02:05:58.142 28546 ERROR kuryr_kubernetes.handlers.logging   File "/opt/kuryr-kubernetes/env/local/lib/python2.7/site-packages/kuryr_kubernetes/handlers/retry.py", line 66, in __call__
2017-11-01 02:05:58.142 28546 ERROR kuryr_kubernetes.handlers.logging     ex.reraise = False
2017-11-01 02:05:58.142 28546 ERROR kuryr_kubernetes.handlers.logging   File "/opt/kuryr-kubernetes/env/local/lib/python2.7/site-packages/oslo_utils/excutils.py", line 220, in __exit__
2017-11-01 02:05:58.142 28546 ERROR kuryr_kubernetes.handlers.logging     self.force_reraise()
2017-11-01 02:05:58.142 28546 ERROR kuryr_kubernetes.handlers.logging   File "/opt/kuryr-kubernetes/env/local/lib/python2.7/site-packages/oslo_utils/excutils.py", line 196, in force_reraise
2017-11-01 02:05:58.142 28546 ERROR kuryr_kubernetes.handlers.logging     six.reraise(self.type_, self.value, self.tb)
2017-11-01 02:05:58.142 28546 ERROR kuryr_kubernetes.handlers.logging   File "/opt/kuryr-kubernetes/env/local/lib/python2.7/site-packages/kuryr_kubernetes/handlers/retry.py", line 61, in __call__
2017-11-01 02:05:58.142 28546 ERROR kuryr_kubernetes.handlers.logging     self._handler(event)
2017-11-01 02:05:58.142 28546 ERROR kuryr_kubernetes.handlers.logging   File "/opt/kuryr-kubernetes/env/local/lib/python2.7/site-packages/kuryr_kubernetes/handlers/k8s_base.py", line 63, in __call__
2017-11-01 02:05:58.142 28546 ERROR kuryr_kubernetes.handlers.logging     self.on_present(obj)
2017-11-01 02:05:58.142 28546 ERROR kuryr_kubernetes.handlers.logging   File "/opt/kuryr-kubernetes/env/local/lib/python2.7/site-packages/kuryr_kubernetes/controller/handlers/vif.py", line 72, in on_present
2017-11-01 02:05:58.142 28546 ERROR kuryr_kubernetes.handlers.logging     self._drv_vif.activate_vif(pod, vif)
2017-11-01 02:05:58.142 28546 ERROR kuryr_kubernetes.handlers.logging   File "/opt/kuryr-kubernetes/env/local/lib/python2.7/site-packages/kuryr_kubernetes/controller/drivers/generic_vif.py", line 59, in activate_vif
2017-11-01 02:05:58.142 28546 ERROR kuryr_kubernetes.handlers.logging     raise k_exc.ResourceNotReady(vif)
2017-11-01 02:05:58.142 28546 ERROR kuryr_kubernetes.handlers.logging ResourceNotReady: Resource not ready: VIFBridge(active=False,address=fa:16:3e:98:7b:3f,bridge_name='qbra0818066-aa',has_traffic_filtering=True,id=a0818066-aacc-4e7c-b270-55a072ac28eb,network=Network(78f13a6a-586e-43f8-be56-70c5c04239a5),plugin='ovs',port_profile=VIFPortProfileBase,preserve_on_delete=False,vif_name='tapa0818066-aa')

# ovs-vsctl show k8-masetr
65eb446b-39fc-40f7-880e-d4d2710e28ed
    Manager "ptcp:6640:127.0.0.1"
        is_connected: true
    Bridge br-int
        Controller "tcp:127.0.0.1:6633"
            is_connected: true
        fail_mode: secure
        Port patch-tun
            Interface patch-tun
                type: patch
                options: {peer=patch-int}
        Port br-int
            Interface br-int
                type: internal
    Bridge br-tun
        Controller "tcp:127.0.0.1:6633"
            is_connected: true
        fail_mode: secure
        Port br-tun
            Interface br-tun
                type: internal
        Port patch-int
            Interface patch-int
                type: patch
                options: {peer=patch-tun}
    ovs_version: "2.6.1"

# ovs-vsctl show os-compute
f303722f-f95d-44cd-9340-982ba8525719
    Manager "ptcp:6640:127.0.0.1"
        is_connected: true
    Bridge br-tun
        Controller "tcp:127.0.0.1:6633"
            is_connected: true
        fail_mode: secure
        Port "vxlan-0a000115"
            Interface "vxlan-0a000115"
                type: vxlan
                options: {df_default="true", in_key=flow, local_ip="10.0.1.31", out_key=flow, remote_ip="10.0.1.21"}
        Port patch-int
            Interface patch-int
                type: patch
                options: {peer=patch-tun}
        Port br-tun
            Interface br-tun
                type: internal
    Bridge br-int
        Controller "tcp:127.0.0.1:6633"
            is_connected: true
        fail_mode: secure
        Port patch-tun
            Interface patch-tun
                type: patch
                options: {peer=patch-int}
        Port "qvo835f7fd0-b9"
            tag: 1
            Interface "qvo835f7fd0-b9"
        Port br-int
            Interface br-int
                type: internal
    ovs_version: "2.6.1"

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
