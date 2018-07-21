package main

import (
    "log"

    "k8s.io/client-go/rest"
)

func GetKubernetesConfig() *rest.Config {
    // creates the in-cluster config
    config, err := rest.InClusterConfig()
    if err != nil {
        log.Panic(err.Error())
    }
    return config
}
