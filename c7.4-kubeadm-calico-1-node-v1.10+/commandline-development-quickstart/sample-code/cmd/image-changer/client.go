package main

import (
    "log"

    "k8s.io/client-go/kubernetes"
    "k8s.io/client-go/rest"
)

func GetKubernetesClient(config *rest.Config) kubernetes.Interface {
    // creates the clientset
    client, err := kubernetes.NewForConfig(config)
    if err != nil { 
        log.Panic(err.Error())
    } 
    return client
}
