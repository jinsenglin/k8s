# veirfy

```
kubectl top nodes

# NEED open kubelet port 10255.
# kubelet servers http://<NODE IP>:10255/stats/summary/ API
# metrics-server query data from kubelet stats/summary/ API

# NOTE wait for a while after opening port 10255
```
