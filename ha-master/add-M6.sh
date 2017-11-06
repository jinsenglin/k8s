#!/bin/bash

set -e

function provision() {
    source rc

    echo "# $(date)" | tee -a rc

    PIP6=192.168.202.106
    echo "export PIP6=$PIP6" | tee -a rc
    
    PIP6_PORT_ID=$(openstack port create --network $PN --fixed-ip subnet=$PSN,ip-address=$PIP6 --allowed-address ip-address=$PIP0 -f value -c id $PIP6)
    echo "export PIP6_PORT_ID=$PIP6_PORT_ID" | tee -a rc
    
    FIP6_ID=$(openstack floating ip create --port $PIP6_PORT_ID --fixed-ip-address $PIP6 -f value -c id $EN)
    echo "export FIP6_ID=$FIP6_ID" | tee -a rc
    
    FIP6=$(openstack floating ip show $FIP6_ID -f value -c floating_ip_address)
    echo "export FIP6=$FIP6" | tee -a rc
    
    M6=k8s-node3
    echo "export M6=$M6" | tee -a rc
    
    M6_ID=$(openstack server create --image $I --flavor $F --key-name "$KP" --nic port-id=$PIP6 -f value -c id --wait $M6)
    echo "export M6_ID=$M6_ID" | tee -a rc

    echo "wait 1 minutes for $M6 up and running"
    i=60; while [ $i -gt 0 ]; do echo "wait for $i seconds"; i=$(( $i - 1 )); sleep 1; done
    scp -o StrictHostKeyChecking=false -i $PK $PK root@$FIP6:~/.ssh/id_rsa
}
#provision

# bash remote-runner
