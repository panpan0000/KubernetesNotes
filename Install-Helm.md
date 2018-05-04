This session will provide the steps how to install `Helm`. It's like `apt-get` for Kubernetes.

# 1. Download Helm binary
  Download from https://github.com/kubernetes/helm/releases,  put into your `/usr/local/bin`
  Helm runs as a binary in your K8S master node( just like kubectl)

# 2. Install Tiller 
  Tiller is the server side of Helm. it runs as a few Kubernetes pods.
```
helm init --service-account tiller --skip-refresh
```
Note: `--service-account tiller` will help to create a account, it will be useful for later RBAC.


Messages will show up 
```
Creating /home/rackhd/.helm
Creating /home/rackhd/.helm/repository
Creating /home/rackhd/.helm/repository/cache
Creating /home/rackhd/.helm/repository/local
Creating /home/rackhd/.helm/plugins
Creating /home/rackhd/.helm/starters
Creating /home/rackhd/.helm/cache/archive
Creating /home/rackhd/.helm/repository/repositories.yaml
Adding stable repo with URL: https://kubernetes-charts.storage.googleapis.com
Adding local repo with URL: http://127.0.0.1:8879/charts
$HELM_HOME has been configured at /home/rackhd/.helm.

Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.

Please note: by default, Tiller is deployed with an insecure 'allow unauthenticated users' policy.
For more information on securing your installation see: https://docs.helm.sh/using_helm/#securing-your-helm-installation
```

Then check if `tiller-deploy-xxx` exists and running by `kubectl get pods -n kube-system`



# 3. Tiller Account !!
NOTE, K8S 1.10 enables RBAC, so we should create account for Tiller, and bind it to cluster-admin role
create a file `helm.rbac.config.yaml` with below content:
```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
```

Then run `kubectl create -f helm.rbac.config.yaml`


# 4.  Update Local Repo
```helm repo update```
it equals to "apt-get update" in Ubuntu

# 5. install something
like `helm install stable/nginx-ingress` to install `nginx-ingress` chart.

# 6. list charts
`helm ls` to check what chart(similar to package concept) in your cluster.

# 7. delete package
`helm delete my-release` to delete a package.

