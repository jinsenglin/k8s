function create_event_exporter() {
    kubectl -n add-on apply -f .
}

function delete_event_exporter() {
    kubectl -n add-on delete -f .
}
