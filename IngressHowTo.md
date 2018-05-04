# 0. what's nginx-ingress

As you know, 3 ways to expose services: LoadBlancer Service,NodePort,Ingress.
nginx-ingress provides ingress functionality by nginx.
But seems nginx itself can handle the DNS mapping and update. Why ingress ?
ingress config lives in ConfigMap, easy to be live update. You don't need to modify your nginx image to update nginx config.

中文Reference: https://mritd.me/2017/03/04/how-to-use-nginx-ingress/


# 1. Install

Suggest to use Helm. (But following nginx-ingress offical doc is the same. : https://kubernetes.github.io/ingress-nginx/deploy/ )
`helm install stable/nginx-ingress`

# 2. Add `hostNetwork: true` into `nginx-ingress-controller` deployment config.
  by default, nginx is not binding to minions host network, we need to bind to host Network.
  
  if it was installed by helm. you can patch the config even after pod running.
  `kubectl get pod nginx-ingress-controller-xxxxx -o yaml > /tmp/nginx-ingress-deploy.yaml`
  then edit this yaml file,  add `hostNetwork: true` into pod spec:
  `kubectl patch pod  nginx-ingress-controller-xxxxx  -p "$(cat /tmp/nginx-ingress-deploy.yaml)" `
  
  
# 3. Check nginx-ingress is running well.
```
$ kubectl get pods --all-namespaces |grep ingress
default       my-nginx-nginx-ingress-controller-577cfc67c8-gw24c        1/1       Running   0          2d
default       my-nginx-nginx-ingress-default-backend-6c4bcf675b-dtpjx   1/1       Running   0          2d
```

```
$ kubectl get svc --all-namespaces |grep ingress
default       my-nginx-nginx-ingress-controller        LoadBalancer   10.100.242.54    <pending>      80:31954/TCP,443:31536/TCP   2d
default       my-nginx-nginx-ingress-default-backend   ClusterIP      10.97.148.240    <none>         80/TCP                       2d
```

# 4. Create an ingress
If you already runs a service with name 'nginx'
then create a ingress pointing to the `nginx` service, and the host name is `nginx.peter.me` (change it to anything you like)
using below `my-ingress.yaml` file and apply it.
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: nginx-ingress
spec:
  rules:
  - host: nginx.peter.me
    http:
      paths:
      - backend:
          serviceName: nginx
          servicePort: 80
```
Run  `kubectl apply -f my-ingress.yaml`

Then check it
```
$ kubectl get ingress
NAME            HOSTS            ADDRESS   PORTS     AGE
nginx-ingress   nginx.peter.me             80        2d
```


# 6. Access by ingress

But you can't `curl  nginx.peter.me ` in your master node, because nginx controller is binding to the minion node which the pod was deployed to.
check the Node which nginx-controller pod was deployed to.
example: 
```kubectl describe po  my-nginx-nginx-ingress-controller-xxxxx-xxxx |grep Node ```

assuming the deployed minion Node IP is a.b.c.d

Then you can access that nginx by `curl -H "HOST: nginx.peter.me" a.b.c.d`
or add the to /etc/host


# Reference:
https://mritd.me/2017/03/04/how-to-use-nginx-ingress/
https://github.com/nginxinc/kubernetes-ingress/issues/72
http://blog.wercker.com/troubleshooting-ingress-kubernetes

