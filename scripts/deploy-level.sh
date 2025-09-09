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

# D'abord, supprimer la release Helm si elle existe
if helm status $RELEASE_NAME 2>/dev/null; then
    echo "🗑️  Uninstalling Helm release..."
    helm uninstall $RELEASE_NAME 2>/dev/null || true
fi

# Suppression explicite de toutes les ressources par label Helm
echo "🧹 Cleaning up leftover resources..."
kubectl delete all,ingress,serviceaccount,role,rolebinding,configmap,secret,pvc \
    -l "app.kubernetes.io/instance=$RELEASE_NAME" 2>/dev/null || true

# Suppression par nom au cas où les labels ne matchent pas
kubectl delete service $RELEASE_NAME-service 2>/dev/null || true
kubectl delete deployment $RELEASE_NAME 2>/dev/null || true
kubectl delete configmap nginx-config 2>/dev/null || true
kubectl delete configmap $RELEASE_NAME-config 2>/dev/null || true
kubectl delete ingress $RELEASE_NAME-ingress 2>/dev/null || true
kubectl delete serviceaccount simple-app-sa 2>/dev/null || true
kubectl delete role $RELEASE_NAME-role 2>/dev/null || true
kubectl delete rolebinding $RELEASE_NAME-rolebinding 2>/dev/null || true

# Attendre que la suppression soit complète
echo "⏳ Waiting for cleanup to complete..."
sleep 5

# Vérifier que tout est clean avant de déployer
echo "📋 Checking cluster status..."
RESOURCES_STILL_EXIST=false

# Vérifier les ressources courantes
if kubectl get deployment $RELEASE_NAME 2>/dev/null; then
    echo "❌ Deployment still exists, forcing deletion..."
    kubectl delete deployment $RELEASE_NAME --force --grace-period=0 2>/dev/null || true
    RESOURCES_STILL_EXIST=true
fi

if kubectl get service $RELEASE_NAME-service 2>/dev/null; then
    echo "❌ Service still exists, forcing deletion..."
    kubectl delete service $RELEASE_NAME-service --force --grace-period=0 2>/dev/null || true
    RESOURCES_STILL_EXIST=true
fi

if kubectl get serviceaccount simple-app-sa 2>/dev/null; then
    echo "❌ ServiceAccount still exists, forcing deletion..."
    kubectl delete serviceaccount simple-app-sa --force --grace-period=0 2>/dev/null || true
    RESOURCES_STILL_EXIST=true
fi

# Si des ressources existent encore, attendre un peu plus
if [ "$RESOURCES_STILL_EXIST" = true ]; then
    echo "⏳ Additional cleanup needed, waiting..."
    sleep 3
fi

# Deploy new level avec timeout étendu
echo "📦 Deploying new version with 5 minutes timeout..."
cd "$LEVEL_DIR"

# Vérifier d'abord si la chart est valide
echo "🔍 Validating chart..."
helm lint .

# Installer avec timeout et attente - CAPTURER LA SORTIE
echo "🚀 Installing Helm chart..."
if ! helm install $RELEASE_NAME . \
    --wait \
    --timeout 5m0s \
    --atomic \
    --create-namespace; then
    
    echo "❌ Helm installation failed!"
    echo "🔍 Checking for errors..."
    
    # Afficher les événements pour debug
    kubectl get events --sort-by='.lastTimestamp'
    
    # Afficher les pods en échec
    kubectl get pods --field-selector=status.phase!=Running
    
    # Afficher les logs des pods en échec
    for pod in $(kubectl get pods -l "app.kubernetes.io/instance=$RELEASE_NAME" -o name 2>/dev/null); do
        echo "📝 Logs for $pod:"
        kubectl logs $pod --tail=20 || true
    done
    
    exit 1
fi

echo "✅ Level $LEVEL deployed successfully!"
echo "📊 Deployment status:"
helm status $RELEASE_NAME

echo "📦 Resources created:"
kubectl get all,ingress,serviceaccount,role,rolebinding,configmap \
    -l "app.kubernetes.io/instance=$RELEASE_NAME" 2>/dev/null || true

echo "🐳 Pod status:"
kubectl get pods -l "app.kubernetes.io/instance=$RELEASE_NAME" -w &
PID=$!
sleep 8
kill $PID 2>/dev/null || true

echo "🔍 Detailed pod status:"
kubectl get pods -l "app.kubernetes.io/instance=$RELEASE_NAME" -o wide

echo "🎉 Deployment completed! Use 'kubectl port-forward service/$RELEASE_NAME-service 8080:80' to access the application."