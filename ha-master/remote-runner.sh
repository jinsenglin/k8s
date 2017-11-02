#!/bin/bash

# Usage: bash remote-runner.sh $FIP1 ls /

IP=$1
shift

ssh -i ~/.ssh/id_rsa_devops root@$IP -o StrictHostKeyChecking=false $@
