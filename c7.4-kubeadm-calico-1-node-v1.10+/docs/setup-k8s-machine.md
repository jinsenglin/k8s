```
openstack port create --network k8s --fixed-ip subnet=k8s,ip-address=10.112.0.10 10.112.0.10

port_id=$(openstack port show 10.112.0.10 -c id -f value)
# de17a78b-a39f-4220-8e0b-42ae55d2c0cc

openstack floating ip create --floating-ip-address 192.168.240.23 --port $port_id Catherine-924

openstack server create --image vm-c7 --flavor 4C8G50G --key-name devops --nic port-id=$port_id k8s

openstack server add security group k8s open-all
```
