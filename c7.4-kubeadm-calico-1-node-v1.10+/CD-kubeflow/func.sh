GITHUB_TOKEN=
APP_NAME=kubeflow-app

function create_kubeflow() {
    export KUBEFLOW_VERSION=0.2.2
    export KUBEFLOW_REPO=/tmp/kubeflow_repo
    export KUBEFLOW_KS_DIR=/tmp/$APP_NAME
    export KUBEFLOW_DEPLOY=false
    curl https://raw.githubusercontent.com/kubeflow/kubeflow/v${KUBEFLOW_VERSION}/scripts/deploy.sh | bash

    cd $KUBEFLOW_KS_DIR
        ks env set default --namespace add-on
        ks param set kubeflow-core reportUsage false
        ks apply default
}

function delete_kubeflow() {
    KUBEFLOW_REPO=/tmp/kubeflow_repo
    KUBEFLOW_KS_DIR=/tmp/$APP_NAME

    cd $KUBEFLOW_KS_DIR
        ks delete default
    cd -

    rm -rf $KUBEFLOW_KS_DIR
    rm -rf $KUBEFLOW_REPO
}
