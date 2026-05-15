#!/usr/bin/env bash
set -euo pipefail

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -n argocd   -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl wait deployment   -n argocd   argocd-server   --for condition=Available=True   --timeout=300s

kubectl apply -f bootstrap/root-app.yaml
