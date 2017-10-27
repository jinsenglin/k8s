#!/bin/bash

# Abstract
#
# apt-get install -y neutron-lbaasv2-agent
# Edit the /etc/neutron/lbaas_agent.ini:

    # [DEFAULT]
    # interface_driver = openvswitch
    # ovs_use_veth = False
    #
    # [haproxy]
    # user_group = haproxy

# Edit the /etc/neutron/neutron_lbaas.conf:

    # [service_providers]
    # service_provider = LOADBALANCERV2:Haproxy:neutron_lbaas.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default

# service neutron-lbaasv2-agent restart

# -------------------------------------------------------------------

# Verify
#
# neutron lbaas-loadbalancer-list
# neutron lbaas-listener-list
# neutron lbaas-pool-list
# neutron lbaas-member-list default/demo:TCP:80

# -------------------------------------------------------------------

# Addtional Resource
# https://docs.openstack.org/ocata/networking-guide/config-lbaas.html
# Configuring LBaaS v2 with an agent

# Step 1: Add the LBaaS v2 service plug-in to the service_plugins configuration directive in /etc/neutron/neutron.conf.

#
# service_plugins = [existing service plugins],neutron_lbaas.services.loadbalancer.plugin.LoadBalancerPluginv2
#

# ---

# Step 2: Add the LBaaS v2 service provider to the service_provider configuration directive within the [service_providers] section in /etc/neutron/neutron_lbaas.conf.

#
# service_provider = LOADBALANCERV2:Haproxy:neutron_lbaas.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default
#

# ---

# Step 3: Select the driver that manages virtual interfaces in /etc/neutron/lbaas_agent.ini.

#
# [DEFAULT]
# interface_driver = openvswitch
#

# ---

# Step 4: Run the neutron-lbaas database migration

#
# `neutron-db-manage --subproject neutron-lbaas upgrade head`
#

# ---

# Step 5: Start the LBaaS v2 agent

#
# neutron-lbaasv2-agent --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/lbaas_agent.ini
#

# ---

# Step 6: Restart the Network service to activate the new configuration. You are now ready to create load balancers with the LBaaS v2 agent.

#
# ?
#
