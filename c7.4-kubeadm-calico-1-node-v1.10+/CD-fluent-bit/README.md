If there is no log files in the directory '/var/log/containers/', check the docker daemon flag '--log-driver'.

Change log-driver from 'journald' to 'json-file' by modifying the file '/etc/sysconfig/docker' then restart docker daemon.

Sample /etc/sysconfig/docker
```
--log-driver json-file --log-opt max-size=10m
```

Or by modifying the file '/etc/docker/daemon.json' then restart docker daemon.

Sample /etc/docker/daemon.json
```
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m"
  }
}
```
