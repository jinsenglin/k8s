```
docker pull grafana/grafana:5.2.1
docker run -d --name grafana -p 3000:3000 grafana/grafana:5.2.1
```

# use grafana

create datasource

```
open http://localhost:3000

# step 1 :: login with admin / admin
#
# step 2 :: fill in following info in the page http://localhost:3000/datasources/edit/1
# * name : k8s-ext-prom
# * url  : http://192.168.240.63:9090
# * remain other fields as default
#
# step 3 :: click Save & Test
```

create dashboard

```
# query 'up'
#
# * dashboard name   : k8s-ext-prom
# * panel type       : graph
# * panel name       : up
# * panel datasource : k8s-ext-prom
# * panel query      : up
```

After installed C-prometheus-node-exporter

```
# query 'node_cpu'
# * avg by (instance, mode) (irate(node_cpu[5m])) * 100
#
# query 'node_memory_MemAvailable'
#
# query 'node_filesystem_avail'
# * 'node_filesystem_avail{device!="overlay",mountpoint="/"}'
#
# query 'node_network_receive_bytes'
# * 'node_network_receive_bytes{device="eth0"}'
# * 'node_network_receive_bytes{device="eth0"}[5m]'
# * 'rate(node_network_receive_bytes{device="eth0"}[5m])'
#
# query 'node_network_transmit_bytes'
# * 'node_network_transmit_bytes{device="eth0"}'
# * 'node_network_transmit_bytes{device="eth0"}[5m]'
# * 'rate(node_network_transmit_bytes{device="eth0"}[5m])'
#
```

Additional Resources

* [Free space vs Available Space](https://github.com/prometheus/node_exporter/issues/269)
* [Node Exporter 常用查询语句](https://songjiayang.gitbooks.io/prometheus/content/exporter/nodeexporter_query.html)
* [Helm stable/prometheus-node-exporter README.md](https://github.com/helm/charts/tree/master/stable/prometheus-node-exporter) 
* [Prom node exporter README.md](https://github.com/prometheus/node_exporter)
* [DockerHub prom/node-exporter image info](https://hub.docker.com/r/prom/node-exporter/)
* [quay.io prometheus/node-exporter image info](https://quay.io/repository/prometheus/node-exporter?tab=info)
* [MONITORING LINUX HOST METRICS WITH THE NODE EXPORTER](https://prometheus.io/docs/guides/node-exporter/)
