package controller

import (
    "log"
    "time"

    "k8s.io/client-go/util/workqueue"
)

func RunWorker(queue workqueue.RateLimitingInterface) {
    for {
        log.Printf("queue length: %d\n", queue.Len())
        time.Sleep(10 * time.Second)
    }
}
