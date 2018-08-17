Check https://metacontroller.app

usage

```
git clone https://github.com/GoogleCloudPlatform/metacontroller.git

# Install Metacontroller :: Create 'metacontroller' namespace, service account, and role/binding.
kubectl apply -f metacontroller/manifests/metacontroller-rbac.yaml

# Output
# namespace/metacontroller created
# serviceaccount/metacontroller created
# clusterrole.rbac.authorization.k8s.io/metacontroller created
# clusterrolebinding.rbac.authorization.k8s.io/metacontroller created 

# Install Metacontroller :: Create CRDs for Metacontroller APIs, and the Metacontroller StatefulSet.
kubectl apply -f metacontroller/manifests/metacontroller.yaml

# Output
# customresourcedefinition.apiextensions.k8s.io/compositecontrollers.metacontroller.k8s.io created
# customresourcedefinition.apiextensions.k8s.io/decoratorcontrollers.metacontroller.k8s.io created
# customresourcedefinition.apiextensions.k8s.io/controllerrevisions.metacontroller.k8s.io created
# statefulset.apps/metacontroller created

# Run Example :: CompositeController :: CatSet (JavaScript)
#

# Run Example :: CompositeController :: BlueGreenDeployment (JavaScript)
#

# Run Example :: CompositeController :: IndexedJob (Python)
#

# Run Example :: CompositeController :: Vitess Operator (Jsonnet)
#

# Run Example :: DecoratorController :: Service Per Pod (Jsonnet)
# cd metacontroller/examples/service-per-pod/
# bash test.sh

```

Addiontional Resources

* https://admiralty.io/kubernetes-custom-resource-controller-and-operator-development-tools.html
* https://github.com/GoogleCloudPlatform/metacontroller/tree/master/examples/jsonnetd
* https://github.com/google/go-jsonnet
* https://jsonnet.org/
