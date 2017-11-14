#!/bin/bash

set -e

if [ $# -lt 1 ]; then
    echo "Usage: bash $0 <release | reserve | copy>"
    exit 1
fi
CMD=$1
shift

function release() {
    source rc
    # M1 - M5
    openstack server delete $M1
    openstack server delete $M2
    openstack server delete $M3
    openstack server delete $M4
    openstack server delete $M5

    # M6
    #openstack server delete $M6
}

function reserve() {
    source rc

    echo "# $(date)" | tee -a rc

    # M1 - M5
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

    echo "wait 1 minutes for $M1 - $M5 up and running"
    i=60; while [ $i -gt 0 ]; do echo "wait for $i seconds"; i=$(( $i - 1 )); sleep 1; done
    scp -o StrictHostKeyChecking=false -i $PK $PK root@$FIP1:~/.ssh/id_rsa
    scp -o StrictHostKeyChecking=false -i $PK $PK root@$FIP2:~/.ssh/id_rsa
    scp -o StrictHostKeyChecking=false -i $PK $PK root@$FIP3:~/.ssh/id_rsa
    scp -o StrictHostKeyChecking=false -i $PK $PK root@$FIP4:~/.ssh/id_rsa
    scp -o StrictHostKeyChecking=false -i $PK $PK root@$FIP5:~/.ssh/id_rsa

    # M6
    #M6_ID=$(openstack server create --image $I --flavor $F --key-name "$KP" --nic port-id=$PIP6 -f value -c id $M6)
    #echo "export M6_ID=$M6_ID" | tee -a rc

    #echo "wait 1 minutes for $M6 up and running"
    #i=60; while [ $i -gt 0 ]; do echo "wait for $i seconds"; i=$(( $i - 1 )); sleep 1; done
    #scp -o StrictHostKeyChecking=false -i $PK $PK root@$FIP6:~/.ssh/id_rsa
}

function copy() {
    source rc

    # M1 - M5 (ETA 25 mins)
    bash remote-runner-wrapper.sh git_clone
    bash remote-runner-wrapper.sh copy_pkgs
}

$CMD
