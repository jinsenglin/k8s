#!/bin/bash

set -e
set -o pipefail

function add_golang() {
    yum install -y golang
}

function add_gopath() {
    mkdir -p ~/go
    mkdir -p ~/go/bin
    mkdir -o ~/go/src
    mkdir -o ~/go/pkg
}

function add_dep() {
    curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
}

function main() {
    add_golang
    add_gopath
    add_dep
}

main
