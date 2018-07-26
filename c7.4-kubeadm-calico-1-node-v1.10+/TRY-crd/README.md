sample-controller-kubernetes-1.11.1 is downloaded from https://github.com/kubernetes/sample-controller/tree/kubernetes0.11.1

try run

```
# assumes you have a working kubeconfig, not required if operating in-cluster
$ go run *.go -kubeconfig=$HOME/.kube/config

# create a CustomResourceDefinition
$ kubectl create -f artifacts/examples/crd.yaml

# create a custom resource of type Foo
$ kubectl create -f artifacts/examples/example-foo.yaml

# check deployments created through the custom resource
$ kubectl get deployments
```
