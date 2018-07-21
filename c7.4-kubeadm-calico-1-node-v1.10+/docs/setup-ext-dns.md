```
yum install -y bind-utils dnsmasq
# edit /etc/dnsmasq.d/wild-k8s
systemctl enable dnsmasq && systemctl start dnsmasq

# verify
# nslookup k8s.local 127.0.0.1
# nslookup default.k8s.local 127.0.0.1
# nslookup app1.default.k8s.local 127.0.0.1
```

# sample wild-k8s

```
address=/k8s.local/192.168.240.57
```
