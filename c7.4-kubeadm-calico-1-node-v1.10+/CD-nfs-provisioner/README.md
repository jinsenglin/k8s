Demo

```
cat <<YAML | kubectl create -f -

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: fs-pvc
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 1Gi

---

apiVersion: v1
kind: Pod
metadata:
  name: pod-with-fs-volume
spec:
  containers:
    - name: fc-container
      image: fedora:26
      command: ["/bin/sh", "-c"]
      args: [ "tail -f /dev/null" ]
      volumeMounts:
      - mountPath: "/data"
        name: data
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: fs-pvc

YAML
```
