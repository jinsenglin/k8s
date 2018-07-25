#!/bin/bash

set -e
set -o pipefail

function main() {
    export GOPATH=~/go
    mkdir -p $GOPATH/src/github.com/cclin81922/k8s-image-changer

    cd $GOPATH/src/github.com/cclin81922/k8s-image-changer
        mkdir -p cmd/image-changer pkg internal out
        $GOPATH/bin/dep init
        touch Makefile
        touch cmd/image-changer/main.go
        touch .gitignore
        git init
        git add -A
        git commit -m "init"
}

main
