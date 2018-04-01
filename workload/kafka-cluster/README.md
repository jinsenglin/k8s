# USAGE

```
kubectl apply -f zookeeper.yml
kubectl apply -f zookeeper-service.yml
kubectl apply -f kafka-service.yml
kubectl apply -f kafka-cluster.yml # Before apply, change 192.168.1.104 specified in this file
```

REF http://dojoblog.dellemc.com/dojo/deploy-kafka-cluster-kubernetes/
