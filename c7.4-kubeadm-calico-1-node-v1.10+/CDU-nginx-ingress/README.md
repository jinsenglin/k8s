# verify

```
helm create app1
helm install --name app1 --set ingress.enabled=true --set ingress.hosts={app1.default.k8s.local} app1
curl http://app1.default.k8s.local
helm del --purge app1
rm -rf app1
```

# verify tls termination

```
# add "127.0.0.1   cafe.example.com" to /etc/hosts

kubectl apply -f cafe.example.com/
curl -k https://cafe.example.com:32443/coffee
curl -k https://cafe.example.com:32443/tee
kubectl delete -f cafe.example.com/

# remove "127.0.0.1   cafe.example.com" from /etc/hosts
```
