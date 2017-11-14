#!/bin/bash

# Usage 1: bash remote-runner-wrapper.sh git_clone
# Usage 2: bash remote-runner-wrapper.sh git_pull
# Usage 3: bash remote-runner-wrapper.sh copy_pkgs
# Usage 4: bash remote-runner-wrapper.sh configure
# Usage 5: bash remote-runner-wrapper.sh del_k8s
# Usage 6: bash remote-runner-wrapper.sh del_k8s_workers
# Usage 7: bash remote-runner-wrapper.sh del_etcd
# Usage 8: bash remote-runner-wrapper.sh del_lb
# Usage 9: bash remote-runner-wrapper.sh restart_docker_and_kubelet
# Usage 10: bash remote-runner-wrapper.sh power_off
# Usage 11: bash remote-runner-wrapper.sh power_on
# Usage 12: bash remote-runner-wrapper.sh patch

set -e

CMD=$1
shift

function patch() {
    source rc
    img0="gcr.io/google_containers/kubernetes-dashboard-init-amd64:v1.0.1"
    img1="gcr.io/google_containers/kubernetes-dashboard-amd64:v1.7.1"
    img2="gcr.io/google_containers/heapster-amd64:v1.4.3"
    img3="gcr.io/google_containers/heapster-grafana-amd64:v4.4.3"
    img4="gcr.io/google_containers/heapster-influxdb-amd64:v1.3.3"

    ssh -i ~/.ssh/id_rsa_devops root@$FIP1 -o StrictHostKeyChecking=false "docker pull $img1; docker pull $img2; docker pull $img3; docker pull $img4"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP2 -o StrictHostKeyChecking=false "docker pull $img1; docker pull $img2; docker pull $img3; docker pull $img4"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP3 -o StrictHostKeyChecking=false "docker pull $img1; docker pull $img2; docker pull $img3; docker pull $img4"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP4 -o StrictHostKeyChecking=false "docker pull $img1; docker pull $img2; docker pull $img3; docker pull $img4"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP5 -o StrictHostKeyChecking=false "docker pull $img1; docker pull $img2; docker pull $img3; docker pull $img4"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP6 -o StrictHostKeyChecking=false "docker pull $img1; docker pull $img2; docker pull $img3; docker pull $img4"
}

function power_off() {
    source rc
    openstack server stop $M1
    openstack server stop $M2
    openstack server stop $M3
    openstack server stop $M4
    openstack server stop $M5
}

function power_on() {
    source rc
    openstack server start $M1
    openstack server start $M2
    openstack server start $M3
    openstack server start $M4
    openstack server start $M5
}

function restart_docker_and_kubelet() {
    source rc
    ssh -i ~/.ssh/id_rsa_devops root@$FIP1 -o StrictHostKeyChecking=false "hostname; systemctl restart docker kubelet"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP2 -o StrictHostKeyChecking=false "hostname; systemctl restart docker kubelet"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP3 -o StrictHostKeyChecking=false "hostname; systemctl restart docker kubelet"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP4 -o StrictHostKeyChecking=false "hostname; systemctl restart docker kubelet"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP5 -o StrictHostKeyChecking=false "hostname; systemctl restart docker kubelet"
}

function del_k8s_workers() {
    source rc

    set +e
    ssh -i ~/.ssh/id_rsa_devops root@$FIP5 -o StrictHostKeyChecking=false "kubeadm reset; [ -d /var/lib/kubelet ] && rm -rf /var/lib/kubelet; [ -f /etc/kubernetes/bootstrap-kubelet.conf ] && rm /etc/kubernetes/bootstrap-kubelet.conf"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP4 -o StrictHostKeyChecking=false "kubeadm reset; [ -d /var/lig/kubelet ] && rm -rf /var/lib/kubelet; [ -f /etc/kubernetes/bootstrap-kubelet.conf ] && rm /etc/kubernetes/bootstrap-kubelet.conf"
    set -e
}

function del_k8s() {
    source rc
    ssh -i ~/.ssh/id_rsa_devops root@$FIP5 -o StrictHostKeyChecking=false "kubeadm reset; rm -rf /var/lib/kubelet; rm /etc/kubernetes/bootstrap-kubelet.conf"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP4 -o StrictHostKeyChecking=false "kubeadm reset; rm -rf /var/lib/kubelet; rm /etc/kubernetes/bootstrap-kubelet.conf"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP3 -o StrictHostKeyChecking=false "kubectl --kubeconfig=/etc/kubernetes/admin.conf drain $M3 --delete-local-data --force --ignore-daemonsets; kubectl --kubeconfig=/etc/kubernetes/admin.conf delete node $M3; kubeadm reset; rm -rf /var/lib/kubelet"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP2 -o StrictHostKeyChecking=false "kubectl --kubeconfig=/etc/kubernetes/admin.conf drain $M2 --delete-local-data --force --ignore-daemonsets; kubectl --kubeconfig=/etc/kubernetes/admin.conf delete node $M2; kubeadm reset; rm -rf /var/lib/kubelet"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP1 -o StrictHostKeyChecking=false "kubectl --kubeconfig=/etc/kubernetes/admin.conf drain $M1 --delete-local-data --force --ignore-daemonsets; kubectl --kubeconfig=/etc/kubernetes/admin.conf delete node $M1; kubeadm reset; rm -rf /var/lib/kubelet"
}

function del_etcd() {
    source rc
    ssh -i ~/.ssh/id_rsa_devops root@$FIP1 -o StrictHostKeyChecking=false "docker stop etcd && docker rm etcd"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP2 -o StrictHostKeyChecking=false "docker stop etcd && docker rm etcd"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP3 -o StrictHostKeyChecking=false "docker stop etcd && docker rm etcd"
}

function del_lb() {
    source rc
    ssh -i ~/.ssh/id_rsa_devops root@$FIP1 -o StrictHostKeyChecking=false "docker stop nginx-lb && docker rm nginx-lb"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP2 -o StrictHostKeyChecking=false "docker stop nginx-lb && docker rm nginx-lb"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP3 -o StrictHostKeyChecking=false "docker stop nginx-lb && docker rm nginx-lb"
}

# do once only
function git_clone() {
    source rc
    ssh -i ~/.ssh/id_rsa_devops root@$FIP1 -o StrictHostKeyChecking=false "git clone https://github.com/jinsenglin/k8s.git"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP2 -o StrictHostKeyChecking=false "git clone https://github.com/jinsenglin/k8s.git"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP3 -o StrictHostKeyChecking=false "git clone https://github.com/jinsenglin/k8s.git"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP4 -o StrictHostKeyChecking=false "git clone https://github.com/jinsenglin/k8s.git"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP5 -o StrictHostKeyChecking=false "git clone https://github.com/jinsenglin/k8s.git"
}

function git_pull() {
    source rc
    ssh -i ~/.ssh/id_rsa_devops root@$FIP1 -o StrictHostKeyChecking=false "cd k8s; git pull"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP2 -o StrictHostKeyChecking=false "cd k8s; git pull"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP3 -o StrictHostKeyChecking=false "cd k8s; git pull"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP4 -o StrictHostKeyChecking=false "cd k8s; git pull"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP5 -o StrictHostKeyChecking=false "cd k8s; git pull"
}

# do once only
function copy_pkgs() {
    source rc
    ssh -i ~/.ssh/id_rsa_devops root@$FIP1 -o StrictHostKeyChecking=false "cd k8s/ha-master; bash copy-packages-to-machine.sh"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP2 -o StrictHostKeyChecking=false "cd k8s/ha-master; bash copy-packages-to-machine.sh"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP3 -o StrictHostKeyChecking=false "cd k8s/ha-master; bash copy-packages-to-machine.sh"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP4 -o StrictHostKeyChecking=false "cd k8s/ha-master; bash copy-packages-to-machine.sh"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP5 -o StrictHostKeyChecking=false "cd k8s/ha-master; bash copy-packages-to-machine.sh"
}

function configure() {
    source rc
    ssh -i ~/.ssh/id_rsa_devops root@$FIP1 -o StrictHostKeyChecking=false "cd k8s/ha-master; bash configure-machine.sh"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP2 -o StrictHostKeyChecking=false "cd k8s/ha-master; bash configure-machine.sh"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP3 -o StrictHostKeyChecking=false "cd k8s/ha-master; bash configure-machine.sh"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP4 -o StrictHostKeyChecking=false "cd k8s/ha-master; bash configure-machine.sh"
    ssh -i ~/.ssh/id_rsa_devops root@$FIP5 -o StrictHostKeyChecking=false "cd k8s/ha-master; bash configure-machine.sh"
}

$CMD
