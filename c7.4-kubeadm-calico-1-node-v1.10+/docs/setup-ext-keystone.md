```
yum install -y docker
systemctl enable docker && systemctl start docker

docker pull docker.io/stephenhsu/keystone:9.1.0
docker run -d --restart always --name ks -p 5000:5000 -p 35357:35357 -e TLS_ENABLED=true docker.io/stephenhsu/keystone:9.1.0

# verify
# curl http://127.0.0.1:5000/
# curl http://127.0.0.1:5000/v3
# curl http://127.0.0.1:35357/
# curl http://127.0.0.1:35357/v3
# docker exec ks cat openrc

# copy openrc file
# docker cp ks:/root/openrc .

# copy ca cert file
# docker cp ks:/etc/apache2/ssl/apache.crt .
```

Sample openrc file

```
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=passw0rd
export OS_AUTH_URL=https://86a82ce738af:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
export OS_CACERT=/etc/apache2/ssl/apache.crt
```
