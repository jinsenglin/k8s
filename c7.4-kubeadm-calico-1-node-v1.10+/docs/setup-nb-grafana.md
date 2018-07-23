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
```
