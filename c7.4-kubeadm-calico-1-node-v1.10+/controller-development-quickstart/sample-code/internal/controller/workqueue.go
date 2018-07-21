package controller

import (
    "k8s.io/client-go/util/workqueue"
)

func GetWorkqueue() workqueue.RateLimitingInterface {
    queue := workqueue.NewRateLimitingQueue(workqueue.DefaultControllerRateLimiter())
    return queue
}
