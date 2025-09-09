#!/bin/bash
set -e

echo "🚀 Setting up Kubernetes environment..."

# Vérifier et installer Minikube si nécessaire
if ! command -v minikube &> /dev/null; then
    echo "📦 Installing Minikube..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
    echo "✅ Minikube installed"
else
    echo "✅ Minikube is already installed"
fi

# Vérifier et installer kubectl si nécessaire
if ! command -v kubectl &> /dev/null; then
    echo "📦 Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    echo "✅ kubectl installed"
else
    echo "✅ kubectl is already installed"
fi

# Vérifier et installer Helm si nécessaire
if ! command -v helm &> /dev/null; then
    echo "📦 Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    echo "✅ Helm installed"
else
    echo "✅ Helm is already installed"
fi

# Démarrer Minikube
echo "🔧 Starting Minikube cluster..."
if ! minikube status | grep -q "Running"; then
    minikube start --driver=docker --cpus=2 --memory=4096 --disk-size=10g
    echo "✅ Minikube cluster started"
else
    echo "✅ Minikube cluster is already running"
fi

# Configurer l'environnement Docker pour Minikube
echo "🐳 Setting up Docker environment..."
eval $(minikube docker-env)

# Vérifier que tout fonctionne
echo "📊 Verification..."
minikube status
kubectl cluster-info
helm version

echo "🎉 Environment setup completed successfully!"
echo "➡️ Next step: Run './scripts/deploy-level.sh 0' to deploy level 0"
