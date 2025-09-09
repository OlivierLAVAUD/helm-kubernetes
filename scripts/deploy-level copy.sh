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

# Cleanup previous deployment
helm uninstall $RELEASE_NAME 2>/dev/null || true
kubectl delete all -l app=$RELEASE_NAME 2>/dev/null || true

# Deploy new level
cd "$LEVEL_DIR"
helm install $RELEASE_NAME . \
    --wait \
    --timeout 5m \
    --create-namespace

echo "✅ Level $LEVEL deployed successfully!"
echo "📦 Resources:"
kubectl get all -l app=$RELEASE_NAME