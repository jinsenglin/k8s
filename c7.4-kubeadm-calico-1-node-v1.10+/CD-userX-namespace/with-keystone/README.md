# NEXT STEP

In this doc, accessing keystone is via http instead of https. Need check how to pass ca cert file to k8s-keystone-auth.

# NEED

Tell kube-apiserver to enable authentication-token-webhook and authorization-webhook. [[doc](../../07-update-kube-apiserver.sh)]

# NOTE

When using dims/k8s-keystone-auth, there are two ways to configure permissions

1. via policy.json, like this https://github.com/dims/k8s-keystone-auth/blob/master/examples/policy.json
2. via k8s rbac, like this http://superuser.openstack.org/articles/keystone-authentication-kubernetes-cluster/

# USAGE

use internal keystone to create some demo data and to get tokens

```
kubectl -n kube-system exec os-keystone-6c5c7b84b7-59jwl -it -- bash

source openrc
openstack project create team1
openstack project create team2
openstack role create k8s-admin
openstack role create k8s-viewer
openstack user create --password passw0rd alice
openstack user create --password passw0rd bob
openstack user create --password passw0rd carol
openstack role add --user alice --project team1 k8s-admin
openstack role add --user bob --project team2 k8s-admin
openstack role add --user carol --project team2 k8s-viewer

export OS_PROJECT_NAME=team1
export OS_USERNAME=alice
openstack token issue -c id -f value
# 822da94d09a74196952613487772a800

export OS_PROJECT_NAME=team2
export OS_USERNAME=bob
openstack token issue -c id -f value
# ee39b1e0e2654443a368eca6ae21ad84

export OS_PROJECT_NAME=team2
export OS_USERNAME=carol
openstack token issue -c id -f value
# 1675355538244cddb12e60cbe66ec2cc

exit
```

test k8s-keystone-auth service :: authn

```
# see this https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/using-keystone-webhook-authenticator-and-authorizer.md#test-k8s-keystone-auth-service

# sample curl
TOKEN=822da94d09a74196952613487772a800
cat <<EOF | curl -ks -XPOST -d @- https://10.112.0.10:31443/webhook
{
  "apiVersion": "authentication.k8s.io/v1beta1",
  "kind": "TokenReview",
  "metadata": {
    "creationTimestamp": null
  },
  "spec": {
    "token": "$TOKEN"
  }
}
EOF

# sample output
{
  "apiVersion": "authentication.k8s.io/v1beta1",
  "kind": "TokenReview",
  "metadata": {
    "creationTimestamp": null
  },
  "spec": {
    "token": "822da94d09a74196952613487772a800"
  },
  "status": {
    "authenticated": true,
    "user": {
      "username": "alice",
      "uid": "445dbd0cacd44ba6bb78c87771a550df",
      "groups": [
        "9aa12faec95c4d5d84538453e65fc139"
      ],
      "extra": {
        "alpha.kubernetes.io/identity/project/id": [
          "9aa12faec95c4d5d84538453e65fc139"
        ],
        "alpha.kubernetes.io/identity/project/name": [
          "team1"
        ],
        "alpha.kubernetes.io/identity/roles": [
          "k8s-admin"
        ],
        "alpha.kubernetes.io/identity/user/domain/id": [
          "default"
        ],
        "alpha.kubernetes.io/identity/user/domain/name": [
          "Default"
        ]
      }
    }
  }
}
```

test k8s-keystone-auth service :: authz

```
# see this https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/using-keystone-webhook-authenticator-and-authorizer.md#test-k8s-keystone-auth-service

# sample curl
cat <<EOF | curl -ks -XPOST -d @- https://10.112.0.10:31443/webhook
{
  "apiVersion": "authorization.k8s.io/v1beta1",
  "kind": "SubjectAccessReview",
  "spec": {
    "resourceAttributes": {
      "namespace": "team1",
      "verb": "create",
      "group": "",
      "resource": "pods"
    },
    "user": "alice",
    "group": ["9aa12faec95c4d5d84538453e65fc139"],
    "extra": {
        "alpha.kubernetes.io/identity/project/id": ["9aa12faec95c4d5d84538453e65fc139"],
        "alpha.kubernetes.io/identity/project/name": ["team1"],
        "alpha.kubernetes.io/identity/roles": ["k8s-admin"]
    }
  }
}
EOF

# sample output
{
    "apiVersion": "authorization.k8s.io/v1beta1",
    "kind": "SubjectAccessReview",
    "status": {
        "allowed": true
    }
}
```

use kubectl with keystone token

```
source openrc-alice
kubectl config use-context openstackcontext
kubectl get pods

# NOTE kubectl now supports using openstack environment variables
# PR https://github.com/kubernetes/kubernetes/pull/39587
# Client auth providers are deprecated in v1.11.0 and to be removed in the next version. The recommended way of client authentication is to use exec mode with the client-keystone-auth binary.
```

kubectl kubeconfig file for kubectl clients from v1.8.0 to v1.10.x

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
    namespace: team1
    user: openstackuser
  name: openstackcontext
```

kubectl kubeconfig file for kubectl clients from v1.11.0 and later

```
clusters:
- cluster:
  name: kubernetes

users:
- name: openstackuser
  user:
    exec:
      command: "/usr/local/bin/client-keystone-auth"
      apiVersion: "client.authentication.k8s.io/v1alpha1"

contexts:
- context:
    cluster: kubernetes
    namespace: team1
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
  * https://lingxiankong.github.io/2018-03-28-integration-test-k8s-keystone.html
  * https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/using-keystone-webhook-authenticator-and-authorizer.md
* docker image
  * [k8scloudprovider/k8s-keystone-auth](https://hub.docker.com/r/k8scloudprovider/k8s-keystone-auth/)
  * lingxiankong/k8s-keystone-auth:authorization-improved
  * kairen/k8s-keystone-auth:aee023b3
* auth parameters in the ~/.kube/config file for integration of kubectl and keystone
  * [Keystone client-go credential plugin usage](https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/using-client-keystone-auth.md)
  * [client-go credential plugins](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#client-go-credential-plugins)
* command source code
  * [k8s-keystone-auth/main.go](https://github.com/kubernetes/cloud-provider-openstack/blob/master/cmd/k8s-keystone-auth/main.go)
  * [client-keystone-auth/main.go](https://github.com/kubernetes/cloud-provider-openstack/blob/master/cmd/client-keystone-auth/main.go)
