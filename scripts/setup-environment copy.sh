#!/bin/bash
set -e

echo "🚀 Setting up Kubernetes environment..."

# Install Minikube
if ! command -v minikube &> /dev/null; then
    echo "📦 Installing Minikube..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
fi

# Install kubectl
if ! command -v kubectl &> /dev/null; then
    echo "📦 Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
fi

# Install Helm
if ! command -v helm &> /dev/null; then
    echo "📦 Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Start Minikube
echo "🔧 Starting Minikube cluster..."
minikube start --driver=docker --cpus=4 --memory=7000 --disk-size=20g

echo "✅ Environment setup completed!"
echo "📊 Cluster status:"
minikube status