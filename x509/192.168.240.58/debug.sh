#!/bin/bash

openssl s_client -CAfile ca.crt -connect 192.168.240.58.xip.io:443
