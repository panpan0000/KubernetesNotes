This is a quick example to deploy 2 replicas of nginx and show you how to expose it and access it from external.

# 1.Deploy 2 pods of nginx
```
kubectl create -f  nginx-deployment.yaml
```
above is the same as below in command line
```
kubectl run nginx --image=nginx:1.7.9 --replicas=2
```

# 2. Expose service by NodePort
```
kubectl create -f  nginx-service.yaml
```
above is the same as below command line
```
kubectl expose deploy/nginx --type="NodePort"  --port 80
```


# 3.(optional)
above (1)(2) step can be also implemented by single command line
```
kubectl run nginx --image=nginx:1.7.9 --port=80  --replicas=2
```
And yes, you can combine the two yaml together into one file, with `---` delimar.


# 4.Access nginx website from your browser

4.1 Find the Minios Node the pos are deployed to.

```
jenkins@ConCourse:~$ kubectl get po
NAME                     READY     STATUS    RESTARTS   AGE
nginx-769c4f66dc-t28qd   1/1       Running   0          10m
nginx-769c4f66dc-vwwgk   1/1       Running   0          10m
--------------
```

get Node IP which the pod was deployed to
```
jenkins@ConCourse:~$ kubectl describe po nginx-769c4f66dc-t28qd |grep Node
Node:           rackhd-server/10.**.**.101
Node-Selectors:  <none>

```
```
jenkins@ConCourse:~$ kubectl describe po nginx-769c4f66dc-vwwgk |grep Node
Node:           rackhd-server/10.**.**.102
Node-Selectors:  <none>
```

So the 10.**.**.101 & 10.**.**.102 are the NodeIP we need(either one will be ok.)


4.2 Get exposed service port 

```
jenkins@ConCourse:~$ kubectl get svc
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
nginx        NodePort    10.96.132.84   <none>        80:30591/TCP   17h
```
Above 30591 is the random port K8S assign to nginx service ($Port)


4.3 go to your web browser, open URL http://$NodeIP:$Port

