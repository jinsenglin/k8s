package main

import (
    "fmt"
    "log"
    "net/http"

    "github.com/prometheus/client_golang/prometheus/promhttp"

    "github.com/cclin81922/k8s-pod-monitor/internal/controller"
)

func main() {
    // creates the config
    config := GetKubernetesConfig()

    // creates the client
    client := GetKubernetesClient(config)

    //
    go controller.Ctrl(client)

    http.HandleFunc("/in-cluster-service-account", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "client :: %+v \n config :: %+v", client, config)
    })

    http.Handle("/metrics", promhttp.Handler())
    log.Fatal(http.ListenAndServe(":8080", nil))
}
