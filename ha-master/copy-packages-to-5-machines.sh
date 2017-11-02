#!/bin/bsash

source rc

# update '/etc/hosts' file
cat >> /etc/hosts <<DATA
$PIP1  $M1
$PIP2  $M2
$PIP3  $M3
$PIP4  $M4
$PIP5  $M5
DATA

# install k8s package dependency
apt-get update && apt-get install -y ebtables ethtool

# install docker-ce 17.03
apt-get install -y docker.io
apt-get update && apt-get install -y curl apt-transport-https
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/docker.list
deb https://download.docker.com/linux/$(lsb_release -si | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable
EOF
apt-get update && apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')

# install k8s apt repository
apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update

# install kubeadm, kubelete, kubectl of version 1.8.0
apt-get install -y kubeadm=1.8.0-00 kubectl=1.8.0-00 kubelet=1.8.0-00
