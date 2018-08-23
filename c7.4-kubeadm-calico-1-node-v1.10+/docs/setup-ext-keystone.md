```
yum install -y docker
systemctl enable docker && systemctl start docker

docker pull docker.io/stephenhsu/keystone:9.1.0
docker run -d --restart always --name ks -p 5000:5000 -p 35357:35357 -e TLS_ENABLED=true -h 192.168.240.63 docker.io/stephenhsu/keystone:9.1.0  # https
# docker run -d --restart always --name ks -p 5000:5000 -p 35357:35357 -h 192.168.240.63 docker.io/stephenhsu/keystone:9.1.0                    # http

# verify
# curl -k https://127.0.0.1:5000/
# curl -k https://127.0.0.1:5000/v3
# curl -k https://127.0.0.1:35357/
# curl -k https://127.0.0.1:35357/v3

# copy openrc file
# docker cp ks:/root/openrc .

# copy ca cert file
# docker cp ks:/etc/apache2/ssl/apache.crt .
```

Sample openrc file

```
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=passw0rd
export OS_AUTH_URL=https://192.168.240.63:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
export OS_CACERT=/etc/apache2/ssl/apache.crt
```

OpenStack Keystone Command Line Usage

```
openstack token issue

openstack project list          # admin
openstack user list             # admin
openstack role list             # admin
openstack group list            # empty
openstack role assignment list  # u:admin r:admin p:admin
```

Sample Case

- 2 projects: team1, team2
- 2 roles: k8s-admin, k8s-viewer
- 3 users: alice, bob, carol
- role assignments
  - u:alice r:k8s-admin p:team1
  - u:bob r:k8s-admin p:team2
  - u:carol r:k8s-viewer p:team2

```
openstack project create team1
openstack project create team2

openstack role create k8s-admin
openstack role create k8s-viewer

openstack user create --password passw0rd alice
openstack user create --password passw0rd bob
openstack user create --password passw0rd carol

openstack role add --user alice --project team1 k8s-admin
openstack role add --user bob --project team2 k8s-admin
openstack role add --user carol --project team2 k8s-viewer
```

openrc-alice

```
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=team1
export OS_USERNAME=alice
export OS_PASSWORD=passw0rd
export OS_AUTH_URL=https://192.168.240.63:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
export OS_CACERT=/etc/apache2/ssl/apache.crt
```

openrc-bob

```
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=team2
export OS_USERNAME=bob
export OS_PASSWORD=passw0rd
export OS_AUTH_URL=https://192.168.240.63:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
export OS_CACERT=/etc/apache2/ssl/apache.crt
```

openrc-carol

```
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=team2
export OS_USERNAME=carol
export OS_PASSWORD=passw0rd
export OS_AUTH_URL=https://192.168.240.63:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
export OS_CACERT=/etc/apache2/ssl/apache.crt
```
