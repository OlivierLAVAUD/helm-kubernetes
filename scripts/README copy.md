# 🚀 Helm Kubernetes Mastery Journey

A comprehensive learning path from Kubernetes beginner to Helm expert through progressive levels of complexity.

## 📚 Learning Path

### Level 0: Simple Application
- Basic Helm chart structure
- Single container deployment
- Service exposure

### Level 1: With Ingress
- Ingress controller setup
- DNS configuration
- External access

### Level 2: With ConfigMaps
- Configuration management
- Health checks implementation
- Configuration decoupling

### Level 3: With Auto-scaling
- Horizontal Pod Autoscaler
- Resource-based scaling
- Scaling policies

### Level 4: Full-Stack Application
- Multi-container deployment
- Service discovery
- Database integration

### Level 5: With Monitoring
- Prometheus integration
- Metrics exposure
- Monitoring setup

## 🛠️ Prerequisites

- Docker
- Minikube
- kubectl
- Helm

## 🚀 Quick Start

```bash
chmod +x setup-environement.sh
chmod +x verify-deployment.sh
chmod +x cleanup-cluster.sh
chmod +x deploy-level.sh

# Setup environment
./scripts/setup-environment.sh

# Deploy level 0
./scripts/deploy-level.sh 00

# Access application
kubectl port-forward service/my-app-service 8080:80

## 📊 Verification

bash

# Check deployment status
./scripts/verify-deployment.sh

# View logs
kubectl logs -f deployment/my-app

# Monitor resources
kubectl get all --watch

## 🧹 Cleanup

# Clean entire cluster
./scripts/cleanup-cluster.sh

# Delete Minikube
minikube delete

## 📝 License

MIT License - feel free to use this for learning and production deployments!

## 🤝 Contributing

Contributions are welcome! Please read the contributing guidelines first.



# test 02
# Supprimer les ressources manuellement
kubectl delete service my-app-service --ignore-not-found
kubectl delete deployment my-app --ignore-not-found
kubectl delete configmap my-app-config --ignore-not-found
kubectl delete ingress my-app-ingress --ignore-not-found 2>/dev/null || true

# Vérifier que tout est clean
kubectl get all
kubectl get configmap

# Maintenant réinstaller
cd 02-with-configmaps
helm install my-app ./


# Big Clean Up
# Methode nucleaire

# Redémarrer complètement Minikube
minikube stop
minikube delete
minikube start --driver=docker --cpus=2 --memory=4096

# Attendre que le cluster soit ready
kubectl cluster-info

# Maintenant déployer proprement
cd 02-with-configmaps
helm install my-app ./

# Verifications
# Voir les ressources existantes
kubectl get all

# Voir les events pour comprendre le problème
kubectl get events --sort-by=.metadata.creationTimestamp

# Voir l'état du namespace
kubectl get all --all-namespaces