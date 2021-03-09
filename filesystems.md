### Files exist while container is exist

hostPath: on specific node

emptyDir: dynamically created location on the node (exist only as long as the pod exist on the node)

allowVolumeExpansion: true
(ability to resize volumes after they are created)
persistentVolumeReclaimPolicy: 
how can be reuseed when PV associated PVC deleted

* Retain:
keeps al data (manually clean up the data)
* Delete:
deletes the storage automatically 
* Recycle:
deletes all data, allowing the PV to be reused

```
apiVersion: v1
kind: Pod
metadata:
  name: volume-pod
spec:
  restartPolicy: Never
  containers:
  - name: busybox
    image: busybox
    command: ['sh', '-c', 'echo Success! > /output/success.txt']
    volumeMounts:
    - name: my-volume
      mountPath: /output
  volumes:
  - name: my-volume
    hostPath:
      path: /var/data

```

PVC-user request for storage
When PVC is created, it will look for a PV that is able to meet the requested criteria automatically.

You can expand PVC without interapting application
simply edit spec.resources.requests.storage

```

apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: localdisk
provisioner: kubernetes.io/no-provisioner
allowVolumeExpansion: true

---

kind: PersistentVolume
apiVersion: v1
metadata:
  name: my-pv
spec:
  storageClassName: localdisk
  persistentVolumeReclaimPolicy: Recycle
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /var/output

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  storageClassName: localdisk
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi

```