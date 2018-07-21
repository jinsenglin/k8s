```
yum install -y haproxy

mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.org
# edit /etc/haproxy/haproxy.cfg
systemctl enable haproxy && systemctl start haproxy 
```
