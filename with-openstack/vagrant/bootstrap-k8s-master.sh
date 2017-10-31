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

    rm -rf /var/lib/apt/lists/*
    echo 'APT::Get::AllowUnauthenticated "true";' > /etc/apt/apt.conf.d/99-use-local-apt-server
    apt-get update && APT_UPDATED=true
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

function install_utilities() {
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt-get install -y crudini
}

function install_python() {
    PYTHON_VERSION=2.7.11-1
    PYTHON_PIP_VERSION=8.1.1-2ubuntu0.4
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt-get install -y python=$PYTHON_VERSION python-pip=$PYTHON_PIP_VERSION
    #apt-get install -y python python-pip
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

function install_openstack_cli() {
    PYTHON_OPENSTACKCLIENT_VERSION=3.8.1-0ubuntu3~cloud0
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt install -y python-openstackclient=$PYTHON_OPENSTACKCLIENT_VERSION
    #apt install -y python-openstackclient

    cat > /root/admin-openrc <<DATA
export OS_USERNAME=admin
export OS_PASSWORD=ADMIN_PASS
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://os-controller:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
DATA

    cat > /root/demo-openrc <<DATA
export OS_USERNAME=demo
export OS_PASSWORD=DEMO_PASS
export OS_PROJECT_NAME=demo
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://os-controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
DATA

}

function download_neutron() {
    NEUTRON_PLUGIN_ML2_VERSION=2:10.0.3-0ubuntu1~cloud0
    NEUTRON_OPENVSWITCH_AGENT_VERSION=2:10.0.3-0ubuntu1~cloud0
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt install -y neutron-plugin-ml2=$NEUTRON_PLUGIN_ML2_VERSION \
                   neutron-openvswitch-agent=$NEUTRON_OPENVSWITCH_AGENT_VERSION
#    apt install -y neutron-plugin-ml2 \
#                   neutron-openvswitch-agent
}

function configure_neutron() {
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

    # Edit the /etc/sysctl.conf
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#compute-node
    sed -i "$ a net.ipv4.conf.all.rp_filter = 0" /etc/sysctl.conf
    sed -i "$ a net.ipv4.conf.default.rp_filter = 0" /etc/sysctl.conf
    sed -i "$ a net.bridge.bridge-nf-call-iptables = 1" /etc/sysctl.conf
    sed -i "$ a net.bridge.bridge-nf-call-ip6tables = 1" /etc/sysctl.conf
    sysctl -p

    # Edit the /etc/neutron/neutron.conf file, [database] section
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#compute-node
    sed -i "s|^connection = |#connection = |" /etc/neutron/neutron.conf

    # Edit the /etc/neutron/neutron.conf file, [DEFAULT] section
    sed -i "/^\[DEFAULT\]$/ a service_plugins = router" /etc/neutron/neutron.conf
    sed -i "/^\[DEFAULT\]$/ a allow_overlapping_ips = True" /etc/neutron/neutron.conf
    sed -i "/^\[DEFAULT\]$/ a transport_url = rabbit://openstack:RABBIT_PASS@os-controller" /etc/neutron/neutron.conf
    sed -i "/^\[DEFAULT\]$/ a auth_strategy = keystone" /etc/neutron/neutron.conf

    # Edit the /etc/neutron/neutron.conf file, [keystone_authtoken] section
    echo -e "auth_uri = http://os-controller:5000\nauth_url = http://os-controller:35357\nmemcached_servers = os-controller:11211\nauth_type = password\nproject_domain_name = Default\nuser_domain_name = Default\nproject_name = service\nusername = neutron\npassword = NEUTRON_PASS\n" | sed -i "/^\[keystone_authtoken\]/ r /dev/stdin" /etc/neutron/neutron.conf

    # Edit the /etc/neutron/plugins/ml2/openvswitch_agent.ini file, [ovs] section
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#compute-node
    sed -i "/^\[ovs\]$/ a local_ip = $ENV_TUNNEL_K8S_MASTER_IP" /etc/neutron/plugins/ml2/openvswitch_agent.ini 

    # Edit the /etc/neutron/plugins/ml2/openvswitch_agent.ini file, [agent] section
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#compute-node
    sed -i "/^\[agent\]$/ a tunnel_types = vxlan" /etc/neutron/plugins/ml2/openvswitch_agent.ini 
    sed -i "/^\[agent\]$/ a l2_population = True" /etc/neutron/plugins/ml2/openvswitch_agent.ini 
    sed -i "/^\[agent\]$/ a prevent_arp_spoofing = True" /etc/neutron/plugins/ml2/openvswitch_agent.ini 

    # Edit the /etc/neutron/plugins/ml2/openvswitch_agent.ini file, [securitygroup] section
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#compute-node
    sed -i "/^\[securitygroup\]$/ a enable_security_group = True" /etc/neutron/plugins/ml2/openvswitch_agent.ini 
    sed -i "/^\[securitygroup\]$/ a firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver" /etc/neutron/plugins/ml2/openvswitch_agent.ini 

    # Restart the Networking services
    service openvswitch-switch restart
    service neutron-openvswitch-agent restart

    # Log files
    # /var/log/neutron/neutron-openvswitch-agent.log
    # /var/log/neutron/neutron-ovs-cleanup.log
    # /var/log/openvswitch/ovsdb-server.log
    # /var/log/openvswitch/ovs-vswitchd.log

    # References
    # https://docs.openstack.org/newton/install-guide-ubuntu/neutron-compute-install.html
    # https://docs.openstack.org/newton/install-guide-ubuntu/neutron-compute-install-option2.html
    # https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#compute-node
    # https://www.centos.bz/2012/04/linux-sysctl-conf/
}

function download_kuryr() {
    KURYR_VERSION=0.1.0
    git clone -b $KURYR_VERSION https://github.com/openstack/kuryr-kubernetes.git /opt/kuryr-kubernetes

    cd /opt/kuryr-kubernetes
    pip install virtualenv
    virtualenv env
    source /opt/kuryr-kubernetes/env/bin/activate
    pip install -r requirements.txt -c https://raw.githubusercontent.com/openstack/requirements/stable/ocata/upper-constraints.txt
}

function configure_kuryr() {
    source ~/admin-openrc

    # create provider network 'provider'
    FLAT_NETWORK_NAME=external
    PROVIDER_NETWORK_NAME=provider
    openstack network create  --share --external --provider-physical-network $FLAT_NETWORK_NAME --provider-network-type flat $PROVIDER_NETWORK_NAME
    echo "export FLAT_NETWORK_NAME=$FLAT_NETWORK_NAME" | tee -a $CACHE/env.rc
    echo "export PROVIDER_NETWORK_NAME=$PROVIDER_NETWORK_NAME" | tee -a $CACHE/env.rc

    # create subnet 'provider'
    openstack subnet create --network $PROVIDER_NETWORK_NAME --allocation-pool start=10.0.3.230,end=10.0.3.250 --dns-nameserver 8.8.8.8 --gateway 10.0.3.1 --subnet-range 10.0.3.0/24 --no-dhcp $PROVIDER_NETWORK_NAME

    # create flavor 'm1.nano'
    openstack flavor create --id 0 --vcpus 1 --ram 64 --disk 1 m1.nano

    # create user 'kuryr'
    KURYR_USER_ID=$(openstack user create kuryr --password password --domain=Default --or-show -c id -f value)
    echo "export KURYR_USER_ID=$KURYR_USER_ID" | tee -a $CACHE/env.rc

    # create role 'service'
    SERVICE_ROLE_ID=$(openstack role create service --or-show -c id -f value)
    echo "export SERVICE_ROLE_ID=$SERVICE_ROLE_ID" | tee -a $CACHE/env.rc

    # assign 'admin' role to 'kuryr' user in 'admin' project
    openstack role add service --user kuryr --project service --user-domain Default --project-domain Default

    # assign 'service' role to 'kuryr' user in 'service' project
    openstack role add admin --user kuryr --project service --user-domain Default --project-domain Default

    # create service 'kuryr-kubernetes'
    KURYR_SVC_ID=$(openstack service create kuryr-kubernetes --name kuryr-kubernetes --description="Kuryr-Kubernetes Service" -f value -c id)
    echo "export KURYR_SVC_ID=$KURYR_SVC_ID" | tee -a $CACHE/env.rc
    
    # create subnet pool 'shared-default-subnetpool'
    SUBNETPOOL_V4_ID=$(openstack subnet pool create shared-default-subnetpool --default-prefix-length 26 --pool-prefix "10.1.0.0/22" --share --default -f value -c id)
    echo "export SUBNETPOOL_V4_ID=$SUBNETPOOL_V4_ID" | tee -a $CACHE/env.rc
    
    # get id of project 'demo'
    DEMO_PROJECT_ID=$(openstack project show -c id -f value demo)
    echo "export DEMO_PROJECT_ID=$DEMO_PROJECT_ID" | tee -a $CACHE/env.rc 

    # create network 'demo'
    DEMO_NET_ID=$(openstack network create --project demo -c id -f value demo)
    echo "export DEMO_NET_ID=$DEMO_NET_ID" | tee -a $CACHE/env.rc 

    # create subnet 'demo'
    DEMO_SUBNET_ID=$(openstack subnet create --project demo --ip-version 4 --subnet-pool $SUBNETPOOL_V4_ID --network $DEMO_NET_ID -c id -f value demo)
    echo "export DEMO_SUBNET_ID=$DEMO_SUBNET_ID" | tee -a $CACHE/env.rc 

    # create subnet 'k8s-service-subnet'
    SERVICE_SUBNET_ID=$(openstack subnet create --project demo --ip-version 4 --no-dhcp --gateway none --subnet-pool $SUBNETPOOL_V4_ID --network $DEMO_NET_ID -c id -f value k8s-service-subnet)
    echo "export SERVICE_SUBNET_ID=$SERVICE_SUBNET_ID" | tee -a $CACHE/env.rc 

    # get cidr of subnet 'k8s-service-subnet'
    SERVICE_CIDR=$(openstack subnet show -c cidr -f value $SERVICE_SUBNET_ID)
    KURYR_K8S_CLUSTER_IP_RANGE=$SERVICE_CIDR
    echo "export SERVICE_CIDR=$SERVICE_CIDR" | tee -a $CACHE/env.rc 
    echo "export KURYR_K8S_CLUSTER_IP_RANGE=$KURYR_K8S_CLUSTER_IP_RANGE" | tee -a $CACHE/env.rc 

    # parse allocation_pools of subnet 'k8s-service-subnet'
    GATEWAY_IP=$(openstack subnet show -c allocation_pools -f value $SERVICE_SUBNET_ID | awk -F '-' '{print $2}')
    echo "export GATEWAY_IP=$GATEWAY_IP" | tee -a $CACHE/env.rc 

    # update gateway of subnet 'k8s-service-subnet'
    openstack subnet set --gateway $GATEWAY_IP --no-allocation-pool $SERVICE_SUBNET_ID

    # create router 'demo'
    DEMO_ROUTER_ID=$(openstack router create --project demo -c id -f value demo)
    echo "export DEMO_ROUTER_ID=$DEMO_ROUTER_ID" | tee -a $CACHE/env.rc 

    # link router 'demo' and subnet 'demo'
    openstack router add subnet $DEMO_ROUTER_ID $DEMO_SUBNET_ID

    # link router 'demo' and subnet 'k8s-service-subnet'
    openstack router add subnet $DEMO_ROUTER_ID $SERVICE_SUBNET_ID

    # get security group 'default' of project 'demo'
    DEMO_SECGROUP_ID=$(openstack security group list --project demo -c ID -f value)
    echo "export DEMO_SECGROUP_ID=$DEMO_SECGROUP_ID" | tee -a $CACHE/env.rc 
}

function download_k8s() {
    DOCKER_VERSION=1.12
    DOCKER_ENGINE_VERSION=1.12.6~cs13-0~ubuntu-xenial
    ETCD_VERSION=v3.0.8
    HYPERKUBE_VERSION=v1.4.6
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt-get install --no-install-recommends apt-transport-https curl software-properties-common

    curl -fsSL 'https://sks-keyservers.net/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e' | apt-key add -
    add-apt-repository "deb https://packages.docker.com/$DOCKER_VERSION/apt/repo/ ubuntu-$(lsb_release -cs) main"
    apt-get update
    apt-cache madison docker-engine
    apt-get -y install docker-engine=$DOCKER_ENGINE_VERSION

    docker pull quay.io/coreos/etcd:$ETCD_VERSION
    docker pull gcr.io/google_containers/hyperkube-amd64:$HYPERKUBE_VERSION
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
                install_utilities
                install_python
                install_ntp
                install_openstack_cli
                download_neutron
                download_kuryr
                download_k8s
                ;;
            configure)
                configure_neutron
                ;;
            upgrade)
                configure_kuryr
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
