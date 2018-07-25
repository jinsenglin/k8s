# verify

```
helm create app1
helm install --name app1 --set ingress.enabled=true --set ingress.hosts={app1.default.k8s.local} app1
curl http://app1.default.k8s.local
helm del --purge app1
rm -rf app1
```

# verify tls termination

TODO
