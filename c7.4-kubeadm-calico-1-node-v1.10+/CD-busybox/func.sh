function create_busybox() {
    kubectl -n default run --image=busybox -i --tty my-box --rm=true --restart Never -- sh
}

function delete_busybox() {
    :
}
