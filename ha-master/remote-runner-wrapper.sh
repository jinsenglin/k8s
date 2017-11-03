#!/bin/bash

# Usage 1: bash remote-runner-wrapper.sh git_clone
# Usage 2: bash remote-runner-wrapper.sh git_pull
# Usage 3: bash remote-runner-wrapper.sh copy_pkgs
# Usage 4: bash remote-runner-wrapper.sh configure
# Usage 5: bash remote-runner-wrapper.sh del_k8s
# Usage 6: bash remote-runner-wrapper.sh del_etcd

set -e

CMD=$1
shift

function del_k8s() {
    source rc
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
