package controller

import (
    "log"

    "k8s.io/client-go/kubernetes"
    "k8s.io/client-go/informers"
    "k8s.io/client-go/informers/core/v1"
    "k8s.io/client-go/util/workqueue"
    "k8s.io/client-go/tools/cache"
)

func GetInformerFactory(client kubernetes.Interface) informers.SharedInformerFactory {
    informerFactory := informers.NewSharedInformerFactory(client, 0) // no resync (period of 0)
    return informerFactory
}

func GetPodInformer(informerFactory informers.SharedInformerFactory) v1.PodInformer {
    podInformer := informerFactory.Core().V1().Pods()
    return podInformer
}

func AddEventHandlerForPodInformer(podInformer v1.PodInformer, queue workqueue.RateLimitingInterface) {
    informer := podInformer.Informer()

    informer.AddEventHandler(cache.ResourceEventHandlerFuncs{
        AddFunc: func(obj interface{}) {
            key, err := cache.MetaNamespaceKeyFunc(obj)

            log.Printf("Add pod: %s\n", key)

            if err == nil {
                queue.Add(key)
            }
        },
    })
}
