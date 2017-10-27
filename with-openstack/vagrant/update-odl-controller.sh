#!/bin/bash

# 1-1
# Change Boron-SR3 to Boron-SR4
# feature:install odl-netvirt-openstack odl-dlux-core odl-mdsal-apidocs

<<LOG
odl Failed to send GARP for IP.

2017-08-28 10:13:32,586 | ERROR | pool-39-thread-1 | NatUtil                          | 355 - org.opendaylight.netvirt.natservice-impl - 0.3.4.Boron-SR4 | No resolution was found to GW ip IpAddress [_ipv4Address=Ipv4Address [_value=10.0.3.11]] in subnet b51bfc4c-05f9-4ac5-899a-ce5a9ddf62ac
2017-08-28 10:14:39,099 | ERROR | pool-39-thread-1 | InterfacemgrProvider             | 337 - org.opendaylight.genius.interfacemanager-impl - 0.1.4.Boron-SR4 | Interface 648742a4-e29b-45cf-9140-734879b4855e is not present
2017-08-28 10:15:49,353 | ERROR | pool-39-thread-1 | NatUtil                          | 355 - org.opendaylight.netvirt.natservice-impl - 0.3.4.Boron-SR4 | No resolution was found to GW ip IpAddress [_ipv4Address=Ipv4Address [_value=10.10.10.1]] in subnet 0b594e58-591c-437c-9e72-31d293a2f3c3
2017-08-28 10:15:50,185 | ERROR | pool-39-thread-1 | InterfacemgrProvider             | 337 - org.opendaylight.genius.interfacemanager-impl - 0.1.4.Boron-SR4 | Interface 0e35c253-c213-44bf-a81b-8d7fcbc153dc is not present
2017-08-28 10:19:59,065 | ERROR | pool-39-thread-1 | VpnInterfaceManager              | 346 - org.opendaylight.netvirt.vpnmanager-impl - 0.3.4.Boron-SR4 | Handling addition of VPN interface b89207cf-9aac-47c9-96a0-e93199ee25de skipped as interfaceState is not available
2017-08-28 10:20:03,163 | ERROR | ult-dispatcher-6 | LocalThreePhaseCommitCohort      | 202 - org.opendaylight.controller.sal-distributed-datastore - 1.4.4.Boron-SR4 | Failed to prepare transaction member-1-datastore-config-fe-0-txn-753 on backend
2017-08-28 10:20:03,184 | ERROR | nPool-1-worker-1 | SubnetOpDpnManager               | 346 - org.opendaylight.netvirt.vpnmanager-impl - 0.3.4.Boron-SR4 | Cannot get, portOp for port b89207cf-9aac-47c9-96a0-e93199ee25de is not available in datastore
2017-08-28 10:20:03,193 | ERROR | CommitFutures-6  | MDSALManager                     | 334 - org.opendaylight.genius.mdsalutil-impl - 0.1.4.Boron-SR4 | Install Flow -- Failed because of concurrent transaction modifying same data 
2017-08-28 10:20:03,198 | ERROR | nPool-1-worker-1 | InterfaceStateEventListener      | 355 - org.opendaylight.netvirt.natservice-impl - 0.3.4.Boron-SR4 | NAT Service : Unable to read router port entry for router ID 012921d8-2012-4bb8-8db4-406fcb600bc6 and port name b89207cf-9aac-47c9-96a0-e93199ee25de
2017-08-28 10:20:03,320 | ERROR | nPool-1-worker-1 | InterfaceManagerRpcService       | 337 - org.opendaylight.genius.interfacemanager-impl - 0.1.4.Boron-SR4 | Retrieval of egress actions for the key tun5c61b9d5f4c failed due to Interface information not present in oper DS for tun5c61b9d5f4c
2017-08-28 10:20:03,324 | ERROR | nPool-1-worker-1 | VrfEntryListener                 | 348 - org.opendaylight.netvirt.fibmanager-impl - 0.3.4.Boron-SR4 | Failed to retrieve egress action for prefix 10.10.10.2/32 nextHop [10.0.1.21] interface tun5c61b9d5f4c. Aborting remote FIB entry creation.
2017-08-28 10:20:03,834 | ERROR | nPool-1-worker-0 | InterfaceManagerRpcService       | 337 - org.opendaylight.genius.interfacemanager-impl - 0.1.4.Boron-SR4 | Retrieval of egress actions for the key tuncf8691bf023 failed due to Interface information not present in oper DS for tuncf8691bf023
2017-08-28 10:20:16,220 | ERROR | Thread-144       | NaptManager                      | 355 - org.opendaylight.netvirt.natservice-impl - 0.3.4.Boron-SR4 | NAPT Service : no-entry in checkIpPortMap, returning NULL [should be OK] for segmentId 70001 and internalIPPort 10.10.10.3:39917
2017-08-28 10:22:53,325 | WARN  | nPool-1-worker-1 | NexthopManager                   | 348 - org.opendaylight.netvirt.fibmanager-impl - 0.3.4.Boron-SR4 | No VPN interface found for VPN id 70000 prefix 10.0.3.237/32
2017-08-28 10:22:53,325 | WARN  | nPool-1-worker-1 | NexthopManager                   | 348 - org.opendaylight.netvirt.fibmanager-impl - 0.3.4.Boron-SR4 | Failed to determine network type for prefixIp 10.0.3.237/32 using tunnel
2017-08-28 10:22:53,328 | WARN  | pool-39-thread-1 | VpnManagerImpl                   | 346 - org.opendaylight.netvirt.vpnmanager-impl - 0.3.4.Boron-SR4 | Failed to install responder flows for 012921d8-2012-4bb8-8db4-406fcb600bc6. No external interface found for DPN id 105738484573865
2017-08-28 10:22:53,331 | WARN  | pool-39-thread-1 | VpnFloatingIpHandler             | 355 - org.opendaylight.netvirt.natservice-impl - 0.3.4.Boron-SR4 | Failed to send GARP for IP. Failed to retrieve interface name from network 91556e02-7ff2-4a07-bf51-0ade16366d83 and dpn id 105738484573865.
2017-08-28 10:22:53,341 | WARN  | nPool-1-worker-1 | NexthopManager                   | 348 - org.opendaylight.netvirt.fibmanager-impl - 0.3.4.Boron-SR4 | No VPN interface found for VPN id 70000 prefix 10.0.3.240/32
2017-08-28 10:22:53,341 | WARN  | nPool-1-worker-1 | NexthopManager                   | 348 - org.opendaylight.netvirt.fibmanager-impl - 0.3.4.Boron-SR4 | Failed to determine network type for prefixIp 10.0.3.240/32 using tunnel
LOG
