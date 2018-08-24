RELEASE_NAME=nfs-provisioner-release

function create_nfs_provisioner() {
    helm install stable/nfs-server-provisioner --version 0.1.5 --namespace add-on --name $RELEASE_NAME --set storageClass.defaultClass=true
}

function delete_nfs_provisioner() {
    helm delete --purge $RELEASE_NAME
}
