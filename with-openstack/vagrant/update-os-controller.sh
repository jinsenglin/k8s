#!/bin/bash

# 1-2
systemctl stop neutron-server

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

# 1-12
mysql <<DATA
DROP DATABASE IF EXISTS neutron;
CREATE DATABASE neutron;
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'NEUTRON_DBPASS';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'NEUTRON_DBPASS';
DATA

# 1-13
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

# 1-14
systemctl start neutron-server

# 1-16
curl -u admin:admin http://odl-controller:8080/controller/nb/v2/neutron/networks
