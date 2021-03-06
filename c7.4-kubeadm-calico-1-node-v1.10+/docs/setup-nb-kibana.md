```
docker pull docker.elastic.co/kibana/kibana-oss:6.3.1
docker run -d --name kibana -p 5601:5601 -e "ELASTICSEARCH_URL=http://192.168.240.63:9200" docker.elastic.co/kibana/kibana-oss:6.3.1
```

# use kibana

create index

```
open http://localhost:5601

# A. for fluent-bit-0.6.0
# step 1 :: create index pattern "kubernetes_cluster-*"
# step 2 :: select time filter field name, available options:
  * @timestamp (try this one)
  * kubernetes.annotations.kubernetes_io/config_seen
  * time

# B. for fluent-bit-0.9.0
# step 1 :: create index pattern "logstash-*"
# step 2 :: select time filter field name, available options:
  * @timestamp (try this one)
  * kubernetes.annotations.kubernetes_io/config_seen
  * time
```

query logs

```
# query logs by pod name
# e.g. kubernetes.pod_name:etcd-k8s

# query logs by namespace name
# e.g., kubernetes.namespace_name:add-on
```
