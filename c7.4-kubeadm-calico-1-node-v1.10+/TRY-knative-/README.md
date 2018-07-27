try run

```
# install istio
kubectl apply -f https://storage.googleapis.com/knative-releases/serving/latest/istio.yaml
kubectl label namespace default istio-injection=enabled
get pods -n istio-system

# install knative
kubectl apply -f https://storage.googleapis.com/knative-releases/serving/latest/release.yaml
kubectl get pods -n knative-serving

# deploy knative app
# TODO
```

Additional Resources

* https://github.com/knative/docs/blob/master/install/Knative-with-any-k8s.md
* https://github.com/knative/docs/blob/master/install/getting-started-knative-app.md
