#!/bin/bash

C=TW
ST=Taiwan
L=Taipei
O=LIN
OU=Jim
CN=192.168.240.58.xip.io
ROOT_CN=root.$CN
emailAddress=admin@$CN

openssl req -new -sha256 -keyout data/server.key -out data/server.csr -days 365 -newkey rsa:2048 -nodes -subj "/C=$C/ST=$ST/L=$L/O=$O/OU=$OU/CN=$CN/emailAddress=$emailAddress"
openssl x509 -req -days 365 -sha1 -CA ca.crt  -CAkey ca.key -CAcreateserial -in data/server.csr -out data/server.crt
