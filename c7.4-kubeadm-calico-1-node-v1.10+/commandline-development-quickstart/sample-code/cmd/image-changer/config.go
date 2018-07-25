package main

import (
    "log"

    "k8s.io/client-go/rest"
    "k8s.io/client-go/tools/clientcmd"
)

func GetKubernetesConfig(kubeconfig string) *rest.Config {
    // creates the config from the given kubeconfig file
    config, err := clientcmd.BuildConfigFromFlags("", kubeconfig)
    if err != nil {
        log.Panic(err.Error())
    }
    return config
}
