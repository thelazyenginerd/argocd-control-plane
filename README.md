# ArgoCD Control Plane

GitOps-based Kubernetes control plane using:

- ArgoCD App-of-Apps
- MinIO
- StackGres
- Crossplane

## Bootstrap

```bash
kind create cluster --config bootstrap/kind-config.yaml

./bootstrap/install-argocd.sh
```
