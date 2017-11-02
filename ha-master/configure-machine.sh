#!/bin/bash

set -e

function update_etc_sysctl_conf() {
# update '/etc/sysctl.conf' file

# Enable iptables Filtering on Bridge Devices
cat >>  /etc/sysctl.conf <<DATA
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-arptables = 1
DATA

# Apply settings immediately and verify that the value is 1.
sysctl -p
sysctl net.bridge.bridge-nf-call-iptables
sysctl net.bridge.bridge-nf-call-ip6tables
sysctl net.bridge.bridge-nf-call-arptables
}

function bring_up_etcd_cluster() {
    source rc

    case $HOSTNAME in
        $M1)
            echo "M1"
            docker ps --filter "name=etcd" | wc -l
            ;;
        $M2)
            echo "M2"
            docker ps --filter "name=etcd" | wc -l
            ;;
        $M3)
            echo "M3"
            docker ps --filter "name=etcd" | wc -l
            ;;
        $M4)
            echo "M4 has nothing to do in step 'configure-machine.sh'"
            ;;
        $M5)
            echo "M5 has nothing to do in step 'configure-machine.sh'"
            ;;
        *)
            echo "unknown hostname"
            ;;
    esac
    :
}

#update_etc_sysctl_conf
bring_up_etcd_cluster
#run_kubeadm_init
#install_flannel
#setup_ha_master
#setup_keepalived
#setup_nginx_lb
#update_kube_proxy
#run_kubeadm_join
