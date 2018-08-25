```
yum install -y docker
systemctl enable docker && systemctl start docker

docker pull prom/prometheus:v2.3.2
docker run -d --restart always --name prom -p 9090:9090 -v $PWD/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus:v2.3.2
# docker run -d --restart always --name prom -p 9090:9090 -v $PWD/prometheus.yml:/etc/prometheus/prometheus.yml -v $PWD:/etc/kubernetes/pki prom/prometheus:v2.3.2

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
      # targets: ['localhost:9090', 'prometheus-node-exporter.add-on.k8s.local:80', 'kube-state-metrics.add-on.k8s.local:80']

  - job_name: 'cadvisor'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s

    static_configs:
      - targets: ['10.112.0.10:10255']

    metrics_path: /metrics/cadvisor
```

# Enable kubernetes_sd_config

prepare admin.crt and admin.key files

```
echo -n "crt string in admin.conf" | base64 -d > admin.crt && chmod 777 admin.crt
echo -n "key string in admin.conf" | base64 -d > admin.key && chmod 777 admin.key
```

prometheus.yaml

```
scrape_configs:
  - job_name: 'kubernetes-pods'

    kubernetes_sd_configs:
    - role: pod
      api_server: https://10.112.0.10:6443
      tls_config:
        cert_file: /etc/kubernetes/pki/admin.crt
        key_file: /etc/kubernetes/pki/admin.key
        insecure_skip_verify: true
```

Explain

* Relabeling is a powerful tool to dynamically rewrite the label set of a target **before** it gets scraped.

# Additional Resources

* [kubernetes_sd_config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#%3Ckubernetes_sd_config%3E)
  * role: node
  * role: service
  * role: pod
  * role: endpoints
  * role: ingress
* [examples/prometheus-kubernetes.yml](https://github.com/prometheus/prometheus/blob/master/documentation/examples/prometheus-kubernetes.yml)
  * job_name: 'kubernetes-apiservers'
      * kubernetes_sd_config :: role: endpoints
  * job_name: 'kubernetes-nodes'
      * kubernetes_sd_config :: role: node
  * job_name: 'kubernetes-cadvisor'
      * kubernetes_sd_config :: role: node
  * job_name: 'kubernetes-service-endpoints'
      * kubernetes_sd_config :: role: endpoints
  * job_name: 'kubernetes-services'
      * kubernetes_sd_config :: role: service
  * job_name: 'kubernetes-ingresses'
      * kubernetes_sd_config :: role: ingress
  * job_name: 'kubernetes-pods'
      * kubernetes_sd_config :: role: pod
* gpu-smi-exporter
  * https://www.slideshare.net/inwinstack/prometheus-kubernetes-cluster
* pod filesystem
  * https://www.slideshare.net/inwinstack/prometheus-kubernetes-cluster
  * https://groups.google.com/forum/#!topic/prometheus-users/yQxNzwHrc8o
  * https://groups.google.com/forum/#!topic/prometheus-users/eaoPBsYrNlQ
