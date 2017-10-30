#!/bin/bash

<<NOTE
[ os-controller ]

# # 1. 建立 kuryr user
# create user 'kuryr'
KURYR_USER_ID=$(openstack user create kuryr --password password --domain=Default --or-show -c id -f value)

# create role 'service'
SERVICE_ROLE_ID=$(openstack role create service --or-show -c id -f value)

# link user, role, and project
openstack role add service --user kuryr --project service --user-domain Default --project-domain Default
openstack role add admin --user kuryr --project service --user-domain Default --project-domain Default

# # 2. 建立 'kuryr-kubernetes' service
# create service 'kuryr-kubernetes'
KURYR_SVC_ID=$(openstack service create kuryr-kubernetes --name kuryr-kubernetes --description="Kuryr-Kubernetes Service" -f value -c id)

# # 3. 建立 'shared-default-subnetpool' subnet pool
# create subnet pool 'shared-default-subnetpool'
openstack subnet pool create shared-default-subnetpool --default-prefix-length 26 --pool-prefix "10.1.0.0/22" --share --default
SUBNETPOOL_V4_ID=$(openstack subnet pool show shared-default-subnetpool -f value -c id)

# # 4. 建立 'demo' network
# set network 'demo'
DEMO_NET_ID=(openstack network create --project demo -c id -f value demo)

# # 5. 建立 'demo' subnet
# create subnet 'demo'
DEMO_SUBNET_ID=$(openstack subnet create --project demo --ip-version 4 --subnet-pool $SUBNETPOOL_V4_ID --network $DEMO_NET_ID -c id -f value demo)

# # 6. 建立 'k8s-service-subnet' subnet
# create subnet 'k8s-service-subnet'
SERVICE_SUBNET_ID=$(openstack subnet create --project demo --ip-version 4 --no-dhcp --gateway none --subnet-pool $SUBNETPOOL_V4_ID --network $DEMO_NET_ID -c id -f value k8s-service-subnet)
SERVICE_CIDR=$(openstack subnet show -c cidr -f value $SERVICE_SUBNET_ID)
KURYR_K8S_CLUSTER_IP_RANGE=$SERVICE_CIDR
GATEWAY_IP=$(openstack subnet show -c cidr -f value $SERVICE_SUBNET_ID | awk -F '-' '{print $2}')

# set gateway
openstack subnet set --gateway $GATEWAY_IP --no-allocation-pool $SERVICE_SUBNET_ID

# # 7. 建立 'demo' router
# create router 'demo'
DEMO_ROUTER_ID=$(openstack router create --project demo -c id -f value demo)

# # 8. 將 'demo' subnet 加入 'demo' router
# link subnet and router
openstack router add subnet $DEMO_ROUTER_ID $DEMO_SUBNET_ID

# # 9. 將 'k8s-service-subnet' subnet 加入 'demo' router
# link subnet and router
openstack router add subnet $DEMO_ROUTER_ID $SERVICE_SUBNET_ID

# # 10. 取得 'demo' project 的 'default' security group
# get security group 'default'
DEMO_SECGROUP_ID=$(openstack security group list --project demo -c ID -f value)

[ k8s-master ]

NOTE
