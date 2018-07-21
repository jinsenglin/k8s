```
yum install -y docker
systemctl enable docker && systemctl start docker

sysctl -w vm.max_map_count=262144
docker pull docker.elastic.co/elasticsearch/elasticsearch-oss:6.3.1
docker run -d --restart always --name es -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch-oss:6.3.1

# verify
# curl http://127.0.0.1:9200/_cat/health
```
