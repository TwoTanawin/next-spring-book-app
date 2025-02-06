# deploy.ps1

# Function to check if minikube is running
function Check-MinikubeStatus {
    $status = minikube status | Select-String -Pattern "host: Running"
    if (-not $status) {
        Write-Host "Starting Minikube..."
        minikube start
    }
    else {
        Write-Host "Minikube is already running"
    }
}

# Function to delete Kubernetes resources
function Delete-Resources {
    Write-Host "`nCleaning up resources..."
    
    # Delete all services
    kubectl delete service --all -n gogreen-app
    
    # Delete all deployments
    kubectl delete deployment --all -n gogreen-app
    
    # Delete persistent volumes and claims
    kubectl delete pvc --all -n gogreen-app
    kubectl delete pv --all
    
    # Delete configmaps and secrets
    kubectl delete configmap --all -n gogreen-app
    kubectl delete secret --all -n gogreen-app
    
    # Delete namespace
    kubectl delete namespace gogreen-app
    
    Write-Host "All resources deleted successfully!" -ForegroundColor Green
}

# Main script
Write-Host "Starting cleanup process..."

# Check Minikube status
Check-MinikubeStatus

# Delete all resources
Delete-Resources