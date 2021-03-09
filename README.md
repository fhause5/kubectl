#  kubectl

### Nerwork

* Node will remain NotReady until a network plugin is installed
* dns server in kube-system
* kubeadm use CoreDNS
* 192-168-10-100.namespaces.pod.cluster.local (without service)
* service endpoints kubectl get endpoints svc-clusterip
* service.namespaces.svc.cluster.local



### Imperative commands

```
kubectl create deployment my-deployment --image=nginx
```

### Recod the last command to annotaion

```
kubectl scale deploy nginx replicas=2 -record

```

### To issign to a specific node need write a node name or label

Deamon set
```
selector:
  matchLabel:
    app: worker

```

### Static pods, mean no K8s Api, only pod. Kubelet cretes mirror of the pod

> just a yaml in /etc/kubernetes/manifests/

### Apply whole yaml

```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  password: $(echo -n "s33msi4" | base64 -w0)
  username: $(echo -n "jane" | base64 -w0)
EOF
```


### Usecase
```
export KUBE_EDITOR="nano"

source <(kubectl completion bash)

echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc

KUBECONFIG=~/.kube/config:~/.kube/kubconfig2

kubectl api-resources

kubectl -n default get po test-nginx-ingress-controller-6bf4b4f554-nqq5g -o wide --sort-by .spec.nodeName

kubectl run busybox --image=busybox --rm -it --restart=Never -- sh

kubectl get events --all-namespaces
```

# - ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+)`Application Lifecycle Management`


```

kubectl run po nginx1 --image=nginx:1.5

kubectl create deploy nginx-deploy1 --image=nginx:1.16 --replicas=3 -n ngx -o yaml --dry-run=client > nginx1.yaml

kubectl set image deployment/nginx-deploy nginx=nginx:1.17 -n ngx

kubectl scale deployments/nginx-deploy --replicas=5 -n ngx

kubectl -n ngx rollout history deploy nginx-deploy
kubectl -n ngx rollout undo deploy nginx-deploy

```
# - ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+)`CongigMaps/Secrets`


```
kubectl -n ngx exec -it pod-busybox -- env | grep PLANET
kubectl create cm space --from-literal=planet=blue --from-literal=moon=white -n ngx

cat << EOF > system.conf
planet=red
moon=black
EOF

kubectl -n ngx cm create --from-file=system.conf

    env:
      - name: PLANET
        valueFrom:
          configMapKeyRef:
            name: space
            key: planet

    env:
      - name: USERNAME
        valueFrom:
          secretKeyRef:
            name: admin-cred
            key: username

kubectl create -n ngx secret generic admins --from-file=secrets
```
# - ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+)`Autoscaler`


```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

        - --kubelet-insecure-tls

kubectl autoscale deploy nginx --min 1 --max 5 --cpu-percent 20

siege -q -c 5 -t 2m http://kmaster:31784

stress --vm 2 --vm-bytes 200M

https://github.com/kubernetes/autoscaler.git

```

# - ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+)`Network`


```
kubectl expose deploy nginx-new --port=80 --target-port=80 --type=NodePort
kubectl expose deployment nginx --port=80 --target-port=80 --type=LoadBalancer

```
### MetalLB installation By Manifest Layer 2 Configuration

> https://metallb.universe.tf/installation/

```
kubectl get nodes -o wide
INTERNAL-IP

apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 172.42.42.101-172.42.42.110
```
# - ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+)`Scheduling`

```
# untaint master node for  Scheduling
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl label nodes kmaster.example.com kind=special

apiVersion: v1
kind: Pod
metadata:
  labels:
    run: podsel
  name: podsel
spec:
  containers:
  - image: busybox:latest
    name: podsel
    args:
      - sleep
      - "3600"
  nodeSelector:
    kind: special
```
### Use antiaffinity to launch a pod to a different node than the pod where the first one was scheduled.
```
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
              - key: run
                operator: In
                values:
                  - podsel
          topologyKey: kubernetes.io/hostname

```

### Taint a node with type=special:NoSchedule, make the other node unschedulable, and create a pod to tolerate this taint.

```
  tolerations:
  - key: "type"
    operator: "Equal"
    value: "special"
    effect: "NoSchedule"
```

```
  nodeName: k8s-worker-2```

```

# - ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+)`Security`

```

kubectl create sa lister
kubectl create role lister-role --verb=get,watch,list --resource=pods
kubectl create rolebinding lister-rolebinding --role=lister-role --serviceaccount=default:lister

apiVersion: v1
kind: Pod
metadata:
  labels:
    run: podsa
  name: podsa
spec:
  serviceAccountName: lister
  containers:
  - image: tutum/curl:latest
    name: podsa
    command: ["sleep","3600"]

kubectl exec -it podsa -- bash
# From within the pod now
API=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)

# Listing pods
curl -H "Authorization: Bearer $TOKEN" --cacert $CACERT $API/api/v1/namespaces/$NAMESPACE/pods
  "kind": "PodList",
  "apiVersion": "v1",
  "metadata": {
    "selfLink": "/api/v1/namespaces/default/pods",
    "resourceVersion": "1085753"
  },
  "items": [
    {
...

# Trying to list services is forbidden
curl -H "Authorization: Bearer $TOKEN" --cacert $CACERT $K8S/api/v1/amespaces/$NAMESPACE/service
```
### Calico


### Certificates

> Create a certificate signing request with cfssl for a user named new-admin and create a certificate through the API that it will use to authenticate, and give it the cluster-admin role.
Create a config with this user and list nodes with it.

```
wget -q --show-progress --https-only --timestamping https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
chmod +x cfssl_linux-amd64 cfssljson_linux-amd64
sudo mv cfssl_linux-amd64 /usr/local/bin/cfssl
sudo mv cfssljson_linux-amd64 /usr/local/bin/cfssljson

cat << EOF | cfssl genkey - | cfssljson -bare new-admin
{
  "CN": "new-admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "FR",
      "L": "Paris",
      "O": "system:authenticated",
      "OU": "CKA practice exercises",
      "ST": "IDF"
    }
  ]
}
EOF

cat << EOF > new-admin-csr.yml
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: new-admin-csr
spec:
  request: $(cat new-admin.csr | base64 | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - client auth
EOF

kubectl apply -f new-admin-csr.yml

# Approve the CSR through the API
kubectl certificate approve new-admin-csr

# Get the signed certificate
kubectl get csr new-admin-csr -o jsonpath='{.status.certificate}' | base64 --decode > new-admin.crt

# Create a ClusterRoleBinding for user new-admin and give cluster-admin role
kubectl create clusterrolebinding cluster-new-admin --clusterrole=cluster-admin --user=new-admin

# Create config for user new-admin
kubectl config set-credentials new-admin --client-certificate=new-admin.crt --client-key=new-admin-key.pem --embed-certs=true
kubectl config set-context new-admin@kubernetes --cluster=kubernetes --user=new-admin
kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://172.16.1.11:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
- context:
    cluster: kubernetes
    user: new-admin
  name: new-admin@kubernetes
current-context: new-admin@kubernetes
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
- name: new-admin
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED

# Use context to list nodes
kubectl config use-context new-admin@kubernetes
Switched to context "new-admin@kubernetes".

kubectl get nodes
```

### Security Context

```
spec:
  securityContext:
    runAsUser: 9001
    runAsGroup: 9002
```

# - ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+)`Monitor`

```
  containers:
  - name: nginx
    image: nginx:latest
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
    livenessProbe:
      httpGet:
        path: /
        port: 80

sudo journalctl -u kubelet

# API server
kubectl -n kube-system logs kube-apiserver-k8s-master

# Controller Manager
kubectl -n kube-system logs kube-controller-manager-k8s-master

# Scheduler
kubectl -n kube-system logs kube-scheduler-k8s-master
```

# - ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+)`Volumes`

```
echo '<body> <p>This is an example paragraph. Anything in the <strong>body</strong> tag will appear on the page, just like this <strong>p</strong> tag and its contents.</p>
</body>' > index.html

    args:
      - sleep
      - "3600"
    volumeMounts:
    - name: data
      mountPath: "/data"
  volumes:
  - name: data
    hostPath:
      path: "/home/ubuntu/data/"

```

# - ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+)`ETCD Buckup`

```
kubectl exec -it -n kube-system etcd-k8s-master -- etcd --version
etcd Version: 3.4.3
Git SHA: 3cf2f69b5
Go Version: go1.12.12
Go OS/Arch: linux/amd64
# Download etcd client
wget https://github.com/etcd-io/etcd/releases/download/v3.4.3/etcd-v3.4.3-linux-amd64.tar.gz
tar xzvf etcd-v3.4.3-linux-amd64.tar.gz
sudo mv etcd-v3.4.3-linux-amd64/etcdctl /usr/local/bin

# save etcd snapshot
sudo ETCDCTL_API=3 etcdctl snapshot save --endpoints=172.16.1.11:2379 snapshot.db --cacert /etc/kubernetes/pki/etcd/server.crt --cert /etc/kubernetes/pki/etcd/ca.crt --key /etc/kubernetes/pki/etcd/ca.key

# View the snapshot
ETCDCTL_API=3 sudo etcdctl --write-out=table snapshot status snapshot.db
+----------+----------+------------+------------+
|   HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+----------+----------+------------+------------+
| b72a6b6e |    34871 |       1430 |     3.3 MB |
+----------+----------+------------+------------+

```

### Restore

> https://github.com/etcd-io/etcd/blob/master/Documentation/op-guide/recovery.md#restoring-a-cluster