# Usage

```
ls /tmp # result 1

kubectl apply -f po.yaml

kubectl exec busybox -- ls /host-tmp # result 2

kubectl delete po/busybox 
```

result 1 is equivalent to result 2.
