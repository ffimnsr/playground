Expose deployment to load balancer service

```
kubectl expose deployment <deployment-name> --type=LoadBalancer --name=<service-name> --port=<port> --target-port=<target-port>
```
