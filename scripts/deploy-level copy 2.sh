#!/bin/bash
set -e

LEVEL=$1
RELEASE_NAME="my-app"

if [ -z "$LEVEL" ]; then
    echo "❌ Usage: $0 <level-number>"
    exit 1
fi

# Trouver le répertoire du niveau
LEVEL_DIR=$(find . -maxdepth 1 -name "${LEVEL}-*" -type d)
if [ -z "$LEVEL_DIR" ]; then
    echo "❌ Level $LEVEL not found"
    echo "📁 Available levels:"
    find . -maxdepth 1 -name "*-*" -type d | sort
    exit 1
fi

echo "🚀 Deploying level $LEVEL from $LEVEL_DIR..."

# Cleanup complet des ressources précédentes
echo "🧹 Cleaning up previous deployment..."
helm uninstall $RELEASE_NAME 2>/dev/null || true

# Suppression explicite de toutes les ressources possibles
kubectl delete all -l app=$RELEASE_NAME 2>/dev/null || true
kubectl delete configmap -l app=$RELEASE_NAME 2>/dev/null || true
kubectl delete ingress -l app=$RELEASE_NAME 2>/dev/null || true
kubectl delete secret -l app=$RELEASE_NAME 2>/dev/null || true
kubectl delete pvc -l app=$RELEASE_NAME 2>/dev/null || true

# Suppression par nom au cas où les labels ne matchent pas
kubectl delete service $RELEASE_NAME-service 2>/dev/null || true
kubectl delete deployment $RELEASE_NAME 2>/dev/null || true
kubectl delete configmap $RELEASE_NAME-config 2>/dev/null || true
kubectl delete ingress $RELEASE_NAME-ingress 2>/dev/null || true

# Attendre que la suppression soit complète
sleep 3

# Vérifier que tout est clean avant de déployer
echo "📋 Checking cluster status..."
if kubectl get deployment $RELEASE_NAME 2>/dev/null; then
    echo "❌ Deployment still exists, forcing deletion..."
    kubectl delete deployment $RELEASE_NAME --force --grace-period=0 2>/dev/null || true
fi

if kubectl get service $RELEASE_NAME-service 2>/dev/null; then
    echo "❌ Service still exists, forcing deletion..."
    kubectl delete service $RELEASE_NAME-service --force --grace-period=0 2>/dev/null || true
fi

# Deploy new level
echo "📦 Deploying new version..."
cd "$LEVEL_DIR"
helm install $RELEASE_NAME . \
    --wait \
    --timeout 5m \
    --create-namespace

echo "✅ Level $LEVEL deployed successfully!"
echo "📊 Deployment status:"
helm status $RELEASE_NAME

echo "📦 Resources created:"
kubectl get all -l app=$RELEASE_NAME
kubectl get configmap -l app=$RELEASE_NAME 2>/dev/null || true
kubectl get ingress -l app=$RELEASE_NAME 2>/dev/null || true

echo "🐳 Pod status:"
kubectl get pods -l app=$RELEASE_NAME -w &
PID=$!
sleep 5
kill $PID 2>/dev/null

echo "🎉 Deployment completed! Use 'kubectl port-forward service/my-app-service 8080:80' to access the application."