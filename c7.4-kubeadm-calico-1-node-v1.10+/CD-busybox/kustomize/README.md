launch

```
# method 1
kubectl apply -f Pod.yaml

# method 2 (equivalent to method 1)
kustomize build | kubectl apply -f -

# method 3
kustomize build overlays/ubuntu | kubectl apply -f -

# method 4
kustomize build overlays/centos | kubectl apply -f -
```

attach 

```
kubectl exec -i -t busybox -- sh
```

detach

```
ctrl + d
```

cleanup

```
kubectl delete -f Pod.yaml
```
