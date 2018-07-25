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

# After installed C-prometheus-node-exporter

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
* [Prometheus Querying Function rate() vs irate()](https://hk.saowen.com/a/9b0e30de9327a6d553ab68061ceac681639d70956b42791a96cbd29f60c16d8b)
* [Irate绘图更精准](https://blog.csdn.net/sinkou/article/details/75303974)
* [Node Exporter 常用查询语句](https://songjiayang.gitbooks.io/prometheus/content/exporter/nodeexporter_query.html)
* [Helm stable/prometheus-node-exporter README.md](https://github.com/helm/charts/tree/master/stable/prometheus-node-exporter) 
* [Prom node exporter README.md](https://github.com/prometheus/node_exporter)
* [Prom node exporter :: collector :: filesystem_linux.go](https://github.com/prometheus/node_exporter/blob/master/collector/filesystem_linux.go)
* [Golang :: package :: syscall :: type Statfs_t](https://golang.org/pkg/syscall/#Statfs_t)
* [Golang :: package :: syscall :: func Statfs](https://golang.org/pkg/syscall/#Statfs)
* [DockerHub prom/node-exporter image info](https://hub.docker.com/r/prom/node-exporter/)
* [quay.io prometheus/node-exporter image info](https://quay.io/repository/prometheus/node-exporter?tab=info)
* [prometheus.io/docs :: Monitoring Linux host metrics with the Node Exporter](https://prometheus.io/docs/guides/node-exporter/)
* [prometheys.io/docs :: PromQL :: Selector :: Instant](https://prometheus.io/docs/prometheus/latest/querying/basics/#instant-vector-selectors)
* [prometheys.io/docs :: PromQL :: Selector :: Range](https://prometheus.io/docs/prometheus/latest/querying/basics/#range-vector-selectors)
* [prometheys.io/docs :: PromQL :: Operator :: Aggregtion](https://prometheus.io/docs/prometheus/latest/querying/operators/#aggregation-operators)
* [prometheys.io/docs :: PromQL :: Function :: rate](https://prometheus.io/docs/prometheus/latest/querying/functions/#rate)
* [prometheys.io/docs :: PromQL :: Function :: irate](https://prometheus.io/docs/prometheus/latest/querying/functions/#irate)
* [Grafana plugin :: dashboard :: Node Exporter Full](https://grafana.com/dashboards/1860)
* [Grafana plugin :: dashboard :: Node Exporter Server Metrics](https://grafana.com/dashboards/405)

# After installed C-kube-state-metrics

```
# query 'kube_pod_container_status_running'
# * sum(kube_pod_container_status_running{namespace="add-on"})
#
```

* [The exposed metrics of kube-state-metrics](https://github.com/kubernetes/kube-state-metrics/tree/master/Documentation)
