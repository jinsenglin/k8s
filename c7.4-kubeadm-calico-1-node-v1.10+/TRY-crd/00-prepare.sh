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

function main() {
    with_git
    with_golang
    add_gopath
}

main
