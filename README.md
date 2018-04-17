# KubernetesNotes

Audience:

* CN: 使用minikube 怎么解决x509证书问题(x509: certificate signed by unknown authority)
* EN: This article is mainly for some Corp User, who have limited access to google websites.example (x509: certificate signed by unknown authority)

= Another Way out ==  Build your own minikube : http://wiselyman.iteye.com/blog/2381738


先 highligh issues:
1. `minikube start error`
2. `container 卡在ContainerCreating`
3. `minikube dashboard not working`

Another good reference: https://qii404.me/2018/01/06/minukube.html



For US engineers, go thru the K8S tutorials will be quite easy. But it's tough inside some Chinese Corp Lab environment .



Ok, here's the steps and special highlight for workaround in my enviroment (hope will help you as well).

NOTE: below notes are for Linux (tested on Ubuntu 16.04)



## 1.Install virtualbox (https://www.virtualbox.org/wiki/Linux_Downloads)
(after that check by `vboxmanage list vms` to ensure no error message shown up


## 2.Download minikube
```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64 && \
  chmod +x minikube && \
  sudo mv minikube /usr/local/bin/
```



## 3.Download kubectl

https://kubernetes.io/docs/tasks/tools/install-kubectl/



## 4.Install googleapis certificate in local machine 
(seems helpless, though...T_T 木有用，没事，关键不在这)

```
echo -n | openssl s_client -showcerts -connect storage.googleapis.com:443 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /usr/local/share/ca-certificates/googleapis.crt
update-ca-certificates
```


## 5.Start Minikube 
`minikube start`

### Error Message #1:
```
* Error starting host: Error attempting to cache minikube ISO from URL: Error downloading Minikube ISO: failed to download: failed to download to temp file: download failed: 5 error(s) occurred:
* Temporary download error: Get https://storage.googleapis.com/minikube/iso/minikube-v0.25.1.iso: x509: certificate signed by unknown authority
```
It's because the minikube virturalbox iso image failed to downloaded from googleapis.com... we can download it manually and add "--insecure" for curl command to workaround the x509 certificate issue.

**Resolution**
```
cd ~/.minikube/cache/iso
curl -O https://storage.googleapis.com/minikube/iso/minikube-v0.25.1.iso --insecure
         Reference: http://www.cnblogs.com/sting2me/p/5596222.html
```

### Error Message #2:
```
* Error updating cluster: Error updating localkube from uri: Error creating localkube asset from url: Error opening file asset: /home/jenkins/.minikube/cache/localkube/localkube-v1.9.0: open /home/jenkins/.minikube/cache/localkube/localkube-v1.9.0: no such file or directory
```
Similar Resolution :
```
cd ~/.minikube/cache/localkube
wget https://github.com/kubernetes/minikube/releases/download/v0.25.0/localkube
mv localkube localkube-v1.9.0
```
After above 2 issues address, `minikube start` should be fine.



## Check Cluster status 

```
kubectl config use-context minikube

kubectl cluster-info
```

it should show sth like `Kubernetes master is running at https://192.168.**.1**:8443`


## 6.Deploy an APP

```
 kubectl run my-nginx --image=nginx  --port=80
 ```
Above may be far away from enough. You will see pod stuck at "ContainerCreating" and never be "Ready"/"Running"
卡在ContainerCreating

When `kubectl get pods`, you will find it's stuck....
```
NAME                       READY               STATUS                           RESTARTS        AGE
my-nginx-9d5677d94-l25bh    0/1           ContainerCreating                       0            5m
```

Oops. `minikube logs` can find some `error pulling` errors from `gcr.io`.


**Why it's stuck**

It's stuck in "ContainerCreating" because K8S in minikube requires  `pause` image. which will be download from "gcr.io" which is not reachable from my lab again...

example, in my case , it requries `gcr.io/google_containers/pause-amd64`

So you can try to `minikube ssh`, then go into the minikube VM, try to `docker pull gcr.io/google_containers/pause-amd64`, you will find it timeout and failing. 

Below is the cure. It will download another pause image and **pretend** to be a image from gcr.io by changing its image name.
```
minikube ssh 
# now you are inside the minikube VM
docker pull docker.io/kubernetes/pause
docker tag docker.io/kubernetes/pause gcr.io/google_containers/pause-amd64
docker rmi -f docker.io/kubernetes/pause
# then `docker images` to double check
```
reference:  http://blog.sina.com.cn/s/blog_8ea8e9d50102ww8m.html


**Re-deploy again**

Then delete your deployment `kubectl delete deployment my-nginx` and re-deploy again `kubectl run my-nginx --image=nginx  --port=80`. Then you will find after 5-10sec, containers become "Running"!!!
```
NAME                       READY               STATUS                     RESTARTS        AGE
my-nginx-9d5677d94-gbkhl    1/1                Running                       0            10s
```


## 7. Other part of the toturial :  

剩下部分不再赘述啦( those are the same as tutorial)

 Expose the service
```
kubectl expose deployment/my-nginx --type="NodePort"
kubectl get services
```

Try to access this nginx 
```
export NODE_PORT=$(kubectl get services/my-nginx -o go-template='{{(index .spec.ports 0).nodePort}}')
echo $NODE_PORT
export IP=$(minikube ip)
curl ${IP}:${NODE_PORT}
```


## 8 Dashboard
`minikube dashboard` may suffer from `Could not find finalized endpoint being pointed to by kubernetes-dashboard: Error validating service: Error getting service kubernetes-dashboard: services "kubernetes-dashboard" not found`
There're no releavant images inside minikube VM.
it's because those dashboard/add-on images couldn't be pulled inside minikube VM, again... 
There're two cases:
1. You can't access Google (gcr.io) due to GFW inside China
2. x509 certification error due to Corp network .

for case (2), just follow below two steps:
```
minikube delete # delete the VM to restore clean state
# then treat gcr.io as insecure registry. so to skip x509 certification check
minikube start  --insecure-registry=gcr.io --insecure-registry=googleapis.com --insecure-registry=k8s.gcr.io

```
for case(1):

so we follow the same pattern as above "pulling from other place, and using docker-tag to pretend as a google image.."



let's pull images from 阿里云(Ali Yun):
```
1. Find missing image:tag from log (minikube logs|grep pulling)
```
example. `gcr.io/google-containers/kube-addon-manager:v6.5` is missing.
```
2. minikube ssh
3. docker pull registry.cn-hangzhou.aliyuncs.com/google-containers/kube-addon-manager-amd64:v6.1 
4. docker tag registry.cn-hangzhou.aliyuncs.com/google-containers/kube-addon-manager-amd64:v6.1  ${the missing addon image:version}
```
```
minikube stop
minikube start
```

reference: https://qii404.me/2018/01/06/minukube.html









