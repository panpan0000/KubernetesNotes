Q: when query k8s system pod/deploy/service, example : `kubectl get deploy kubernetes-dashboard`  :    
`Error:   Error from server (NotFound): deployments.extensions "kubernetes-dashboard" not found`

A:that's because default namespace is "default", specify ns clearly to pointing kube-system         :
`kubectl get deploy kubernetes-dashboard --namespace=kube-system`

----

Q: How to debug issues ? Below are Debugging Tips 
   * 1.  "kubecel describe" to check the last event, usually, it will provide you hint, like image pull failure.
```
kubectl describe po kubernetes-dashboard-7d5dcdb6d9-cbph5 --namespace=kube-system
```

   * 2. check system kubelet logs, for more information
         If you are running k8s cluster, using `sudo journalctl -u kubelet`
         If you are running minikube, using `minikube logs`

   * 3. Step in and Check container 
        * `kubectl logs  $POD -c $ContainerName`  (this equals `docker logs` if you are familar with docker)
        * `kubectl exec -it $POD  -c $ContainerName  -- /bin/bash` (equals to `docker exec`)
        
   * 4. If kubernetes basic functionalites are not working, do check the system service pod health.
        * in minikube, check ` minikube addons list` , to ensure functions you needs is enabled.
        * both for minikube or cluster, check the system pods status by `kubectl get pods -n kube-system`
          for minikube, ensure `kube-addon-manager-minikube` running. checking `kube-dns` if you need DNS(headless cluster or ingress).check `storage-provisioner` if PV/PVC involved.
          for cluster, ensure core service, `kube-proxy`,`kube-scheduler`,`etcd`,`kube-controller-manager`,`kube-apiserver` are running. and CNI plugin like `kube-flannel` also running if there're multiple minions.

---


          
---

 Q: Volume Binding Error:
```
Error:Unable to create a persistent volume with a default storage class
```
 A:Check the PVC StorageClassName aligns PV

 Q:even previous PVC deleted,  a new PVC can't claim and bind to a PV: 
```Error :    storageclass.storage.k8s.io "manual" not found``` (the manual is just a storageClassName, varies in your case)
 A: PV default recycle strategy is "Retain", even previous PVC deleted, but its data still persist , and PV still occupied. you can delete/re-create that PV.


----

Q: mysql issue in toturial : https://kubernetes.io/docs/tasks/run-application/run-single-instance-stateful-application/
ERROR 1130 (HY000): Host '10.244.1.39' is not allowed to connect to this MySQL server
A: Check https://github.com/kubernetes/website/issues/8152

-----

Q: HPA issue in toturial: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/
HPA always return unknown `   <unknown> / 50% `
A: Check my issue and resolution : https://github.com/kubernetes/website/issues/8173



