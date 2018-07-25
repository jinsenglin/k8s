package main

import (
    "log"
    "flag"
    "os"
    "path/filepath"
)

type flags struct {
    kubeconfig     string
    namespaceName  string
    deploymentName string
    containerName  string
    imageName      string
}

func ParseFlag() *flags {
    // parses the command-line flags
    var kubeconfig *string
    if home := homeDir(); home != "" {
        kubeconfig = flag.String("kubeconfig", filepath.Join(home, ".kube", "config"), "(optional) absolute path to the kubeconfig file")
    } else {
        kubeconfig = flag.String("kubeconfig", "", "absolute path to the kubeconfig file")
    }
    namespaceName := flag.String("namespace", "", "existing namespace name")
    deploymentName := flag.String("deploy", "", "existing deployment name")
    containerName := flag.String("container", "", "existing container name")
    imageName := flag.String("image", "", "new image name")

    flag.Parse()

    if *namespaceName == "" {
        log.Panic("You must specify the namespace name.")
    }
    if *deploymentName == "" {
        log.Panic("You must specify the deployment name.")
    }
    if *containerName == "" {
        log.Panic("You must specify the container name.")
    }
    if *imageName == "" {
        log.Panic("You must specify the image name.")
    }

    return &flags{*kubeconfig, *namespaceName, *deploymentName, *containerName, *imageName}
}

func homeDir() string {
    if h := os.Getenv("HOME"); h != "" {
        return h
    }
    return os.Getenv("USERPROFILE") // windows
}
