Check https://kubernetes.io/blog/2018/08/10/introducing-kubebuilder-an-sdk-for-building-kubernetes-apis-using-crds/

Usage

* Create a project with `kubebuilder init`
* Define a new API with `kubebuilder create api`
* Build and run the provided main function with `make install & make run`
* Build and push the container image from the provided Dockerfile using `make docker-build` and `make docker-push` commands
* Deploy the API using `make deploy` command
