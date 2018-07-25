package main

import (
    "log"

    "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func main() {
    // parses the flag
    //kubeconfig, namespaceName, deploymentName, containerName, imageName := ParseFlag()
    kubeconfig, namespaceName, deploymentName, _, _ := ParseFlag()

    // creates the config
    config := GetKubernetesConfig(kubeconfig)

    // creates the client
    client := GetKubernetesClient(config)

    // changes the image
    //deployment, err := client.AppsV1beta1().Deployments(namespaceName).Get(deploymentName, v1.GetOptions{})
    _, err := client.AppsV1beta1().Deployments(namespaceName).Get(deploymentName, v1.GetOptions{})
    if err != nil {
        log.Panic(err.Error())
    }
}
