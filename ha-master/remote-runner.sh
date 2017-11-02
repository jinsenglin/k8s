#!/bin/bash

# Usage 1: bash remote-runner.sh $FIP1 ls /
# Usage 2: bash remote-runner.sh $FIP1 "cd k8s; git pull"
# Usage 3: bash remote-runner.sh $FIP1 "cd k8s/ha-master; bash copy-packages-to-machine.sh"
# Usage 4: bash remote-runner.sh $FIP1 "cd k8s/ha-master; bash configure-machine.sh"
# Usage 5: bash remote-runner.sh $FIP1 "cd k8s/ha-master; bash destroy-k8s-cluster.sh"

IP=$1
shift

ssh -i ~/.ssh/id_rsa_devops root@$IP -o StrictHostKeyChecking=false $@
