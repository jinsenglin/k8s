#!/bin/bash

# 1-2
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
ovs-vsctl set Open_vSwitch . other_config:local_ip=10.0.1.31
ovs-vsctl show
ovs-vsctl get Open_vSwitch . other_config

# 1-6
apt-get install -y python-networking-odl=1:2.0.1~git20160926.416a5c7-0ubuntu1~cloud0

# 1-9
sed -i "/^service_plugins = / d" /etc/neutron/neutron.conf
sed -i "/^\[DEFAULT\]$/ a service_plugins = odl-router" /etc/neutron/neutron.conf

# 1-15
ovs-vsctl set Open_vSwitch . other_config:provider_mappings=external:enp0s10
ovs-vsctl show
ovs-vsctl get Open_vSwitch . other_config

<<LOG
`ovs-ofctl -OOpenFlow13 dump-flows br-int | grep 10.0.3.240`

 cookie=0x8000003, duration=175.933s, table=21, n_packets=0, n_bytes=0, priority=42,ip,metadata=0x222e0/0xfffffffe,nw_dst=10.0.3.240 actions=goto_table:25
 cookie=0x8000004, duration=175.994s, table=25, n_packets=0, n_bytes=0, priority=10,ip,nw_dst=10.0.3.240 actions=set_field:10.10.10.3->ip_dst,write_metadata:0x222e2/0xfffffffe,goto_table:27
 cookie=0x8000004, duration=175.982s, table=26, n_packets=0, n_bytes=0, priority=10,ip,metadata=0x222e2/0xfffffffe,nw_src=10.10.10.3 actions=set_field:10.0.3.240->ip_src,write_metadata:0x222e0/0xfffffffe,goto_table:28

Are there packets on the outgoing flow (matching src_ip=<floating_ip>)?
If not, this probably means that OpenDaylight is failing to resolve the MAC of the provided external gateway, required for forwarding packets to the external network.
LOG
