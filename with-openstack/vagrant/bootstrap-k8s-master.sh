#!/bin/bash

set -e

ENV_MGMT_NETWORK="10.0.0.0/24"
ENV_MGMT_OS_CONTROLLER_IP="10.0.0.11"
ENV_MGMT_OS_NETWORK_IP="10.0.0.21"
ENV_MGMT_OS_COMPUTE_IP="10.0.0.31"
ENV_MGMT_ODL_CONTROLLER_IP="10.0.0.41"
ENV_MGMT_K8S_MASTER_IP="10.0.0.51"

ENV_TUNNEL_NETWORK="10.0.1.0/24"
ENV_TUNNEL_OS_CONTROLLER_IP="10.0.1.11"
ENV_TUNNEL_OS_NETWORK_IP="10.0.1.21"
ENV_TUNNEL_OS_COMPUTE_IP="10.0.1.31"
ENV_TUNNEL_ODL_CONTROLLER_IP="10.0.1.41"
ENV_TUNNEL_K8S_MASTER_IP="10.0.1.51"

LOG=/tmp/provision.log
date | tee $LOG            # when:  Thu Aug 10 07:48:13 UTC 2017
whoami | tee -a $LOG       # who:   root
pwd | tee -a $LOG          # where: /home/vagrant

CACHE=/vagrant/cache
[ -d $CACHE ] || mkdir -p $CACHE 

function use_public_apt_server() {
    apt install -y software-properties-common
    add-apt-repository cloud-archive:ocata
    apt-get update && APT_UPDATED=true

    # Reference https://docs.openstack.org/newton/install-guide-ubuntu/environment-packages.html
}

function use_local_apt_server() {
    cat > /etc/apt/sources.list <<DATA
deb http://192.168.240.3/ubuntu xenial main restricted
deb http://192.168.240.3/ubuntu xenial universe
deb http://192.168.240.3/ubuntu xenial multiverse
deb http://192.168.240.3/ubuntu xenial-updates main restricted
deb http://192.168.240.3/ubuntu xenial-updates universe
deb http://192.168.240.3/ubuntu xenial-updates multiverse
deb http://192.168.240.3/ubuntu xenial-security main restricted
deb http://192.168.240.3/ubuntu xenial-security universe
deb http://192.168.240.3/ubuntu xenial-security multiverse
deb http://192.168.240.3/ubuntu-cloud-archive xenial-updates/ocata main
DATA
}

function each_node_must_resolve_the_other_nodes_by_name_in_addition_to_IP_address() {
    cat >> /etc/hosts <<DATA
$ENV_MGMT_OS_CONTROLLER_IP os-controller
$ENV_MGMT_OS_NETWORK_IP os-network
$ENV_MGMT_OS_COMPUTE_IP os-compute
$ENV_MGMT_ODL_CONTROLLER_IP odl-controller
$ENV_MGMT_K8S_MASTER_IP k8s-master
DATA

    # Reference https://docs.openstack.org/newton/install-guide-ubuntu/environment-networking.html
}

function install_ntp() {
    CHRONY_VERSION=2.1.1-1
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt-get install -y chrony=$CHRONY_VERSION
    #apt-get install -y chrony

    # # # # # # # # # # # # # # # # ## # # # # # # # # # # # # # # # # # # # # # # # # ## # # # # # # # #

    # To connect to the os-controller node
    sed -i "s/^pool /#pool /g" /etc/chrony/chrony.conf
    sed -i "s/^server /#server /g" /etc/chrony/chrony.conf
    echo "server os-controller iburst" >> /etc/chrony/chrony.conf

    # Restart the NTP service
    service chrony restart

    # Verify operation
    chronyc sources

    # Log files
    # /var/log/chrony/measurements.log
    # /var/log/chrony/statistics.log
    # /var/log/chrony/tracking.log

    # Reference https://docs.openstack.org/newton/install-guide-ubuntu/environment-ntp-other.html
}

function install_k8s_dependency() {
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt-get install -y ebtables ethtool

    # Install docker-ce 17.03
    apt-get install -y docker.io
    apt-get update && apt-get install -y curl apt-transport-https
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    cat <<EOF >/etc/apt/sources.list.d/docker.list
deb https://download.docker.com/linux/$(lsb_release -si | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable
EOF
    apt-get update && apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')
    # verify `systemctl status docker`

    # Install k8s repo
    apt-get update && apt-get install -y apt-transport-https
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
    apt-get update
}

function download_k8s() {
    KUBEADM_VERSION=1.8.1-01
    KUBECTL_VERSION=1.8.0-00
    KUBELET_VERSION=1.8.0-00
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt-get install -y kubeadm=$KUBEADM_VERSION kubectl=$KUBECTL_VERSION kubelet=$KUBELET_VERSION
    #apt-get install -y kubeadm kubectl kubelet
}

function configure_k8s() {
    : 
}

function main() {
    while [ $# -gt 0 ];
    do
        case $1 in
            download)
                #use_local_apt_server
                use_public_apt_server
                each_node_must_resolve_the_other_nodes_by_name_in_addition_to_IP_address
                install_ntp
                install_k8s_dependency
                download_k8s
                ;;
            configure)
                configure_k8s
                ;;
            *)
                echo "unknown mode"
                ;;
        esac
        shift
    done
    echo done
}
main $@
