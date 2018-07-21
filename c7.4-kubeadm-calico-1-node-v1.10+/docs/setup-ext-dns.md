```
yum install -y bind-utils dnsmasq
# edit /etc/dnsmasq.d/wild-k8s
systemctl enable dnsmasq && systemctl start dnsmasq
```

# sample wild-k8s

```
address=/k8s.local/192.168.240.57
```
