ConfigMap.yaml for authz policy doesn't work. Need debug - check log authorizer.go:197. (workaround: use k8s rbac)

Reason: no project info nor role info passed to k8s-keystone-auth ... BUG! (root cause: token doesn't contain project nor role info) (solution: openstack user set --project team1 alice # default project is required)

Analysis:
  * kubectl asks client-keystone-auth for a token
  * -> client-keystone-auth asks keystone for a token
  * .. keystone log: 10.112.0.10 - - [24/Aug/2018:01:59:47 +0000] "POST /v3/auth/tokens HTTP/1.1" 201 585 "-" "gophercloud/2.0.0"
  * .. 10.112.0.10 is client-keystone-auth
  * kubectl sends a TokenReview request to kube-apiserver
  * -> kube-apiserver sends a TokenReview request to k8s-keystone-auth
  * -> -> k8s-keystone-auth asks keystone to verify the token
  * .. .. keystone log: 192.168.0.23 - - [24/Aug/2018:01:59:47 +0000] "GET /v3/auth/tokens HTTP/1.1" 200 580 "-" "gophercloud/2.0.0"
  * .. .. 192.168.0.23 is k8s-keystone-auth
  * .. k8s-keystone-auth log (keystone.go:265): authenticateToken <- - - no project info nor role info resovled
  * -> kube-apiserver sends a SubjectAccessReview request to k8s-keystone-auth
  * .. k8s-keystone-auth log (authorizer.go:197): Authorization failed <- - - no project info nor role info passed in

k8s-keystone-auth log (keystone.go:265)
```
authenticateToken : b399a374aeb24a48a5689525ce8a1b8d, &{alice b91698c922a646d88a890370031cf95a [] map[alpha.kubernetes.io/identity/roles:[] alpha.kubernetes.io/identity/project/id:[] alpha.kubernetes.io/identity/project/name:[] alpha.kubernetes.io/identity/user/domain/id:[default] alpha.kubernetes.io/identity/user/domain/name:[Default]]}
```
 
k8s-keystone-auth log (authorizer.go:197)
```
Authorization failed, user: &user.DefaultInfo{Name:"alice", UID:"", Groups:[]string{"", "system:authenticated"}, Extra:map[string][]string{"alpha.kubernetes.io/identity/user/domain/name":[]string{"Default"}, "alpha.kubernetes.io/identity/project/id":[]string{""}, "alpha.kubernetes.io/identity/project/name":[]string{""}, "alpha.kubernetes.io/identity/user/domain/id":[]string{"default"}}}, attributes: authorizer.AttributesRecord{User:(*user.DefaultInfo)(0xc420698ec0), Verb:"list", Namespace:"team1", APIGroup:"", APIVersion:"v1", Resource:"pods", Subresource:"", Name:"", ResourceRequest:true, Path:""}
```

manually sends a token review for b399a374aeb24a48a5689525ce8a1b8d
```
TOKEN=b399a374aeb24a48a5689525ce8a1b8d
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

# result ( NO PROJECT! NOR ROLE! )
{
  "apiVersion": "authentication.k8s.io/v1beta1",
  "kind": "TokenReview",
  "metadata": {
    "creationTimestamp": null
  },
  "spec": {
    "token": "b399a374aeb24a48a5689525ce8a1b8d"
  },
  "status": {
    "authenticated": true,
    "user": {
      "username": "alice",
      "uid": "b91698c922a646d88a890370031cf95a",
      "groups": [
        ""
      ],
      "extra": {
        "alpha.kubernetes.io/identity/project/id": [
          ""
        ],
        "alpha.kubernetes.io/identity/project/name": [
          ""
        ],
        "alpha.kubernetes.io/identity/roles": [],
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
