#!/bin/bsash

set -e

function update_etc_hosts() {
# update '/etc/hosts' file
source rc
cat >> /etc/hosts <<DATA
$PIP1  $M1
$PIP2  $M2
$PIP3  $M3
$PIP4  $M4
$PIP5  $M5
DATA
}

function download_utilities() {
apt-get update && apt-get install -y tree jq ntpdate
}

function download_k8s_packages() {
# install k8s package dependency
apt-get update && apt-get install -y ebtables ethtool

# install k8s apt repository
apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update

# install kubeadm, kubelete, kubectl of version 1.8.0
apt-get install -y kubeadm=1.8.0-00 kubectl=1.8.0-00 kubelet=1.8.0-00
}

function download_docker_images() {
# install docker-ce 17.03
apt-get install -y docker.io
apt-get update && apt-get install -y curl apt-transport-https
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/docker.list
deb https://download.docker.com/linux/$(lsb_release -si | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable
EOF
apt-get update && apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')

    # required
    docker pull gcr.io/google_containers/kube-proxy-amd64:v1.8.2
    docker pull gcr.io/google_containers/kube-apiserver-amd64:v1.8.2
    docker pull gcr.io/google_containers/kube-controller-manager-amd64:v1.8.2
    docker pull gcr.io/google_containers/kube-scheduler-amd64:v1.8.2
    docker pull gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.5
    docker pull gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.5
    docker pull gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.5
    docker pull nginx:latest
    docker pull quay.io/coreos/flannel:v0.8.0-amd64
    docker pull gcr.io/google_containers/etcd-amd64:3.0.17
    docker pull gcr.io/google_containers/pause-amd64:3.0
    # option
    docker pull gcr.io/google_containers/kubernetes-dashboard-init-amd64:v1.0.1
    docker pull gcr.io/google_containers/kubernetes-dashboard-amd64:v1.7.1
    docker pull gcr.io/google_containers/heapster-amd64:v1.4.3
    docker pull gcr.io/google_containers/heapster-grafana-amd64:v4.4.3
    docker pull gcr.io/google_containers/heapster-influxdb-amd64:v1.3.3
}

function donwload_keepalived() {
    apt-get update && apt install -y keepalived
}

update_etc_hosts
download_utilities
download_k8s_packages
download_docker_images
donwload_keepalived
