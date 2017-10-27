#!/bin/bash

# 1-0
# https://ihrachyshka.com/2017/05/17/gratuitous-arp-for-openstack-neutron/
# https://gist.github.com/spangenberg/6bfe47553264231e2d95dc883151d5f4
# https://lists.opendaylight.org/pipermail/dev/2017-January/003093.html
# http://docs.opendaylight.org/en/stable-carbon/submodules/netvirt/docs/openstack-guide/openstack-with-netvirt.html
#
# Enable arp_accept for the external (enp0s10) interface;
# echo 1 > echo 1 > /proc/sys/net/ipv4/conf/enp0s10/arp_accept

# 1-2
systemctl stop neutron-l3-agent
systemctl stop neutron-openvswitch-agent
systemctl stop openvswitch-switch

# 1-3
rm -rf /var/log/openvswitch/*
rm -rf /etc/openvswitch/conf.db
systemctl start openvswitch-switch
ovs-vsctl show

# 1-4
ovs-vsctl set-manager tcp:10.0.0.41:6640
ovs-vsctl show

# 1-5
ovs-vsctl set Open_vSwitch . other_config:local_ip=10.0.1.21
ovs-vsctl show
ovs-vsctl get Open_vSwitch . other_config

# 1-6
apt-get install -y python-networking-odl=1:2.0.1~git20160926.416a5c7-0ubuntu1~cloud0

# 1-7
sed -i "/^mechanism_drivers = / d" /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i "/^\[ml2\]$/ a mechanism_drivers = opendaylight" /etc/neutron/plugins/ml2/ml2_conf.ini

# 1-8
cat >> /etc/neutron/plugins/ml2/ml2_conf.ini <<DATA

[ml2_odl]
url = http://odl-controller:8080/controller/nb/v2/neutron
password = admin
username = admin
DATA

# 1-9
sed -i "/^service_plugins = / d" /etc/neutron/neutron.conf
sed -i "/^\[DEFAULT\]$/ a service_plugins = odl-router" /etc/neutron/neutron.conf

# 1-10
sed -i "/^\[DEFAULT\]$/ a force_metadata = True" /etc/neutron/dhcp_agent.ini

systemctl restart neutron-dhcp-agent
systemctl restart neutron-metadata-agent

# 1-11
#cat >> /etc/neutron/dhcp_agent.ini <<DATA
#
#[OVS]
#ovsdb_interface = vsctl
#DATA

# 1-15
ovs-vsctl set Open_vSwitch . other_config:provider_mappings=external:enp0s10
ovs-vsctl show
ovs-vsctl get Open_vSwitch . other_config
