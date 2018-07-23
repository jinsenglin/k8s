```
yum install -y haproxy

mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.org
# edit /etc/haproxy/haproxy.cfg
systemctl enable haproxy && systemctl start haproxy 
```

# sample haproxy.cfg

```
# create new
 global
      # for logging section
    log         127.0.0.1 local2 info
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
      # max per-process number of connections
    maxconn     256
      # process' user and group
    user        haproxy
    group       haproxy
      # makes the process fork into background
    daemon

defaults
      # running mode
    mode               http
      # use global settings
    log                global
      # get HTTP request log
    option             httplog
      # timeout if backends do not reply
    timeout connect    10s
      # timeout on client side
    timeout client     30s
      # timeout on server side
    timeout server     30s

# define frontend ( set any name for "http-in" section )
frontend http-in
      # listen 80
    bind *:80
      # set default backend
    default_backend    backend_servers
      # send X-Forwarded-For header
    option             forwardfor

# define backend
backend backend_servers
      # balance with roundrobin
    balance            roundrobin
      # define backend servers
    server             k8s 10.112.0.10:32280 check
```
