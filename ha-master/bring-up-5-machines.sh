#!/bin/bash

set -e

# flavor
F=2C2G10G

# image
I=Tony_Ubuntu_16.04.2_Srv_Cloud_v1.3

# security group
SG=open-all

# key pair name
KP=devops

# private network name
PN=infra

# private subnet name
PSN=infra

# private IPs
PIP1=192.168.202.101
PIP2=192.168.202.102
PIP3=192.168.202.103
PIP4=192.168.202.104
PIP5=192.168.202.105
PIP6=192.168.202.106

# Reserve resources # TODO Delete
function reserve_PIPs() {
    PIP1_PORT_ID=$(openstack port create --network $PN --fixed-ip subnet=$PSN,ip-address=$PIP1 -f value -c id $PIP1)
    echo "export PIP1_PORT_ID=$PIP1_PORT_ID" | tee -a rc
    PIP2_PORT_ID=$(openstack port create --network $PN --fixed-ip subnet=$PSN,ip-address=$PIP2 -f value -c id $PIP2)
    echo "export PIP2_PORT_ID=$PIP2_PORT_ID" | tee -a rc
    PIP3_PORT_ID=$(openstack port create --network $PN --fixed-ip subnet=$PSN,ip-address=$PIP3 -f value -c id $PIP3)
    echo "export PIP3_PORT_ID=$PIP3_PORT_ID" | tee -a rc
    PIP4_PORT_ID=$(openstack port create --network $PN --fixed-ip subnet=$PSN,ip-address=$PIP4 -f value -c id $PIP4)
    echo "export PIP4_PORT_ID=$PIP4_PORT_ID" | tee -a rc
    PIP5_PORT_ID=$(openstack port create --network $PN --fixed-ip subnet=$PSN,ip-address=$PIP5 -f value -c id $PIP5)
    echo "export PIP5_PORT_ID=$PIP5_PORT_ID" | tee -a rc
    PIP6_PORT_ID=$(openstack port create --network $PN --fixed-ip subnet=$PSN,ip-address=$PIP6 -f value -c id $PIP6)
    echo "export PIP6_PORT_ID=$PIP6_PORT_ID" | tee -a rc
}
#reserve_PIPs

# external network name
EN=Catherine-924

# Reserve resources # TODO Delete
function reserve_FIPs() {
    source rc
    FIP1_ID=$(openstack floating ip create --port $PIP1_PORT_ID --fixed-ip-address $PIP1 -f value -c id $EN)
    echo "export FIP1_ID=$FIP1_ID" | tee -a rc
    FIP2_ID=$(openstack floating ip create --port $PIP2_PORT_ID --fixed-ip-address $PIP2 -f value -c id $EN)
    echo "export FIP2_ID=$FIP2_ID" | tee -a rc
    FIP3_ID=$(openstack floating ip create --port $PIP3_PORT_ID --fixed-ip-address $PIP3 -f value -c id $EN)
    echo "export FIP3_ID=$FIP3_ID" | tee -a rc
    FIP4_ID=$(openstack floating ip create --port $PIP4_PORT_ID --fixed-ip-address $PIP4 -f value -c id $EN)
    echo "export FIP4_ID=$FIP4_ID" | tee -a rc
    FIP5_ID=$(openstack floating ip create --port $PIP5_PORT_ID --fixed-ip-address $PIP5 -f value -c id $EN)
    echo "export FIP5_ID=$FIP5_ID" | tee -a rc
    FIP6_ID=$(openstack floating ip create --port $PIP6_PORT_ID --fixed-ip-address $PIP6 -f value -c id $EN)
    echo "export FIP6_ID=$FIP6_ID" | tee -a rc
}
#reserve_FIPs

# Export floating IPs
function export_FIPs() {
    source rc
    FIP1=$(openstack floating ip show $FIP1_ID -f value -c floating_ip_address)
    echo "export FIP1=$FIP1" | tee -a rc
    FIP2=$(openstack floating ip show $FIP2_ID -f value -c floating_ip_address)
    echo "export FIP2=$FIP2" | tee -a rc
    FIP3=$(openstack floating ip show $FIP3_ID -f value -c floating_ip_address)
    echo "export FIP3=$FIP3" | tee -a rc
    FIP4=$(openstack floating ip show $FIP4_ID -f value -c floating_ip_address)
    echo "export FIP4=$FIP4" | tee -a rc
    FIP5=$(openstack floating ip show $FIP5_ID -f value -c floating_ip_address)
    echo "export FIP5=$FIP5" | tee -a rc
    FIP6=$(openstack floating ip show $FIP6_ID -f value -c floating_ip_address)
    echo "export FIP6=$FIP6" | tee -a rc
}
#export_FIPs

# virtual machine name
M1=k8s-master1
M2=k8s-master2
M3=k8s-master3
M4=k8s-node1
M5=k8s-node2

source rc
#openstack server create --image $I --flavor $F --key-name "$KP" --nic port-id=$PIP2 --wait $M1
