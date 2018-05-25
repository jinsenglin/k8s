#!/bin/bash

yum install -y jq wget git tree golang

    wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
    chmod +x cfssl_linux-amd64
    mv cfssl_linux-amd64 /usr/local/bin/cfssl

    wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
    chmod +x cfssljson_linux-amd64
    mv cfssljson_linux-amd64 /usr/local/bin/cfssljson

    go get -u github.com/rakyll/hey
