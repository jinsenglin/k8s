NEED tell kube-apiserver to enable authentication-token-webhook and authorization-webhook.

When using dims/k8s-keystone-auth, there are two ways to configure permissions

1. via policy.json, like this https://github.com/dims/k8s-keystone-auth/blob/master/examples/policy.json
2. via k8s rbac, like this http://superuser.openstack.org/articles/keystone-authentication-kubernetes-cluster/

install webhook

```
TODO
```

usage

```
source my-os-rc
kubectl use-context openstackcontext
kubectl get pods

# NOTE kubectl now supports using openstack environment variables
# PR https://github.com/kubernetes/kubernetes/pull/39587

# Sample my-os-rc
export OS_AUTH_URL="http://KEYSTONE_HOST/identity/v3"
export OS_PROJECT_NAME="jinsenglin"
export OS_TENANT_NAME="jinsenglin"
export OS_USERNAME="jinsenglin" # of role: admin, Member
export OS_PASSWORD="jinsenglin"
export OS_REGION_NAME="RegionOne"
export OS_DOMAIN_NAME="default"
export OS_IDENTITY_API_VERSION="3"

# query role id list by $OS_USERNAME 
openstack role assignment list --user $OS_USERNAME 

# query role id and role name list
openstack role list
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
  * -> -> https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/using-keystone-webhook-authenticator-and-authorizer.md
  * -> -> -> https://github.com/kubernetes/cloud-provider-openstack/search?q=keystone&unscoped_q=keystone
* tutorial
  * http://superuser.openstack.org/articles/keystone-authentication-kubernetes-cluster/
  * http://superuser.openstack.org/articles/kubernetes-keystone-integration-test/
  * https://kairen.github.io/2018/05/30/kubernetes/k8s-integration-keystone/
  * https://lingxiankong.github.io/2018-03-28-integration-test-k8s-keystone.html
* docker image
  * k8scloudprovider/k8s-keystone-auth
  * lingxiankong/k8s-keystone-auth:authorization-improved
  * kairen/k8s-keystone-auth:aee023b3
