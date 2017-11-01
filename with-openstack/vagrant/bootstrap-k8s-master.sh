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

function download_nova() {
    NOVA_COMPUTE_VERSION=2:15.0.7-0ubuntu1~cloud0
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt-get install -y nova-compute=$NOVA_COMPUTE_VERSION
    #apt-get install -y nova-compute
}

function configure_nova() {
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

    # Edit the /etc/nova/nova.conf file, [DEFAULT] section
    sed -i "/^\[DEFAULT\]$/ a transport_url = rabbit://openstack:RABBIT_PASS@os-controller" /etc/nova/nova.conf
    sed -i "/^\[DEFAULT\]$/ a auth_strategy = keystone" /etc/nova/nova.conf
    sed -i "/^\[DEFAULT\]$/ a my_ip = $ENV_MGMT_K8S_MASTER_IP" /etc/nova/nova.conf
    sed -i "/^\[DEFAULT\]$/ a use_neutron = True" /etc/nova/nova.conf
    sed -i "/^\[DEFAULT\]$/ a firewall_driver = nova.virt.firewall.NoopFirewallDriver" /etc/nova/nova.conf

    # Edit the /etc/nova/nova.conf file, [keystone_authtoken] section
    cat >> /etc/nova/nova.conf <<DATA

[keystone_authtoken]
auth_uri = http://os-controller:5000
auth_url = http://os-controller:35357
memcached_servers = os-controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = nova
password = NOVA_PASS
DATA

    # Edit the /etc/nova/nova.conf file, [vnc] section
    cat >> /etc/nova/nova.conf <<DATA

[vnc]
enabled = True
vncserver_listen = 0.0.0.0
vncserver_proxyclient_address = $ENV_MGMT_K8S_MASTER_IP
novncproxy_base_url = http://os-controller:6080/vnc_auto.html
DATA

    # Edit the /etc/nova/nova.conf file, [glance] section
    cat >> /etc/nova/nova.conf <<DATA

[glance]
api_servers = http://os-controller:9292
DATA

    # Edit the /etc/nova/nova.conf file, [oslo_concurrency] section
    sed -i "/^lock_path=/ d" /etc/nova/nova.conf
    sed -i "/^\[oslo_concurrency\]$/ a lock_path = /var/lib/nova/tmp" /etc/nova/nova.conf

    # Edit the /etc/nova/nova.conf file, [placement] section
    sed -i "s|^os_region_name = openstack|os_region_name = RegionOne|" /etc/nova/nova.conf
    sed -i "/^\[placement\]$/ a project_domain_name = Default" /etc/nova/nova.conf
    sed -i "/^\[placement\]$/ a project_name = service" /etc/nova/nova.conf
    sed -i "/^\[placement\]$/ a auth_type = password" /etc/nova/nova.conf
    sed -i "/^\[placement\]$/ a user_domain_name = Default" /etc/nova/nova.conf
    sed -i "/^\[placement\]$/ a auth_url = http://os-controller:35357/v3" /etc/nova/nova.conf
    sed -i "/^\[placement\]$/ a username = placement" /etc/nova/nova.conf
    sed -i "/^\[placement\]$/ a password = PLACEMENT_PASS" /etc/nova/nova.conf

    # Edit the /etc/nova/nova.conf file, [neutron] section
    # See https://kairen.gitbooks.io/openstack-ubuntu-newton/content/ubuntu-binary/neutron/#compute-node
    cat >> /etc/nova/nova.conf <<DATA

[neutron]
url = http://os-controller:9696
auth_url = http://os-controller:35357
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = neutron
password = NEUTRON_PASS
DATA

    # Edit the /etc/nova/nova-compute.conf file, [libvirt] section
    sed -i "/^virt_type=/ d" /etc/nova/nova-compute.conf
    sed -i "/^\[libvirt\]$/ a virt_type = qemu" /etc/nova/nova-compute.conf

    # Restart the Compute service
    service nova-compute restart

    # Log files
    # /var/log/nova/nova-compute.log

    # Reference https://docs.openstack.org/newton/install-guide-ubuntu/nova-compute-install.html
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
    deactivate
}

function configure_kuryr_part1() {
    source /root/admin-openrc

    # create provider network 'provider'
    FLAT_NETWORK_NAME=external
    PROVIDER_NETWORK_NAME=provider
    openstack network create  --share --external --provider-physical-network $FLAT_NETWORK_NAME --provider-network-type flat $PROVIDER_NETWORK_NAME
    echo "# $(date)" | tee -a $CACHE/env.rc
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

    # update security group 'default'
    openstack security group rule create --protocol icmp --remote-ip 0.0.0.0/0 $DEMO_SECGROUP_ID
    openstack security group rule create --protocol tcp --dst-port 22 --remote-ip 0.0.0.0/0 $DEMO_SECGROUP_ID
    openstack security group rule create --protocol tcp --dst-port 80 --remote-ip 0.0.0.0/0 $DEMO_SECGROUP_ID
}

function configure_kuryr_part2() {
    source $CACHE/env.rc

    # install kuryr-kubernetes
    cd /opt/kuryr-kubernetes
    source /opt/kuryr-kubernetes/env/bin/activate
    python setup.py install
    cp /opt/kuryr-kubernetes/env/bin/kuryr-cni /usr/local/bin/kuryr-cni
    cp /opt/kuryr-kubernetes/env/bin/kuryr-k8s-controller /usr/local/bin/kuryr-k8s-controller

    # make /etc/kuryr/kuryr.conf
    ./tools/generate_config_file_samples.sh
    mkdir /etc/kuryr
    cp etc/kuryr.conf.sample /etc/kuryr/kuryr.conf
    mkdir -p /var/cache/kuryr
    mkdir -p /etc/kuryr
    mkdir -p /opt/data/etcd
    cat > /etc/kuryr/kuryr.conf <<DATA
[DEFAULT]
use_stderr = true

[kubernetes]
api_root = http://$ENV_MGMT_K8S_MASTER_IP:8080

[neutron]
auth_uri = http://$ENV_MGMT_OS_CONTROLLER_IP:5000
auth_url = http://$ENV_MGMT_OS_CONTROLLER_IP:35357
memcached_servers = $ENV_MGMT_OS_CONTROLLER_IP:11211
auth_type = password
username = kuryr
password = password
project_name = service
project_domain_name = Default
user_domain_name = Default
signing_dir = /var/cache/kuryr
cafile = /opt/stack/data/ca-bundle.pem

[neutron_defaults]
ovs_bridge = br-int
project = $DEMO_PROJECT_ID
service_subnet = $SERVICE_SUBNET_ID
pod_subnet = $DEMO_SUBNET_ID
pod_security_groups = $DEMO_SECGROUP_ID
DATA
}

function configure_kuryr_part3() {
    # bring up kuryr-kubernetes controller
    source /opt/kuryr-kubernetes/env/bin/activate
    screen -dmS kuryr-kubernetes-controller /opt/kuryr-kubernetes/env/bin/python /opt/kuryr-kubernetes/scripts/run_server.py --config-file /etc/kuryr/kuryr.conf 
    deactivate
}

function configure_kuryr_part4() {
    # create 'demo' docker image
    mkdir demo
    cat > demo/Dockerfile <<DATA
FROM alpine
RUN apk add --no-cache python bash openssh-client curl
COPY server.py /server.py
ENTRYPOINT ["python", "/server.py"]
DATA
    cat > demo/server.py <<DATA
import BaseHTTPServer as http
import platform
class Handler(http.BaseHTTPRequestHandler):
  def do_GET(self):
    self.send_response(200)
    self.send_header('Content-Type', 'text/plain')
    self.end_headers()
    self.wfile.write("%s\n" % platform.node())
if __name__ == '__main__':
  httpd = http.HTTPServer(('', 8080), Handler)
  httpd.serve_forever()
DATA
    docker build -t demo:demo demo
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
    docker pull alpine
}

function configure_k8s() {
    source $CACHE/env.rc

    # bring up etcd
    docker run --name etcd --detach \
           --net host \
           --volume="/opt/data/etcd:/var/etcd:rw" \
           quay.io/coreos/etcd:v3.0.8 /usr/local/bin/etcd \
           --name devstack \
           --data-dir /var/etcd/data \
           --initial-advertise-peer-urls http://$ENV_MGMT_K8S_MASTER_IP:2380 \
           --listen-peer-urls http://0.0.0.0:2380 \
           --listen-client-urls http://0.0.0.0:2379 \
           --advertise-client-urls http://$ENV_MGMT_K8S_MASTER_IP:2379 \
           --initial-cluster-token etcd-cluster-1 \
           --initial-cluster devstack=http://$ENV_MGMT_K8S_MASTER_IP:2380 \
           --initial-cluster-state new

    # bring up hyperkube::devstack-setup-files
    mkdir -p /opt/data/hyperkube
    docker run --name devstack-k8s-setup-files --detach \
           --volume "/opt/data/hyperkube:/srv/kubernetes:rw" \
           gcr.io/google_containers/hyperkube-amd64:v1.4.6 \
           /setup-files.sh \
           "IP:$ENV_MGMT_K8S_MASTER_IP,DNS:kubernetes,DNS:kubernetes.default,DNS:kubernetes.default.svc,DNS:kubernetes.default.svc.cluster.local"

    echo "wait 5 seconds for hyperkube::devstack-setup-files"
    sleep 5

    # bring up hyperkube::apiserver
    KURYR_ETCD_ADVERTISE_CLIENT_URL=http://$ENV_MGMT_K8S_MASTER_IP:2379
    docker run --name kubernetes-api --detach \
           --net host \
           --volume="/opt/data/hyperkube:/srv/kubernetes:rw" \
           gcr.io/google_containers/hyperkube-amd64:v1.4.6 \
           /hyperkube apiserver \
           --service-cluster-ip-range=$KURYR_K8S_CLUSTER_IP_RANGE \
           --insecure-bind-address=0.0.0.0 \
           --insecure-port=8080 \
           --etcd-servers=http://$ENV_MGMT_K8S_MASTER_IP:2379 \
           --admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,ResourceQuota \
           --client-ca-file=/srv/kubernetes/ca.crt \
           --basic-auth-file=/srv/kubernetes/basic_auth.csv \
           --min-request-timeout=300 \
           --tls-cert-file=/srv/kubernetes/server.cert \
           --tls-private-key-file=/srv/kubernetes/server.key \
           --token-auth-file=/srv/kubernetes/known_tokens.csv \
           --allow-privileged=true \
           --v=2 --logtostderr=true

    echo "wait 5 seconds for hyperkube::apiserver"
    sleep 5

    # bring up hyperkube::controller-manager
    docker run --name kubernetes-controller-manager --detach \
           --net host \
           --volume="/opt/data/hyperkube:/srv/kubernetes:rw" \
           gcr.io/google_containers/hyperkube-amd64:v1.4.6 \
           /hyperkube controller-manager \
           --service-account-private-key-file=/srv/kubernetes/server.key \
           --root-ca-file=/srv/kubernetes/ca.crt \
           --min-resync-period=3m \
           --master="http://$ENV_MGMT_K8S_MASTER_IP:8080" \
           --v=2 --logtostderr=true

    echo "wait 5 seconds for hyperkube::controller-manager"
    sleep 5

    # bring up hyperkube::scheduler
    docker run --name kubernetes-scheduler --detach \
           --net host \
           --volume="/opt/data/hyperkube:/srv/kubernetes:rw" \
           gcr.io/google_containers/hyperkube-amd64:v1.4.6 \
           /hyperkube scheduler \
           --master=http://$ENV_MGMT_K8S_MASTER_IP:8080 \
           --v=2 --logtostderr=true

    # ?
    KURYR_CNI_BIN=$(which kuryr-cni)
    mkdir -p /opt/cni/bin /opt/cni/conf
    cp /usr/local/bin/kuryr-cni /opt/cni/bin/kuryr-cni
    cp /opt/kuryr-kubernetes/etc/cni/net.d/10-kuryr.conf /opt/cni/conf/10-kuryr.conf
    cp /opt/kuryr-kubernetes/etc/cni/net.d/99-loopback.conf /opt/cni/conf/99-loopback.conf
    CONTAINER_ID="$(docker ps -aq -f ancestor=gcr.io/google_containers/hyperkube-amd64:v1.4.6 | head -1)"
    docker cp ${CONTAINER_ID}:/hyperkube /tmp/hyperkube
    docker cp ${CONTAINER_ID}:/opt/cni/bin/loopback /tmp/loopback
    docker cp ${CONTAINER_ID}:/usr/bin/nsenter /tmp/nsenter
    cp /tmp/hyperkube /usr/local/bin/hyperkube
    cp /tmp/loopback /opt/cni/bin/loopback
    cp /tmp/nsenter /usr/local/bin/nsenter
    /opt/kuryr-kubernetes/devstack/kubectl version
    cp /opt/kuryr-kubernetes/devstack/kubectl $(dirname /usr/local/bin/hyperkube)/kubectl

    # bring up kubelet
    mkdir -p /opt/data/hyperkube/{kubelet,kubelet.cert}
cat > /etc/systemd/system/kubelet.service <<DATA
[Unit]
Description=Kubernetes Kubelet Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Wants=docker.socket

[Service]
Environment="KUBE_ALLOW_PRIV=--allow-privileged=true"
Environment="KUBE_LOGTOSTDERR=--logtostderr=true --v=2"
Environment="KUBELET_API_SERVER=--api-servers=http://$ENV_MGMT_K8S_MASTER_IP:8080"
Environment="KUBELET_ADDRESS=--address=0.0.0.0 --enable-server"
Environment="KUBELET_NETWORK_PLUGIN=--network-plugin=cni --cni-bin-dir=/opt/cni/bin --cni-conf-dir=/opt/cni/conf"
Environment="KUBELET_DIR=--cert-dir=/opt/data/hyperkube/kubelet.cert --root-dir=/opt/data/hyperkube/kubelet"
ExecStart=/usr/local/bin/hyperkube kubelet \
                \$KUBE_ALLOW_PRIV \
                \$KUBE_LOGTOSTDERR \
                \$KUBELET_API_SERVER \
                \$KUBELET_ADDRESS \
                \$KUBELET_NETWORK_PLUGIN \
                \$KUBELET_DIR
Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target
DATA
    systemctl start kubelet.service
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
                download_nova
                configure_nova
                configure_neutron
                ;;
            upgrade)
                configure_kuryr_part1
                configure_kuryr_part2
                configure_k8s
                configure_kuryr_part3
                configure_kuryr_part4
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
