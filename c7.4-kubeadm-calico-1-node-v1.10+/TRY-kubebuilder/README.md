Check https://kubernetes.io/blog/2018/08/10/introducing-kubebuilder-an-sdk-for-building-kubernetes-apis-using-crds/

Install

```
version=1.0.0 # latest stable version
arch=amd64
os=linux # or darwin

# download the release
curl -L -O https://github.com/kubernetes-sigs/kubebuilder/releases/download/v${version}/kubebuilder_${version}_${os}_${arch}.tar.gz

# extract the archive
tar -zxvf kubebuilder_${version}_${os}_${arch}.tar.gz
sudo mv kubebuilder_${version}_${os}_${arch} /usr/local/kubebuilder

# update your PATH to include /usr/local/kubebuilder/bin
export PATH=$PATH:/usr/local/kubebuilder/bin
```

Usage

* Create a project with `kubebuilder init`
* Define a new API with `kubebuilder create api`
* Build and run the provided main function with `make install & make run`
* Build and push the container image from the provided Dockerfile using `make docker-build` and `make docker-push` commands
* Deploy the API using `make deploy` command
