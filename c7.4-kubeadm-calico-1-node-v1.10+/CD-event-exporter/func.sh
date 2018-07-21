function create_event_exporter() {
    kubectl -n 3rd-party apply -f .
}

function delete_event_exporter() {
    kubectl -n 3rd-party delete -f .
}
