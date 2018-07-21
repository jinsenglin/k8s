package controller

import (
    "k8s.io/client-go/kubernetes"
)

func Ctrl(client kubernetes.Interface) {
    informerFactory := GetInformerFactory(client)
    queue := GetWorkqueue()

    podInformer := GetPodInformer(informerFactory)
    AddEventHandlerForPodInformer(podInformer, queue)

    // start informer
    stopCh := make(chan struct{})
    informerFactory.Start(stopCh)

    RunWorker(queue)
}
