RELEASE_NAME=nfs-provisioner-release

function create_nfs_provisioner() {
    helm install stable/nfs-server-provisioner --namespace add-on --name $RELEASE_NAME --set storageClass.defaultClass=true
}

function delete_nfs_provisioner() {
    helm delete --purge $RELEASE_NAME
}
