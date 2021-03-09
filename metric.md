### Check metrics

### Install 
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl top po --sort-by <>

kubectl top po --sort-by cpu
kubectl top po --selector app=nginx