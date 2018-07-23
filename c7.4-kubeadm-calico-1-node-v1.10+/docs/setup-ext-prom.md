```
yum install -y docker
systemctl enable docker && systemctl start docker

docker pull prom/prometheus:v2.3.2
docker run -d --restart always --name prom -p 9090:9090 -v /tmp/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus:v2.3.2

# verify
# curl http://127.0.0.1:9090/
```

# Sample prometheus.yml

```
global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s

    static_configs:
      - targets: ['localhost:9090']
      # targets: ['localhost:9090', 'http://prometheus-node-exporter.add-on.k8s.local', 'http://kube-state-metrics.add-on.k8s.local']
```
