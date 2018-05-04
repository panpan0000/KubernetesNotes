This session share the steps to using Prometheus to monitor kubernetes cluster.

# 1. Install
kube-prometheus is one of CoreOS K8S Operator, which CoreOS aims to simplify installation on K8S.
clone the code and run the script:
```
git clone https://github.com/coreos/prometheus-operator.git
cd prometheus-operator
cd contrib/kube-prometheus/
hack/cluster-monitoring/deploy
```

# 2. Check things are running 

AlertManager/Grafana/kube-state-metrics/node-export/prometheus-k8s/prometheus-operator
```
$ kubectl get pods   -n monitoring
NAME                                   READY     STATUS    RESTARTS   AGE
alertmanager-main-0                    2/2       Running   0          1d
alertmanager-main-1                    2/2       Running   0          1d
alertmanager-main-2                    2/2       Running   0          1d
grafana-56f6bbccc-gsvnq                1/1       Running   0          1d
kube-state-metrics-5bf8c78d78-9g68p    4/4       Running   0          1d
node-exporter-49vmw                    2/2       Running   0          1d
node-exporter-8v4lc                    2/2       Running   0          1d
prometheus-k8s-0                       2/2       Running   1          1d
prometheus-k8s-1                       2/2       Running   2          1d
prometheus-operator-7f8dd94bd6-9788t   1/1       Running   0          1d
```

# 3. access the dashboards
```
$ kubectl get svc  -n monitoring
NAME                    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
alertmanager-main       ClusterIP   10.105.135.68    <none>        9093/TCP            1d
alertmanager-operated   ClusterIP   None             <none>        9093/TCP,6783/TCP   1d
grafana                 NodePort    10.109.102.255   <none>        3000:31729/TCP      1d
kube-state-metrics      ClusterIP   10.103.104.186   <none>        8443/TCP,9443/TCP   1d
node-exporter           ClusterIP   10.99.151.37     <none>        9100/TCP            1d
prometheus-k8s          NodePort    10.99.59.81      <none>        9090:30690/TCP      1d
prometheus-operated     ClusterIP   None             <none>        9090/TCP            1d
prometheus-operator     ClusterIP   10.97.67.63      <none>        8080/TCP            1d
```

the `prometheus-k8s` is the Prometheus simply UI.
the `grafana` is the Grafana UI to dump Prometheus monitoring metrics.
Enjoy.
