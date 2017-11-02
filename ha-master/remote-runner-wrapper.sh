#!/bin/bash

# Usage 1: bash remote-runner-wrapper.sh git_clone
# Usage 2: bash remote-runner-wrapper.sh git_pull
# Usage 3: bash remote-runner-wrapper.sh copy_pkgs
# Usage 4: bash remote-runner-wrapper.sh configure

CMD=$1
shift

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
