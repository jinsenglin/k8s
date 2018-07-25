package main

import (
    "log"

    "k8s.io/apimachinery/pkg/apis/meta/v1"
    "k8s.io/apimachinery/pkg/api/errors"
)

func main() {
    // parses the flag
    flags := ParseFlag()

    // creates the config
    config := GetKubernetesConfig(flags.kubeconfig)

    // creates the client
    client := GetKubernetesClient(config)

    // get the deployment
    deployment, err := client.AppsV1beta1().Deployments(flags.namespaceName).Get(flags.deploymentName, v1.GetOptions{})
    if errors.IsNotFound(err) {
        log.Panicf("Deployment %s in namespace %s not found\n", flags.deploymentName, flags.namespaceName)
    } else if statusError, isStatus := err.(*errors.StatusError); isStatus {
        log.Panicf("Error getting deployment %s in namespace %s: %v\n", flags.deploymentName, flags.namespaceName, statusError.ErrStatus.Message)
    } else if err != nil {
        panic(err.Error())
    } else {
        log.Printf("Found deployment %s in namespace %s\n", flags.deploymentName, flags.namespaceName)

        // get the container
        containers := &deployment.Spec.Template.Spec.Containers
        found := false
        for i := range *containers {
            c := *containers
            if c[i].Name == flags.containerName {
                found = true

                // update the image
                c[i].Image = flags.imageName
            }
        }
        if found == false {
            log.Panicf("Container %s in deployment %s not found\n", flags.containerName, flags.deploymentName)
        }

        // apply the update
        _, err := client.AppsV1beta1().Deployments(flags.namespaceName).Update(deployment)
        if err != nil {
            panic(err.Error())
        }
    }
   
}
