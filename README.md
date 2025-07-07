# kubernetes-website-50859
https://github.com/kubernetes/website/issues/50859 repro

```console
kubectl version
```

```
Client Version: v1.33.2
Kustomize Version: v5.6.0
Server Version: v1.33.1
```

## Reproducing the issue

1. First apply `combined.yaml`
   ```console
   kubectl apply -f combined.yaml
   ```
1. Then, when you're ready for the init containers to finish/start, apply `services.yaml`:
   ```console
   kubectl apply -f services.yaml
   ```

To reproduce the order docs bug (assuming only one running pod in the cluster):

```console
export POD=$(kubectl get pods | tail -1 | cut -d ' ' -f 1)
```

```console
kubectl delete pod $POD
```

In a separate terminal (there are a few dozens of seconds available as time window) - assuming deletion hasn't yet been done:

```console
kubectl describe pod $POD  # execute this after POD has been exported prior to deletion, and once deletion started
```

### Example output from `describe` example

Note last two lines (stopping container).

```console
describe pod myapp-5b58484b75-5vrcs 
```

```
Name:             myapp-5b58484b75-5vrcs
Namespace:        default
Priority:         0
Service Account:  default
Node:             minikube/192.168.49.2
Start Time:       Mon, 07 Jul 2025 11:37:38 +0100
Labels:           app=myapp
                  pod-template-hash=5b58484b75
Annotations:      <none>
Status:           Succeeded
IP:               10.244.0.6
IPs:
  IP:           10.244.0.6
Controlled By:  ReplicaSet/myapp-5b58484b75
Init Containers:
  init-myservice:
    Container ID:  docker://016bb99733fead90cc049e5a7d3b76192b22fbc3cc28bad9abe0b74dcf7e4265
    Image:         busybox:1.28
    Image ID:      docker-pullable://busybox@sha256:141c253bc4c3fd0a201d32dc1f493bcf3fff003b6df416dea4f41046e0f37d47
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      until nslookup myservice.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for myservice; sleep 2; done
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Mon, 07 Jul 2025 11:37:39 +0100
      Finished:     Mon, 07 Jul 2025 11:37:39 +0100
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-88zm2 (ro)
  init-mydb:
    Container ID:  docker://8cd66e933e3c8bde622531d5467d04dd717874ff5072e57312d3a62261e56e81
    Image:         busybox:1.28
    Image ID:      docker-pullable://busybox@sha256:141c253bc4c3fd0a201d32dc1f493bcf3fff003b6df416dea4f41046e0f37d47
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      until nslookup mydb.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for mydb; sleep 2; done
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Mon, 07 Jul 2025 11:37:40 +0100
      Finished:     Mon, 07 Jul 2025 11:37:40 +0100
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-88zm2 (ro)
  logshipper:
    Container ID:  docker://74119cc955c702062a5b76fc9d26e9c6394050e33858b32c4f8f8156b8923344
    Image:         alpine:latest
    Image ID:      docker-pullable://alpine@sha256:8a1f59ffb675680d47db6337b49d22281a139e9d709335b492be023728e11715
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      tail -F /opt/logs.txt
    State:          Terminated
      Reason:       Error
      Exit Code:    137
      Started:      Mon, 07 Jul 2025 11:37:42 +0100
      Finished:     Mon, 07 Jul 2025 11:43:22 +0100
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /opt from data (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-88zm2 (ro)
Containers:
  myapp:
    Container ID:   docker://4b4b72ea4f37e26d4577c343e838fd55118729f4caa1f385e41012f7bd5fafca
    Image:          algheglobal/k8scontainers:1.0
    Image ID:       docker-pullable://algheglobal/k8scontainers@sha256:ea582a0b560d482fad3ccbc12c42e658de78ec91e2ec2f3e4e08a74cc7761cbd
    Port:           <none>
    Host Port:      <none>
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Mon, 07 Jul 2025 11:37:43 +0100
      Finished:     Mon, 07 Jul 2025 11:43:02 +0100
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /opt from data (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-88zm2 (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   False 
  Initialized                 True 
  Ready                       False 
  ContainersReady             False 
  PodScheduled                True 
Volumes:
  data:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:     
    SizeLimit:  <unset>
  kube-api-access-88zm2:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  5m44s  default-scheduler  Successfully assigned default/myapp-5b58484b75-5vrcs to minikube
  Normal  Pulled     5m44s  kubelet            Container image "busybox:1.28" already present on machine
  Normal  Created    5m44s  kubelet            Created container: init-myservice
  Normal  Started    5m44s  kubelet            Started container init-myservice
  Normal  Pulled     5m43s  kubelet            Container image "busybox:1.28" already present on machine
  Normal  Created    5m43s  kubelet            Created container: init-mydb
  Normal  Started    5m43s  kubelet            Started container init-mydb
  Normal  Pulling    5m42s  kubelet            Pulling image "alpine:latest"
  Normal  Pulled     5m41s  kubelet            Successfully pulled image "alpine:latest" in 1.431s (1.431s including waiting). Image size: 8309109 bytes.
  Normal  Created    5m41s  kubelet            Created container: logshipper
  Normal  Started    5m41s  kubelet            Started container logshipper
  Normal  Pulled     5m40s  kubelet            Container image "algheglobal/k8scontainers:1.0" already present on machine
  Normal  Created    5m40s  kubelet            Created container: myapp
  Normal  Started    5m40s  kubelet            Started container myapp
  Normal  Killing    31s    kubelet            Stopping container logshipper
  Normal  Killing    31s    kubelet            Stopping container myapp
```
