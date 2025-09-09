🚀 Helm Kubernetes Learning Project

Un guide progressif pour maîtriser le déploiement d'applications sur Kubernetes avec Helm, de la configuration basique à l'architecture de production


📋 Table des Matières

    Présentation du Projet
    Architecture des Niveaux
    Prérequis
    Installation
    Utilisation
    Détails des Niveaux
    Best Practices Implementées
    Commandes Utiles
    Dépannage
    Contribuer
    Licence

🎯 Présentation du Projet

Ce projet est conçu pour apprendre progressivement Helm et Kubernetes à travers 5 niveaux de complexité croissante :

    Niveau 01 : Application basique Nginx
    Niveau 02 : Configuration externalisée avec ConfigMaps
    Niveau 03 : Auto-scaling avec HPA
    Niveau 04 : Haute disponibilité
    Niveau 05 : Sécurité renforcée

Chaque niveau ajoute de nouvelles fonctionnalités tout en respectant les best practices Kubernetes


🏗️ Architecture des Niveaux

```bash
helm-kubernetes/
├── 01-basic-setup/          # Déploiement basique
├── 02-with-configmaps/      # Configuration externalisée
├── 03-with-autoscaling/     # Auto-scaling horizontal
├── 04-with-high-availability/ # Architecture HA
├── 05-with-security/        # Sécurité renforcée
├── scripts/
│   └── deploy-level.sh      # Script de déploiement
└── README.md
```

⚙️ Prérequis

    Kubernetes Cluster : Minikube, Kind, ou cluster cloud
    Helm v3.8+ : Installation guide
    kubectl : Client Kubernetes
    Git : Version control

Vérification de l'installation

```bash
# Vérifier Kubernetes
kubectl version --client
minikube version

# Vérifier Helm
helm version

# Vérifier le cluster
kubectl cluster-info
kubectl get nodes
```

🚀 Installation

    Cloner le repository :
```bash
git clone https://github.com/votre-username/helm-kubernetes.git
cd helm-kubernetes
```
    Démarrer Minikube (si utilisé) :

```bash
git clone https://github.com/votre-username/helm-kubernetes.git
cd helm-kubernetes
```

```bash
./scripts/check-environment.sh
```





## 🚀 Quick Start

```bash
chmod +x setup-environement.sh
chmod +x deploy-level.sh

# Setup environment
./scripts/setup-environment.sh

# Deploy level xx: ./scripts/deploy-level.sh <xx>

# Déployer un niveau spécifique
./scripts/deploy-level.sh 00  # Niveau basique
./scripts/deploy-level.sh 01  # Niveau Ingress
./scripts/deploy-level.sh 02  # Avec ConfigMaps
./scripts/deploy-level.sh 03  # Avec auto-scaling
./scripts/deploy-level.sh 04  # Haute disponibilité
./scripts/deploy-level.sh 05  # Sécurité renforcée

# exception pour 05

cd 05-with-security/
helm install my-app-secure . --timeout 5m0s
```

# Surveillance du Déploiement

```bash
# Voir les pods
kubectl get pods -w

# Voir les services
kubectl get services

# Voir les deployments
kubectl get deployments

# Voir les logs
kubectl logs -f deployment/my-app
```
# Access application
```bash
# Port-forward pour accéder à l'application
kubectl port-forward service/my-app-service 8080:80

# Ouvrir dans le navigateur
curl http://localhost:8080
# ou ouvrir http://localhost:8080
```

## 📊 Verification
```bash
# Voir les pods
kubectl get pods -w

# Voir les services
kubectl get services

# Voir les deployments
kubectl get deployments

# Voir les logs
kubectl logs -f deployment/my-app

# Monitor resources
kubectl get all --watch

# See the  namespace state
kubectl get all --all-namespaces
```

## 🧹 Cleanup

```bash
./scripts/cleanup-cluster.sh
```

# ✅ Best Practices Implementées
🔧 Configuration

    Externalisation : ConfigMaps pour la configuration
    Variables d'environnement : Values.yaml pour la customisation
    Templating : Helpers réutilisables

🚀 Déploiement

    Rolling updates : Mises à jour sans downtime
    Health checks : Liveness/readiness probes
    Resource limits : CPU/memory limits et requests

🛡️ Sécurité

    Least privilege : RBAC avec permissions minimales
    Non-root execution : Containers sans privilèges
    Read-only filesystems : Système de fichiers en lecture seule
    Network policies : Isolation réseau

📈 Monitoring

    Metrics : Exposition des métriques
    Logging : Configuration des logs
    Auto-scaling : Adaptation à la charge

## 🛠️ Commandes Utiles
### Commandes Helm
```bash
# Lister les releases
helm list

# Status d'une release
helm status my-app

# Historique des revisions
helm history my-app

# Rollback
helm rollback my-app 1

# Désinstaller
helm uninstall my-app
```

### Commandes Kubernetes
```bash
# Voir tous les ressources
kubectl get all -l app.kubernetes.io/instance=my-app

# Voir les events
kubectl get events --sort-by='.lastTimestamp'

# Voir les logs
kubectl logs -f deployment/my-app

# Debug pod
kubectl describe pod my-app-xyz

# Accéder au container
kubectl exec -it my-app-xyz -- sh

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
```

### Commandes de Debug
```bash
# Dry-run Helm
helm install my-app . --dry-run --debug

# Lint chart
helm lint .

# Template debugging
helm template my-app . --debug

```

### 🐛 Dépannage

```bash
# Erreurs de déploiement :
# Voir les events
kubectl get events

# Voir les pods en échec
kubectl get pods --field-selector=status.phase!=Running

# Logs des pods
kubectl logs <pod-name>

# Problemes de ressources
# Voir l'utilisation des ressources
kubectl top pods
kubectl top nodes

# Voir les resource quotas
kubectl describe resourcequotas

# Problemes de réseau
# Debug réseau
kubectl run debug --image=busybox --rm -it -- sh

# Test DNS
nslookup my-app-service

```


