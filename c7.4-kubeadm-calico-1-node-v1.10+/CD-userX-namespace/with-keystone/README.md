NEED tell kube-apiserver to enable authentication-token-webhook and authorization-webhook.

When using dims/k8s-keystone-auth, there are two ways to configure permissions

1. via policy.json, like this https://github.com/dims/k8s-keystone-auth/blob/master/examples/policy.json
2. via k8s rbac

usage

```
source my-os-rc
kubectl use-context openstackcontext
kubectl get pods

# NOTE kubectl now supports using openstack environment variables
```

kubectl kubeconfig file

```
clusters:
- cluster:
  name: kubernetes

users:
- name: openstackuser
  user:
    as-user-extra: {}
    auth-provider:
      name: openstack # IMPORTANT!

contexts:
- context:
    cluster: kubernetes
    user: openstackuser
  name: openstackcontext
```

Additional Resources

* k8s doc
  * https://kubernetes.io/docs/reference/access-authn-authz/webhook/
  * https://kubernetes.io/docs/reference/access-authn-authz/authorization/#authorization-modules :: Webhook
  * https://kubernetes.io/docs/reference/access-authn-authz/authentication/#webhook-token-authentication
* dims/k8s-keystone-auth
  * https://github.com/dims/k8s-keystone-auth#new-kubectl-clients-v180-and-later
  * -> https://github.com/dims/openstack-cloud-controller-manager
  * -> -> https://github.com/kubernetes/cloud-provider-openstack
  * -> -> -> https://github.com/kubernetes/cloud-provider-openstack/search?q=keystone&unscoped_q=keystone
* tutorial
  * http://superuser.openstack.org/articles/keystone-authentication-kubernetes-cluster/
  * http://superuser.openstack.org/articles/kubernetes-keystone-integration-test/
  * https://kairen.github.io/2018/05/30/kubernetes/k8s-integration-keystone/
