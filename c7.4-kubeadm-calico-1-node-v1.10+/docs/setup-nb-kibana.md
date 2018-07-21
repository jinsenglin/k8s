```
docker pull docker.elastic.co/kibana/kibana-oss:6.3.1
docker run -d --name kibana -p 5601:5601 -e "ELASTICSEARCH_URL=http://192.168.240.63:9200" docker.elastic.co/kibana/kibana-oss:6.3.1
```
