#!/bin/bash

set -e

function update_etc_sysctl_conf() {
# update '/etc/sysctl.conf' file

# Enable iptables Filtering on Bridge Devices
cat >>  /etc/sysctl.conf <<DATA
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-arptables = 1
DATA

# Apply settings immediately and verify that the value is 1.
sysctl -p
sysctl net.bridge.bridge-nf-call-iptables
sysctl net.bridge.bridge-nf-call-ip6tables
sysctl net.bridge.bridge-nf-call-arptables
}

function bring_up_etcd_cluster() {
    source rc

    case $HOSTNAME in
        $M1)
            echo "M1"

            flag=$(docker ps --filter "name=etcd" | wc -l)
            if [ $flag -gt 1 ]; then
                docker stop etcd
                docker rm etcd
            fi

            [ -d /var/lib/etcd-cluster ] && rm -rf /var/lib/etcd-cluster
            mkdir -p /var/lib/etcd-cluster

            docker run -d \
            --restart always \
            -v /etc/ssl/certs:/etc/ssl/certs \
            -v /var/lib/etcd-cluster:/var/lib/etcd \
            -p 4001:4001 \
            -p 2380:2380 \
            -p 2379:2379 \
            --name etcd \
            gcr.io/google_containers/etcd-amd64:3.0.17 \
            etcd --name=etcd0 \
            --advertise-client-urls=http://$PIP1:2379,http://$PIP1:4001 \
            --listen-client-urls=http://0.0.0.0:2379,http://0.0.0.0:4001 \
            --initial-advertise-peer-urls=http://$PIP1:2380 \
            --listen-peer-urls=http://0.0.0.0:2380 \
            --initial-cluster-token=9477af68bbee1b9ae037d6fd9e7efefd \
            --initial-cluster=etcd0=http://$PIP1:2380,etcd1=http://$PIP2:2380,etcd2=http://$PIP3:2380 \
            --initial-cluster-state=new \
            --auto-tls \
            --peer-auto-tls \
            --data-dir=/var/lib/etcd
            ;;
        $M2)
            echo "M2"

            flag=$(docker ps --filter "name=etcd" | wc -l)
            if [ $flag -gt 1 ]; then
                docker stop etcd
                docker rm etcd
            fi

            [ -d /var/lib/etcd-cluster ] && rm -rf /var/lib/etcd-cluster
            mkdir -p /var/lib/etcd-cluster

            docker run -d \
            --restart always \
            -v /etc/ssl/certs:/etc/ssl/certs \
            -v /var/lib/etcd-cluster:/var/lib/etcd \
            -p 4001:4001 \
            -p 2380:2380 \
            -p 2379:2379 \
            --name etcd \
            gcr.io/google_containers/etcd-amd64:3.0.17 \
            etcd --name=etcd1 \
            --advertise-client-urls=http://$PIP2:2379,http://$PIP2:4001 \
            --listen-client-urls=http://0.0.0.0:2379,http://0.0.0.0:4001 \
            --initial-advertise-peer-urls=http://$PIP2:2380 \
            --listen-peer-urls=http://0.0.0.0:2380 \
            --initial-cluster-token=9477af68bbee1b9ae037d6fd9e7efefd \
            --initial-cluster=etcd0=http://$PIP1:2380,etcd1=http://$PIP2:2380,etcd2=http://$PIP3:2380 \
            --initial-cluster-state=new \
            --auto-tls \
            --peer-auto-tls \
            --data-dir=/var/lib/etcd
            ;;
        $M3)
            echo "M3"

            flag=$(docker ps --filter "name=etcd" | wc -l)
            if [ $flag -gt 1 ]; then
                docker stop etcd
                docker rm etcd
            fi

            [ -d /var/lib/etcd-cluster ] && rm -rf /var/lib/etcd-cluster
            mkdir -p /var/lib/etcd-cluster

            docker run -d \
            --restart always \
            -v /etc/ssl/certs:/etc/ssl/certs \
            -v /var/lib/etcd-cluster:/var/lib/etcd \
            -p 4001:4001 \
            -p 2380:2380 \
            -p 2379:2379 \
            --name etcd \
            gcr.io/google_containers/etcd-amd64:3.0.17 \
            etcd --name=etcd2 \
            --advertise-client-urls=http://$PIP3:2379,http://$PIP3:4001 \
            --listen-client-urls=http://0.0.0.0:2379,http://0.0.0.0:4001 \
            --initial-advertise-peer-urls=http://$PIP3:2380 \
            --listen-peer-urls=http://0.0.0.0:2380 \
            --initial-cluster-token=9477af68bbee1b9ae037d6fd9e7efefd \
            --initial-cluster=etcd0=http://$PIP1:2380,etcd1=http://$PIP2:2380,etcd2=http://$PIP3:2380 \
            --initial-cluster-state=new \
            --auto-tls \
            --peer-auto-tls \
            --data-dir=/var/lib/etcd
            ;;
        $M4)
            echo "M4 has nothing to do in step 'bring_up_etcd_cluster'"
            ;;
        $M5)
            echo "M5 has nothing to do in step 'bring_up_etcd_cluster'"
            ;;
        *)
            echo "unknown hostname"
            ;;
    esac
}

function check_etcd_cluster() {
    source rc

    case $HOSTNAME in
        $M1)
            echo "M1"
            docker exec etcd etcdctl member list
            docker exec etcd etcdctl cluster-health
            ;;
        $M2)
            echo "M2"
            docker exec etcd etcdctl member list
            docker exec etcd etcdctl cluster-health
            ;;
        $M3)
            echo "M3"
            docker exec etcd etcdctl member list
            docker exec etcd etcdctl cluster-health
            ;;
        $M4)
            echo "M4 has nothing to do in step 'check_etcd_cluster'"
            ;;
        $M5)
            echo "M5 has nothing to do in step 'check_etcd_cluster'"
            ;;
        *)
            echo "unknown hostname"
            ;;
    esac
}

function run_kubeadm_init() {
    source rc

    case $HOSTNAME in
        $M1)
            echo "M1"

            if [ -d /var/lib/kubelet ]; then
                kubectl --kubeconfig=/etc/kubernetes/admin.conf drain $M1 --delete-local-data --force --ignore-daemonsets
                kubectl --kubeconfig=/etc/kubernetes/admin.conf delete ds kube-proxy -n kube-system
                kubectl --kubeconfig=/etc/kubernetes/admin.conf delete ds kube-flannel-ds -n kube-system
                kubectl --kubeconfig=/etc/kubernetes/admin.conf delete node $M1
                kubeadm reset
                rm -rf /var/lib/kubelet
            fi

            kubeadm init --config=kubeadm-ha/kubeadm-init-v1.8.x.yaml | tee kubeadm-init.log
            ;;
        $M2)
            echo "M2 has nothing to do in step 'run_kubeadm_init'"
            ;;
        $M3)
            echo "M3 has nothing to do in step 'run_kubeadm_init'"
            ;;
        $M4)
            echo "M4 has nothing to do in step 'run_kubeadm_init'"
            ;;
        $M5)
            echo "M5 has nothing to do in step 'run_kubeadm_init'"
            ;;
        *)
            echo "unknown hostname"
            ;;
    esac
}

function check_k8s_cluster() {
    source rc

    case $HOSTNAME in
        $M1)
            echo "M1"

            kubeadm token list
            kubectl --kubeconfig=/etc/kubernetes/admin.conf get node
            kubectl --kubeconfig=/etc/kubernetes/admin.conf get po -n kube-system -o wide

            ;;
        $M2)
            echo "M2 has nothing to do in step 'check_k8s_cluster'"
            ;;
        $M3)
            echo "M3 has nothing to do in step 'check_k8s_cluster'"
            ;;
        $M4)
            echo "M4 has nothing to do in step 'check_k8s_cluster'"
            ;;
        $M5)
            echo "M5 has nothing to do in step 'check_k8s_cluster'"
            ;;
        *)
            echo "unknown hostname"
            ;;
    esac
}

function install_flannel() {
    source rc

    case $HOSTNAME in
        $M1)
            echo "M1"

            kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f kubeadm-ha/kube-flannel/kube-flannel.yml
            kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f kubeadm-ha/kube-flannel/kube-flannel-rbac.yml

            echo "wait 1 minutes for pods up and running"
            i=60; while [ $i -gt 0 ]; do echo "wait for $i seconds"; i=$(( $i - 1 )); sleep 1; done

            kubectl --kubeconfig=/etc/kubernetes/admin.conf get node
            kubectl --kubeconfig=/etc/kubernetes/admin.conf get po -n kube-system -o wide

            ;;
        $M2)
            echo "M2 has nothing to do in step 'install_flannel'"
            ;;
        $M3)
            echo "M3 has nothing to do in step 'install_flannel'"
            ;;
        $M4)
            echo "M4 has nothing to do in step 'install_flannel'"
            ;;
        $M5)
            echo "M5 has nothing to do in step 'install_flannel'"
            ;;
        *)
            echo "unknown hostname"
            ;;
    esac
}

function update_kube_apiserver() {
    source rc

    case $HOSTNAME in
        $M1)
            echo "M1"

            # edit kube-apiserver.yaml file's admission-control settings, 
            # v1.7.0 use NodeRestriction admission control will prevent other master join the cluster, 
            # please reset it to v1.6.x recommended config.
            mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp
            admissions=NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,ResourceQuota,DefaultTolerationSeconds
            sed -i "s|^\(    - --admission-control=\).*|\1$admissions|" /tmp/kube-apiserver.yaml
            mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests

            ;;
        $M2)
            echo "M2 has nothing to do in step 'update_kube_apiserver'"
            ;;
        $M3)
            echo "M3 has nothing to do in step 'update_kube_apiserver'"
            ;;
        $M4)
            echo "M4 has nothing to do in step 'update_kube_apiserver'"
            ;;
        $M5)
            echo "M5 has nothing to do in step 'update_kube_apiserver'"
            ;;
        *)
            echo "unknown hostname"
            ;;
    esac
}

function setup_ha_master() {
    source rc

    case $HOSTNAME in
        $M1)
            echo "M1 has nothing to do in step 'setup_ha_master'"
            ;;
        $M2)
            echo "M2"

            # run kubeadm join
            ssh -o StrictHostKeyChecking=false $M1 "grep 'kubeadm join' k8s/ha-master/kubeadm-init.log" | bash

            # copy k8s settings from master-1
            scp -o StrictHostKeyChecking=false -r $M1:/etc/kubernetes/ /etc/

            # update kube-apiserver
            mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp
            sed -i "s|^\(    - --advertise-address=\).*|\1$PIP2|" /tmp/kube-apiserver.yaml
            mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests
           
            # update kube-controller-manager
            mv /etc/kubernetes/manifests/kube-controller-manager.yaml /tmp
            sed -i "s|^\(    server: https:\/\/\).*\(:6443\)$|\1$PIP2\2|" /etc/kubernetes/controller-manager.conf
            mv /tmp/kube-controller-manager.yaml /etc/kubernetes/manifests

            # update kube-scheduler
            mv /etc/kubernetes/manifests/kube-scheduler.yaml /tmp
            sed -i "s|^\(    server: https:\/\/\).*\(:6443\)$|\1$PIP2\2|" /etc/kubernetes/scheduler.conf
            mv /tmp/kube-scheduler.yaml /etc/kubernetes/manifests

            # update kubelet
            sed -i "s|^\(    server: https:\/\/\).*\(:6443\)$|\1$PIP2\2|" /etc/kubernetes/kubelet.conf
            systemctl restart kubelet
            
            # update kubeconfig file
            sed -i "s|^\(    server: https:\/\/\).*\(:6443\)$|\1$PIP2\2|" /etc/kubernetes/admin.conf

            ;;
        $M3)
            echo "M3"

            # run kubeadm join
            ssh -o StrictHostKeyChecking=false $M1 "grep 'kubeadm join' k8s/ha-master/kubeadm-init.log" | bash

            # copy k8s settings from master-1
            scp -o StrictHostKeyChecking=false -r $M1:/etc/kubernetes/ /etc/

            # update kube-apiserver
            mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp
            sed -i "s|^\(    - --advertise-address=\).*|\1$PIP2|" /tmp/kube-apiserver.yaml
            mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests
           
            # update kube-controller-manager
            mv /etc/kubernetes/manifests/kube-controller-manager.yaml /tmp
            sed -i "s|^\(    server: https:\/\/\).*\(:6443\)$|\1$PIP2\2|" /etc/kubernetes/controller-manager.conf
            mv /tmp/kube-controller-manager.yaml /etc/kubernetes/manifests

            # update kube-scheduler
            mv /etc/kubernetes/manifests/kube-scheduler.yaml /tmp
            sed -i "s|^\(    server: https:\/\/\).*\(:6443\)$|\1$PIP2\2|" /etc/kubernetes/scheduler.conf
            mv /tmp/kube-scheduler.yaml /etc/kubernetes/manifests

            # update kubelet
            sed -i "s|^\(    server: https:\/\/\).*\(:6443\)$|\1$PIP2\2|" /etc/kubernetes/kubelet.conf
            systemctl restart kubelet
            
            # update kubeconfig file
            sed -i "s|^\(    server: https:\/\/\).*\(:6443\)$|\1$PIP2\2|" /etc/kubernetes/admin.conf

            ;;
        $M4)
            echo "M4 has nothing to do in step 'setup_ha_master'"
            ;;
        $M5)
            echo "M5 has nothing to do in step 'setup_ha_master'"
            ;;
        *)
            echo "unknown hostname"
            ;;
    esac
}

function check_k8s_cluster_ha() {
    source rc

    case $HOSTNAME in
        $M1)
            echo "M1"

            kubeadm token list
            kubectl --kubeconfig=/etc/kubernetes/admin.conf get node
            kubectl --kubeconfig=/etc/kubernetes/admin.conf get po -n kube-system -o wide
            kubectl --kubeconfig=/etc/kubernetes/admin.conf get cs

            ;;
        $M2)
            echo "M2"

            kubeadm token list
            kubectl --kubeconfig=/etc/kubernetes/admin.conf get node
            kubectl --kubeconfig=/etc/kubernetes/admin.conf get po -n kube-system -o wide
            kubectl --kubeconfig=/etc/kubernetes/admin.conf get cs

            ;;
        $M3)
            echo "M3"

            kubeadm token list
            kubectl --kubeconfig=/etc/kubernetes/admin.conf get node
            kubectl --kubeconfig=/etc/kubernetes/admin.conf get po -n kube-system -o wide
            kubectl --kubeconfig=/etc/kubernetes/admin.conf get cs

            ;;
        $M4)
            echo "M4 has nothing to do in step 'check_k8s_cluster_ha'"
            ;;
        $M5)
            echo "M5 has nothing to do in step 'check_k8s_cluster_ha'"
            ;;
        *)
            echo "unknown hostname"
            ;;
    esac
}

#update_etc_sysctl_conf
bring_up_etcd_cluster

            echo "wait 10 seconds for etcd nodes up and running"
            i=10; while [ $i -gt 0 ]; do echo "wait for $i seconds"; i=$(( $i - 1 )); sleep 1; done

check_etcd_cluster
#run_kubeadm_init
#check_k8s_cluster
#install_flannel
#update_kube_apiserver
#setup_ha_master
#check_k8s_cluster_ha
#setup_keepalived
#setup_nginx_lb
#update_kube_proxy
#run_kubeadm_join
