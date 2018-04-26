## Deploy a MySql ##

This is a quick tutorial for setup a Host Mount Volume (Note: HostPath is only for testing, not production.)

on your k8s-master
```
mkdir /tmp/k8s-pv
```

1.Create PV
```
kubectl create -f mysql-pv.yaml
```
Check it's ready
```
$ kubectl get pv
NAME           CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM     STORAGECLASS   REASON    AGE
my-pv-volume   2Gi        RWO            Retain           Available             manual                   5s
```

2. Claim and use the PV in mysql deployment
```
kubectl create -f mysql-deployment.yaml
```

Check PVC has been fulfilled(Bound)

```
$ kubectl get pvc
NAME             STATUS    VOLUME         CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mysql-pv-claim   Bound     my-pv-volume   2Gi        RWO            manual         5s
```

3. Your MySql is ready to be access on DNS `mysql` from other pod

-----

FAQ:

a. Q: `kubectl describe pvc` reports error `Error:Unable to create a persistent volume with a default storage class`
   A:  Check the PVC `StorageClassName` aligns with PV
b. Q: even previous PVC deleted, a new PVC can't claim and bind to a PV: `Error : storageclass.storage.k8s.io "manual" not found`
   A: PV default recycle strategy is "Retain", even previous PVC deleted, but its data still persist , and PV still occupied. you can delete/re-create that PV.


