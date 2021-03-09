### troubleshooting

#### Api server is down on master
> The connection to the server localhost:6343 was refused

* check docker is running
* check kubelet is runningS
* check k8s congfig

Check the logs for the Kube API Server:

kubectl logs -n kube-system <KUBE-APISERVER_POD_NAME>

### Detect logs in container
sudo journalctl -u kubelet
kubectl -n kube-system logs kube-apiserver-kmaster.example.com

less /var/log/kube-apiserver.log
less /var/log/kube-scheduler.log
less /var/log/kube-controller-manager.log

### Troubleshooting a pod
kubectl exec troubleshooting-pod -c busybox --stdin --tty -- /bin/sh

### Troubleshooting K8s Networking Issues

image nicolaka/netshoot

```
apiVersion: v1
kind: Pod
metadata:
  name: netshoot
spec:
  containers:
  - name: netshoot
    image: nicolaka/netshoot
    command: ['sh', '-c', 'while true; do sleep 5; done']
```