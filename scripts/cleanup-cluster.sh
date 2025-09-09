#!/bin/bash
set -e

echo "🧹 Cleaning up Kubernetes cluster..."

# Delete all releases
helm list --all-namespaces -q | xargs -n1 helm uninstall -n 2>/dev/null || true

# Delete all resources in default namespace
kubectl delete all --all -n default 2>/dev/null || true
kubectl delete configmap --all -n default 2>/dev/null || true
kubectl delete ingress --all -n default 2>/dev/null || true
kubectl delete pvc --all -n default 2>/dev/null || true

# Delete namespaces
kubectl get namespaces --no-headers -o custom-columns=:metadata.name | \
    grep -E "(my-app|monitoring|logging)" | \
    xargs -n1 kubectl delete namespace 2>/dev/null || true

echo "✅ Cluster cleanup completed!"