### k8s probes

By default k8s will only consider a container
to be "down" if the container process stops
liveness probes can customize the detection

* container health
ability to automatically restart unhealthy containers

* liveness probes
kubelet usus kubelet

```
    livenessProbe:
        exec: 
          command: ["echo", "Hello, World!"]
        initialDelaySeconds: 5
        peridSeconds: 5
```

* startup probes
Simular to liveness probes, once
especially for long sturtup times

```
    sturtupProbe:
        httpGet: 
          path: /
          port: 80
        failureThreshold: 30
        periodSeconds: 10

```

* readiness probes
* Hands-On Demonstration

### Restart policy: Always, OnFailure, Never

