#!/bin/bash

set -e
set -o pipefail

function with_git() {
    command -v git
    git config --global user.name "Your Name"
    git config --global user.email you@example.com
}

function with_golang() {
    command -v go
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
    with_git
    with_golang
    add_gopath
    add_dep
}

main
