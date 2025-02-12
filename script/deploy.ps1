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

# Function to apply Kubernetes manifests and check status
function Apply-Manifest {
    param (
        [string]$fileName,
        [string]$resourceType
    )
    Write-Host "`nApplying $resourceType..."
    kubectl apply -f $fileName
    
    # Wait for a moment to let the resource create
    Start-Sleep -Seconds 2
    
    # Check status based on resource type
    switch ($resourceType) {
        "deployment" {
            $deploymentName = (kubectl get deployment -o json | ConvertFrom-Json).items.metadata.name | Select-Object -Last 1
            kubectl rollout status deployment/$deploymentName
        }
        "service" {
            $serviceName = (kubectl get service -o json | ConvertFrom-Json).items.metadata.name | Select-Object -Last 1
            kubectl get service $serviceName
        }
    }
}

# Main deployment script
Write-Host "Starting deployment process..."

# Check Minikube status
Check-MinikubeStatus

# Create and set namespace
Write-Host "`nCreating and setting namespace 'gogreen-app'..."
kubectl create namespace gogreen-app --dry-run=client -o yaml | kubectl apply -f -
kubectl config set-context --current --namespace=gogreen-app

# Apply ConfigMap and Secrets
Write-Host "`nDeploying ConfigMap and Secrets..."
Apply-Manifest "configmap.yaml" "configmap"
Apply-Manifest "secret.yaml" "secret"

# Create storage resources
Write-Host "`nDeploying Storage Resources..."
Apply-Manifest "postgres-pv-pvc.yaml" "persistentvolume"

# Deploy Database
Write-Host "`nDeploying Database..."
Apply-Manifest "postgres-deployment.yaml" "deployment"
Apply-Manifest "postgres-service.yaml" "service"

# Wait for database to be ready
Write-Host "`nWaiting for database to be ready..."
Start-Sleep -Seconds 10

# Deploy Backend
Write-Host "`nDeploying Backend..."
Apply-Manifest "backend-deployment.yaml" "deployment"
Apply-Manifest "backend-service.yaml" "service"

# Deploy Frontend
Write-Host "`nDeploying Frontend..."
Apply-Manifest "frontend-deployment.yaml" "deployment"
Apply-Manifest "frontend-service.yaml" "service"

# Deploy pgAdmin
Write-Host "`nDeploying pgAdmin..."
Apply-Manifest "pgadmin-deployment.yaml" "deployment"
Apply-Manifest "pgadmin-service.yaml" "service"

# Get service URLs
Write-Host "`nGetting service URLs..."
Write-Host "Frontend URL:" -ForegroundColor Green
minikube service frontend-service -n gogreen-app --url
Write-Host "pgAdmin URL:" -ForegroundColor Green
minikube service pgadmin-service -n gogreen-app --url

Write-Host "`nDeployment completed!" -ForegroundColor Green