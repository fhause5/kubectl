#  kubectl


### Usecase 

export KUBE_EDITOR="nano"

source <(kubectl completion bash)

echo "source <(kubectl completion bash)" >> ~/.bashrc

KUBECONFIG=~/.kube/config:~/.kube/kubconfig2

### Application Lifecycle Management

```

kubectl run po nginx1 --image=nginx:1.5

kubectl create deploy nginx-deploy1 --image=nginx:1.16 --replicas=3 -n ngx -o yaml --dry-run=client > nginx1.yaml

kubectl set image deployment/nginx-deploy nginx=nginx:1.17 -n ngx

kubectl scale deployments/nginx-deploy --replicas=5 -n ngx

kubectl -n ngx rollout history deploy nginx-deploy
kubectl -n ngx rollout undo deploy nginx-deploy

```

### CongigMaps/Secrets

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

### POD autoscaler

> https://aws.amazon.com/premiumsupport/knowledge-center/eks-metrics-server-pod-autoscaler/


### Network

```
kubectl expose deploy nginx-new --port=80 --target-port=80 --type=NodePort

```
