This is an example to create two app inside one pod, and prove they can share the same network namespace and volume.

deploy
```
jenkins@ConCourse:~$ kubectl apply -f two_debian_in_a_pod.yaml
po "two-app" created
```

Get into first container c1
a. check the volume
b. create a file into volume (so we can find it in second container c2)
c. check IP address by `ip r`

```
jenkins@ConCourse:~$ kubectl exec -it two-app -c c1 -- /bin/sh
# ls /usr/folder1
index.html
# touch /usr/folder1/peter
# ip r
default via 10.244.5.1 dev eth0
10.244.0.0/16 via 10.244.5.1 dev eth0
10.244.5.0/24 dev eth0 proto kernel scope link src 10.244.5.133
# exit
```

Get into second container c2
a. check volume
b. find the file created by c1
c. check IP is the same as what you saw in c1
```
jenkins@ConCourse:~$  kubectl exec -it two-app -c c2 -- /bin/sh
# ls /usr/folder2
index.html  peter
# ls /usr/folder1
ls: cannot access '/usr/folder1': No such file or directory
# ip r
default via 10.244.5.1 dev eth0
10.244.0.0/16 via 10.244.5.1 dev eth0
10.244.5.0/24 dev eth0 proto kernel scope link src 10.244.5.133
# exit
```


One example of multiple container in a pod is `nginx_debian_in_a_pod.yaml`
in this case, you can upgrade your nginx from 1.7.9 to 1.9.0 without impacting the debian container.
