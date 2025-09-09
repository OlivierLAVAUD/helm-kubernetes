#!/bin/bash
set -e

RELEASE_NAME="my-app"
NAMESPACE="default"
TIMEOUT=180  # 3 minutes timeout for verification
INTERVAL=10  # Check every 10 seconds

echo "🔍 Starting verification for release: $RELEASE_NAME"

# Function to check if all pods are running
check_pods() {
    echo "📦 Checking pod status..."
    local attempts=0
    while [ $attempts -lt $(($TIMEOUT/$INTERVAL)) ]; do
        local pod_status=$(kubectl get pods -l app.kubernetes.io/instance=$RELEASE_NAME -o jsonpath='{range .items[*]}{.status.phase}{"\n"}{end}' | uniq)
        local ready_pods=$(kubectl get pods -l app.kubernetes.io/instance=$RELEASE_NAME --no-headers | grep -c "Running")
        local total_pods=$(kubectl get pods -l app.kubernetes.io/instance=$RELEASE_NAME --no-headers | wc -l)
        
        if [ "$ready_pods" -eq "$total_pods" ] && [ "$total_pods" -gt 0 ]; then
            echo "✅ All pods ($total_pods) are running"
            return 0
        fi
        echo "⏳ Pods ready: $ready_pods/$total_pods"
        sleep $INTERVAL
        attempts=$((attempts+1))
    done
    echo "❌ Pods not ready after $TIMEOUT seconds"
    return 1
}

# Function to check deployment status
check_deployment() {
    echo "📋 Checking deployment status..."
    if kubectl rollout status deployment/$RELEASE_NAME --timeout=${TIMEOUT}s; then
        echo "✅ Deployment successful"
        return 0
    else
        echo "❌ Deployment failed"
        kubectl describe deployment/$RELEASE_NAME
        return 1
    fi
}

# Function to check service status
check_service() {
    echo "🌐 Checking service status..."
    local service_name="${RELEASE_NAME}-service"
    if kubectl get service $service_name > /dev/null 2>&1; then
        echo "✅ Service $service_name created"
        return 0
    else
        echo "❌ Service $service_name not found"
        return 1
    fi
}

# Function to check ingress status
check_ingress() {
    echo "🚪 Checking ingress status..."
    local ingress_name="${RELEASE_NAME}-ingress"
    if kubectl get ingress $ingress_name > /dev/null 2>&1; then
        echo "✅ Ingress $ingress_name created"
        return 0
    else
        echo "ℹ️  Ingress not found (may be disabled)"
        return 0
    fi
}

# Function to check configmap status
check_configmap() {
    echo "📝 Checking configmap status..."
    local configmap_name="nginx-config"
    if kubectl get configmap $configmap_name > /dev/null 2>&1; then
        echo "✅ ConfigMap $configmap_name created"
        return 0
    else
        echo "ℹ️  ConfigMap not found (may be disabled)"
        return 0
    fi
}

# Function to check HPA status
check_hpa() {
    echo "📊 Checking HPA status..."
    local hpa_name="${RELEASE_NAME}-hpa"
    if kubectl get hpa $hpa_name > /dev/null 2>&1; then
        echo "✅ HPA $hpa_name created"
        kubectl describe hpa $hpa_name
        return 0
    else
        echo "ℹ️  HPA not found (may be disabled)"
        return 0
    fi
}

# Function to check PDB status
check_pdb() {
    echo "🛡️  Checking PDB status..."
    local pdb_name="${RELEASE_NAME}-pdb"
    if kubectl get pdb $pdb_name > /dev/null 2>&1; then
        echo "✅ PDB $pdb_name created"
        return 0
    else
        echo "ℹ️  PDB not found (may be disabled)"
        return 0
    fi
}

# Function to check RBAC status
check_rbac() {
    echo "🔐 Checking RBAC status..."
    local sa_name="simple-app-sa"
    if kubectl get serviceaccount $sa_name > /dev/null 2>&1; then
        echo "✅ ServiceAccount $sa_name created"
        
        # Check role and rolebinding
        local role_name="${RELEASE_NAME}-role"
        local rolebinding_name="${RELEASE_NAME}-rolebinding"
        
        if kubectl get role $role_name > /dev/null 2>&1; then
            echo "✅ Role $role_name created"
        fi
        
        if kubectl get rolebinding $rolebinding_name > /dev/null 2>&1; then
            echo "✅ RoleBinding $rolebinding_name created"
        fi
        
        return 0
    else
        echo "ℹ️  ServiceAccount not found (may be disabled)"
        return 0
    fi
}

# Function to check network policy status
check_network_policy() {
    echo "🌐 Checking network policy status..."
    local networkpolicy_name="${RELEASE_NAME}-networkpolicy"
    if kubectl get networkpolicy $networkpolicy_name > /dev/null 2>&1; then
        echo "✅ NetworkPolicy $networkpolicy_name created"
        return 0
    else
        echo "ℹ️  NetworkPolicy not found (may be disabled)"
        return 0
    fi
}

# Function to test application accessibility
test_application() {
    echo "🚀 Testing application accessibility..."
    local service_name="${RELEASE_NAME}-service"
    
    # Try port-forwarding
    kubectl port-forward service/$service_name 8080:80 &
    local pf_pid=$!
    sleep 3
    
    if curl -s http://localhost:8080/health > /dev/null 2>&1; then
        echo "✅ Application is accessible and healthy"
        kill $pf_pid 2>/dev/null
        return 0
    else
        echo "❌ Application is not accessible"
        kill $pf_pid 2>/dev/null
        return 1
    fi
}

# Main verification process
echo "🔍 Starting comprehensive verification..."
check_pods
check_deployment
check_service
check_ingress
check_configmap
check_hpa
check_pdb
check_rbac
check_network_policy
test_application

echo "✅ Verification completed successfully!"
echo "📊 Final status:"
kubectl get all,ingress,serviceaccount,role,rolebinding,configmap,pdb,hpa,networkpolicy -l app.kubernetes.io/instance=$RELEASE_NAME