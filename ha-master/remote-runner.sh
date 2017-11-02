#!/bin/bash

# Usage 1: bash remote-runner.sh $FIP1 ls /
# Usage 2: bash remote-runner.sh $FIP1 "cd k8s/ha-master; ls"

IP=$1
shift

ssh -i ~/.ssh/id_rsa_devops root@$IP -o StrictHostKeyChecking=false $@
