#!/bin/bash

set -e
set -o pipefail

function with_golang() {
    command -v go
}

function with_skaffold() {
    command -v skaffold
}

function add_gopath() {
    [ -d ~/go ] || mkdir ~/go
    [ -d ~/go/bin ] || mkdir ~/go/bin
    [ -d ~/go/src ] || mkdir ~/go/src
    [ -d ~/go/pkg ] || mkdir ~/go/pkg
}

function add_dep() {
    curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
}

function main() {
    with_golang
    with_skaffold
    add_gopath
    add_dep
}

main
