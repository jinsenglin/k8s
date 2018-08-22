get token

```
SECRETE_NAME=$(kubectl get sa/user-x -n user-x -o jsonpath={.secrets[0].name})
TOKEN=$(kubectl get secret/$SECRETE_NAME -n user-x -o jsonpath={.data.token} | base64 -d)
```

setup kubeconfig

```
kubectl config set-credentials user-x --token=$TOKEN
kubectl config set-context user-x --cluster=kubernetes --user=user-x --namespace=user-x
kubectl config use-context user-x

# cleanup
kubectl config use-context "kubernetes-admin@kubernetes"
kubectl config delete-context user-x
kubectl config unset users.user-x
```

add extra permissions to support
- get nodes
- top nodes
- top pods

```
cat <<YAML | kubectl create -f -

kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: node-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["nodes"]
  verbs: ["get", "watch", "list"] 
- apiGroups: ["metrics.k8s.io"]
  resources: ["nodes"]
  verbs: ["get", "watch", "list"]

---

kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: node-reader
subjects:
- kind: ServiceAccount
  name: user-x
  namespace: user-x
roleRef:
  kind: ClusterRole
  name: node-reader
  apiGroup: rbac.authorization.k8s.io

YAML
```
