If there is no log files in the directory '/var/log/containers/', check the docker daemon flag '--log-driver'.

Change log-driver from 'journald' to 'json-file' by modifiying the file '/etc/sysconfig/docker' then restart docker daemon.
