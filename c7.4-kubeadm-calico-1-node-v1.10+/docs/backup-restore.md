Prepare machine for restore

* hostname: k8s
* ip: 10.112.0.10

Backup etcd

```
export ETCDCTL_API=3
etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/apiserver-etcd-client.crt --key=/etc/kubernetes/pki/apiserver-etcd-client.key snapshot save etcd-snapshot.db
```

Restore etcd

```
export ETCDCTL_API=3
etcdctl snapshot restore etcd-snapshot.db
rm -rf /var/lib/etcd && mv default.etcd /var/lib/etcd
```

Backup images

```
docker save -o IMAGE.tar IMAGE
docker save -o IMAGE.tar IMAGE
docker save -o IMAGE.tar IMAGE

docker images --format "{{.ID}} {{.Repository}} {{.Tag}}" | { while read id repo tag; do [ -f $(basename $repo):$tag.tar ] || docker save -o $(basename $repo):$tag.tar $id; done; }
```

Restore images

```
docker load -i IMAGE.tar
docker load -i IMAGE.tar
docker load -i IMAGE.tar
```

Backup /etc/kubernetes

```
tar -czf kubernetes.tar.gz /etc/kubernetes
```

Restore /etc/kubernetes

```
tar -zxf kubernetes.tar.gz
rm -rf /etc/kubernetes && mv etc/kubernetes /etc/kubernetes && rmdir etc
```

Backup /etc/hostname

```
tar -czf hostname.tar.gz /etc/hostname
```

Restore /etc/hostname

```
tar -zxf hostname.tar.gz
rm -f /etc/hostname && mv etc/hostname /etc/hostname && rmdir etc
```

Backup persistent volume

```
TODO
```

Restore persistent volume

```
TODO
```

Additional Resources

* https://kubernetes.io/docs/getting-started-guides/ubuntu/backups/
* https://github.com/kubernetes/kubernetes/blob/master/cluster/restore-from-backup.sh
* https://medium.com/@pmvk/kubernetes-backups-and-recovery-efc33180e89d
  * Ark
  * kube-backup

# Demo

1. create a deployment and then expose it

```
kubectl run --image=nginx:1.14.0 --port=80 ng
kubectl expose --type NodePort --port=8080 --target-port=80 deploy ng
```

2. test

```
curl 10.0.2.15:32019
```

3. backup etcd

```
export ETCDCTL_API=3
etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/apiserver-etcd-client.crt --key=/etc/kubernetes/pki/apiserver-etcd-client.key snapshot save etcd-snapshot.db
```

4. delete the deployment and the service

```
kubectl delete svc ng
kubectl delete deply ng
```

5. restore from the backup etcd

```
echo "3.2.18/etcd3" > version.txt
bash revised-restore-from-backup.sh # the original restore-from-backup.sh is here https://github.com/kubernetes/kubernetes/blob/master/cluster/restore-from-backup.sh
```

6. test

```
curl 10.0.2.15:32019 
```
