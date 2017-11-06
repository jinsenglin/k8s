#!/bin/bash

set -e

echo "# $(date)" | tee -a rc

# flavor
F=2C2G10G
echo "export F=$F" | tee -a rc

# image
I=Tony_Ubuntu_16.04.2_Srv_Cloud_v1.3
echo "export I=$I" | tee -a rc

# security group
SG=open-all
echo "export SG=$SG" | tee -a rc

# key pair name
KP=devops
echo "export KP=$KP" | tee -a rc

# private network name
PN=infra
echo "export PN=$PN" | tee -a rc

# private subnet name
PSN=infra
echo "export PSN=$PSN" | tee -a rc

# private IPs
PIP0=192.168.202.100
PIP1=192.168.202.101
PIP2=192.168.202.102
PIP3=192.168.202.103
PIP4=192.168.202.104
PIP5=192.168.202.105

function export_PIPs() {
    echo "export PIP0=$PIP0" | tee -a rc

    echo "export PIP1=$PIP1" | tee -a rc

    echo "export PIP2=$PIP2" | tee -a rc

    echo "export PIP3=$PIP3" | tee -a rc

    echo "export PIP4=$PIP4" | tee -a rc

    echo "export PIP5=$PIP5" | tee -a rc
}
#export_PIPs

# Reserve resources
function reserve_PIPs() {
    PIP0_PORT_ID=$(openstack port create --network $PN --fixed-ip subnet=$PSN,ip-address=$PIP0 -f value -c id $PIP0)
    echo "export PIP0_PORT_ID=$PIP0_PORT_ID" | tee -a rc

    PIP1_PORT_ID=$(openstack port create --network $PN --fixed-ip subnet=$PSN,ip-address=$PIP1 --allowed-address ip-address=$PIP0 -f value -c id $PIP1)
    echo "export PIP1_PORT_ID=$PIP1_PORT_ID" | tee -a rc

    PIP2_PORT_ID=$(openstack port create --network $PN --fixed-ip subnet=$PSN,ip-address=$PIP2 --allowed-address ip-address=$PIP0 -f value -c id $PIP2)
    echo "export PIP2_PORT_ID=$PIP2_PORT_ID" | tee -a rc

    PIP3_PORT_ID=$(openstack port create --network $PN --fixed-ip subnet=$PSN,ip-address=$PIP3 --allowed-address ip-address=$PIP0 -f value -c id $PIP3)
    echo "export PIP3_PORT_ID=$PIP3_PORT_ID" | tee -a rc

    PIP4_PORT_ID=$(openstack port create --network $PN --fixed-ip subnet=$PSN,ip-address=$PIP4 --allowed-address ip-address=$PIP0 -f value -c id $PIP4)
    echo "export PIP4_PORT_ID=$PIP4_PORT_ID" | tee -a rc

    PIP5_PORT_ID=$(openstack port create --network $PN --fixed-ip subnet=$PSN,ip-address=$PIP5 --allowed-address ip-address=$PIP0 -f value -c id $PIP5)
    echo "export PIP5_PORT_ID=$PIP5_PORT_ID" | tee -a rc
}
#reserve_PIPs

# external network name
EN=Catherine-924
echo "export EN=$EN" | tee -a rc

# Reserve resources
function reserve_FIPs() {
    source rc
    FIP0_ID=$(openstack floating ip create --port $PIP0_PORT_ID --fixed-ip-address $PIP0 -f value -c id $EN)
    echo "export FIP0_ID=$FIP0_ID" | tee -a rc

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
}
#reserve_FIPs

# Export floating IPs
function export_FIPs() {
    source rc
    echo "export FIPC=192.168.240.48" | tee -a rc

    FIP0=$(openstack floating ip show $FIP0_ID -f value -c floating_ip_address)
    echo "export FIP0=$FIP0" | tee -a rc

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
}
#export_FIPs

# virtual machine name
M1=k8s-master1
M2=k8s-master2
M3=k8s-master3
M4=k8s-node1
M5=k8s-node2

function export_Ms() {
    echo "export M1=$M1" | tee -a rc

    echo "export M2=$M2" | tee -a rc

    echo "export M3=$M3" | tee -a rc

    echo "export M4=$M4" | tee -a rc

    echo "export M5=$M5" | tee -a rc
}
#export_Ms

function reserve_Ms() {
    source rc
    M1_ID=$(openstack server create --image $I --flavor $F --key-name "$KP" --nic port-id=$PIP1 -f value -c id $M1)
    echo "export M1_ID=$M1_ID" | tee -a rc

    M2_ID=$(openstack server create --image $I --flavor $F --key-name "$KP" --nic port-id=$PIP2 -f value -c id $M2)
    echo "export M2_ID=$M2_ID" | tee -a rc

    M3_ID=$(openstack server create --image $I --flavor $F --key-name "$KP" --nic port-id=$PIP3 -f value -c id $M3)
    echo "export M3_ID=$M3_ID" | tee -a rc

    M4_ID=$(openstack server create --image $I --flavor $F --key-name "$KP" --nic port-id=$PIP4 -f value -c id $M4)
    echo "export M4_ID=$M4_ID" | tee -a rc

    M5_ID=$(openstack server create --image $I --flavor $F --key-name "$KP" --nic port-id=$PIP5 -f value -c id $M5)
    echo "export M5_ID=$M5_ID" | tee -a rc
}
#reserve_Ms

# private key file used to ssh login virtual machines
PK=~/.ssh/id_rsa_devops
echo "export PK=$PK" | tee -a rc

function copy_PK() {
    source rc
    scp -i $PK $PK root@$FIP1:~/.ssh/id_rsa
    scp -i $PK $PK root@$FIP2:~/.ssh/id_rsa
    scp -i $PK $PK root@$FIP3:~/.ssh/id_rsa
    scp -i $PK $PK root@$FIP4:~/.ssh/id_rsa
    scp -i $PK $PK root@$FIP5:~/.ssh/id_rsa
}
#copy_PK

source rc
