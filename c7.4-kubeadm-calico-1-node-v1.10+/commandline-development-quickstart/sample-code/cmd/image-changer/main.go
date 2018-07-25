package main

import (
    "log"

    "k8s.io/apimachinery/pkg/apis/meta/v1"
    "k8s.io/apimachinery/pkg/api/errors"
)

func main() {
    // parses the flag
    kubeconfig, namespaceName, deploymentName, containerName, imageName := ParseFlag()

    // creates the config
    config := GetKubernetesConfig(kubeconfig)

    // creates the client
    client := GetKubernetesClient(config)

    // get the deployment
    deployment, err := client.AppsV1beta1().Deployments(namespaceName).Get(deploymentName, v1.GetOptions{})
    if errors.IsNotFound(err) {
        log.Panicf("Deployment %s in namespace %s not found\n", deploymentName, namespaceName)
    } else if statusError, isStatus := err.(*errors.StatusError); isStatus {
        log.Panicf("Error getting deployment %s in namespace %s: %v\n", deploymentName, namespaceName, statusError.ErrStatus.Message)
    } else if err != nil {
        panic(err.Error())
    } else {
        log.Printf("Found deployment %s in namespace %s\n", deploymentName, namespaceName)

        // get the container
        containers := &deployment.Spec.Template.Spec.Containers
        found := false
        for i := range *containers {
            c := *containers
            if c[i].Name == containerName {
                found = true

                // update the image
                c[i].Image = imageName
            }
        }
        if found == false {
            log.Panicf("Container %s in deployment %s not found\n", containerName, deploymentName)
        }

        // apply the update
        _, err := client.AppsV1beta1().Deployments(namespaceName).Update(deployment)
        if err != nil {
            panic(err.Error())
        }
    }
   
}
