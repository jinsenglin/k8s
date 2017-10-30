#!/bin/bash

# PART I
# ----------------------------------------------------------------------------- #

# # 1. 建立 kuryr user
# create user 'kuryr'
KURYR_USER_ID=$(openstack user create kuryr --password password --domain=Default --or-show -c id -f value)

# create role 'service'
SERVICE_ROLE_ID=$(openstack role create service --or-show -c id -f value)

# link user, role, and project
openstack role add service --user kuryr --project service --user-domain Default --project-domain Default
openstack role add admin --user kuryr --project service --user-domain Default --project-domain Default

# # 2. 建立 'kuryr-kubernetes' service
# create service 'kuryr-kubernetes'
KURYR_SVC_ID=$(openstack service create kuryr-kubernetes --name kuryr-kubernetes --description="Kuryr-Kubernetes Service" -f value -c id)

# # 3. 建立 'shared-default-subnetpool' subnet pool
# create subnet pool 'shared-default-subnetpool'
SUBNETPOOL_V4_ID=$(openstack subnet pool create shared-default-subnetpool --default-prefix-length 26 --pool-prefix "10.1.0.0/22" --share --default -f value -c id)

# # 4. 建立 'demo' network
# set network 'demo'
DEMO_PROJECT_ID=$(openstack project show -c id -f value demo)
DEMO_NET_ID=$(openstack network create --project demo -c id -f value demo)

# # 5. 建立 'demo' subnet
# create subnet 'demo'
DEMO_SUBNET_ID=$(openstack subnet create --project demo --ip-version 4 --subnet-pool $SUBNETPOOL_V4_ID --network $DEMO_NET_ID -c id -f value demo)

# # 6. 建立 'k8s-service-subnet' subnet
# create subnet 'k8s-service-subnet'
SERVICE_SUBNET_ID=$(openstack subnet create --project demo --ip-version 4 --no-dhcp --gateway none --subnet-pool $SUBNETPOOL_V4_ID --network $DEMO_NET_ID -c id -f value k8s-service-subnet)
SERVICE_CIDR=$(openstack subnet show -c cidr -f value $SERVICE_SUBNET_ID)
KURYR_K8S_CLUSTER_IP_RANGE=$SERVICE_CIDR
GATEWAY_IP=$(openstack subnet show -c allocation_pools -f value $SERVICE_SUBNET_ID | awk -F '-' '{print $2}')

# set gateway
openstack subnet set --gateway $GATEWAY_IP --no-allocation-pool $SERVICE_SUBNET_ID

# # 7. 建立 'demo' router
# create router 'demo'
DEMO_ROUTER_ID=$(openstack router create --project demo -c id -f value demo)

# # 8. 將 'demo' subnet 加入 'demo' router
# link subnet and router
openstack router add subnet $DEMO_ROUTER_ID $DEMO_SUBNET_ID

# # 9. 將 'k8s-service-subnet' subnet 加入 'demo' router
# link subnet and router
openstack router add subnet $DEMO_ROUTER_ID $SERVICE_SUBNET_ID

# # 10. 取得 'demo' project 的 'default' security group
# get security group 'default'
DEMO_SECGROUP_ID=$(openstack security group list --project demo -c ID -f value)

# PART II
# ----------------------------------------------------------------------------- #

# # 1. 下載 kuryr-kubernetes project
git clone https://github.com/openstack/kuryr-kubernetes.git /opt/kuryr-kubernetes
cd /opt/kuryr-kubernetes
git checkout -b 0.1.0

# # 2. 安裝 pip, virtualenv and kuryr-kubernetes==0.1.0
pip install virtualenv
virtualenv env
source /opt/kuryr-kubernetes/env/bin/activate
pip install -r requirements.txt -c https://raw.githubusercontent.com/openstack/requirements/stable/ocata/upper-constraints.txt
python setup.py install
cp /opt/kuryr-kubernetes/env/bin/kuryr-cni /usr/local/bin/kuryr-cni
cp /opt/kuryr-kubernetes/env/bin/kuryr-k8s-controller /usr/local/bin/kuryr-k8s-controller

# # 3. 設定 Kuryr 環境與相關配置
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
api_root = http://10.0.0.11:8080

[neutron]
auth_uri = http://10.0.0.11:5000
auth_url = http://10.0.0.11:35357
memcached_servers = 10.0.0.11:11211
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

# # 4. 安裝 docker-engine 1.12
apt-get install --no-install-recommends apt-transport-https curl software-properties-common
curl -fsSL 'https://sks-keyservers.net/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e' | apt-key add -
add-apt-repository "deb https://packages.docker.com/1.12/apt/repo/ ubuntu-$(lsb_release -cs) main"
apt-get update
apt-cache madison docker-engine
apt-get -y install docker-engine=1.12.6~cs13-0~ubuntu-xenial

# # 5. 下載 quay.io/coreos/etcd 3.0.8 鏡像與運行 etcd 容器
docker pull quay.io/coreos/etcd:v3.0.8
docker run --name etcd --detach \
           --net host \
           --volume="/opt/data/etcd:/var/etcd:rw" \
           quay.io/coreos/etcd:v3.0.8 /usr/local/bin/etcd \
           --name devstack \
           --data-dir /var/etcd/data \
           --initial-advertise-peer-urls http://10.0.0.11:2380 \
           --listen-peer-urls http://0.0.0.0:2380 \
           --listen-client-urls http://0.0.0.0:2379 \
           --advertise-client-urls http://10.0.0.11:2379 \
           --initial-cluster-token etcd-cluster-1 \
           --initial-cluster devstack=http://10.0.0.11:2380 \
           --initial-cluster-state new

# # 6. 建立 hyperkube 1.4.6 環境
mkdir -p /opt/data/hyperkube
docker pull gcr.io/google_containers/hyperkube-amd64:v1.4.6
docker run --name devstack-k8s-setup-files --detach \
           --volume "/opt/data/hyperkube:/srv/kubernetes:rw" \
           gcr.io/google_containers/hyperkube-amd64:v1.4.6 \
           /setup-files.sh \
           "IP:10.0.0.11,DNS:kubernetes,DNS:kubernetes.default,DNS:kubernetes.default.svc,DNS:kubernetes.default.svc.cluster.local"

# # 7. 運行 Hyperkube’s Kubernetes API Server
KURYR_ETCD_ADVERTISE_CLIENT_URL=http://10.0.0.11:2379
docker run --name kubernetes-api --detach \
           --net host \
           --volume="/opt/data/hyperkube:/srv/kubernetes:rw" \
           gcr.io/google_containers/hyperkube-amd64:v1.4.6 \
           /hyperkube apiserver \
           --service-cluster-ip-range=$KURYR_K8S_CLUSTER_IP_RANGE \
           --insecure-bind-address=0.0.0.0 \
           --insecure-port=8080 \
           --etcd-servers=http://10.0.0.11:2379 \
           --admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,ResourceQuota \
           --client-ca-file=/srv/kubernetes/ca.crt \
           --basic-auth-file=/srv/kubernetes/basic_auth.csv \
           --min-request-timeout=300 \
           --tls-cert-file=/srv/kubernetes/server.cert \
           --tls-private-key-file=/srv/kubernetes/server.key \
           --token-auth-file=/srv/kubernetes/known_tokens.csv \
           --allow-privileged=true \
           --v=2 --logtostderr=true

# # 8. 運行 Hyperkube’s Kubernetes controller manager
docker run --name kubernetes-controller-manager --detach \
           --net host \
           --volume="/opt/data/hyperkube:/srv/kubernetes:rw" \
           gcr.io/google_containers/hyperkube-amd64:v1.4.6 \
           /hyperkube controller-manager \
           --service-account-private-key-file=/srv/kubernetes/server.key \
           --root-ca-file=/srv/kubernetes/ca.crt \
           --min-resync-period=3m \
           --master="http://10.0.0.11:8080" \
           --v=2 --logtostderr=true

# # 9. 運行 Hyperkube’s Kubernetes scheduler
docker run --name kubernetes-scheduler --detach \
           --net host \
           --volume="/opt/data/hyperkube:/srv/kubernetes:rw" \
           gcr.io/google_containers/hyperkube-amd64:v1.4.6 \
           /hyperkube scheduler \
           --master=http://10.0.0.11:8080 \
           --v=2 --logtostderr=true

# # 10. 設定 kuryr-cni 與 hyperkube 環境
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
/opt/kuryr-kubernetes/devstack/kubectl version # exit code != 0 due to no kubeconfig file found
cp /opt/kuryr-kubernetes/devstack/kubectl $(dirname /usr/local/bin/hyperkube)/kubectl

# # 11. 運行 kubelet + kuryr-cni
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
Environment="KUBELET_API_SERVER=--api-servers=http://10.0.0.11:8080"
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

# # 12. 運行 kuryr-kubernetes controller
source /opt/kuryr-kubernetes/env/bin/activate
nohup /opt/kuryr-kubernetes/env/bin/python /opt/kuryr-kubernetes/scripts/run_server.py --config-file /etc/kuryr/kuryr.conf &
