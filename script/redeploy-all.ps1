# redeploy-all.ps1

# Function to check if minikube is running
function Check-MinikubeStatus {
    try {
        $status = minikube status | Select-String -Pattern "host: Running"
        if (-not $status) {
            Write-Host "Starting Minikube..." -ForegroundColor Yellow
            minikube start
        }
        else {
            Write-Host "Minikube is already running" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Error checking Minikube status: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Function to cleanup existing deployments
function Cleanup-Resources {
    Write-Host "`nCleaning up existing resources..." -ForegroundColor Yellow
    try {
        kubectl delete deployments --all -n gogreen-app
        kubectl delete services --all -n gogreen-app
        kubectl delete configmaps --all -n gogreen-app
        kubectl delete secrets --all -n gogreen-app
        kubectl delete pvc --all -n gogreen-app
        kubectl delete pv --all -n gogreen-app
        Write-Host "Cleanup completed successfully" -ForegroundColor Green
        Start-Sleep -Seconds 5
    }
    catch {
        Write-Host "Error during cleanup: $($_.Exception.Message)" -ForegroundColor Red
        throw $_
    }
}

# Function to wait for pod readiness
function Wait-ForPodReadiness {
    param (
        [string]$label,
        [int]$timeoutSeconds = 120
    )
    Write-Host "Waiting for $label pods to be ready..." -ForegroundColor Yellow
    $timer = 0
    while ($timer -lt $timeoutSeconds) {
        $pods = kubectl get pods -n gogreen-app -l app=$label -o jsonpath='{.items[*].status.phase}'
        if ($pods -eq "Running") {
            Write-Host "$label pods are ready!" -ForegroundColor Green
            return $true
        }
        Start-Sleep -Seconds 5
        $timer += 5
    }
    Write-Host "Timeout waiting for $label pods" -ForegroundColor Red
    return $false
}

# Function to apply Kubernetes manifests and check status
function Apply-Manifest {
    param (
        [string]$fileName,
        [string]$resourceType,
        [string]$namespace = "gogreen-app"
    )
    try {
        Write-Host "`nApplying $resourceType from $fileName..." -ForegroundColor Yellow
        
        if (-not (Test-Path $fileName)) {
            throw "File $fileName does not exist"
        }

        kubectl apply -f $fileName -n $namespace
        Start-Sleep -Seconds 2
        
        switch ($resourceType) {
            "deployment" {
                $deploymentName = (Get-Content $fileName | Select-String "name:") -split ":" | Select-Object -Last 1
                $deploymentName = $deploymentName.Trim()
                Write-Host "Waiting for deployment $deploymentName to roll out..." -ForegroundColor Yellow
                kubectl rollout status deployment/$deploymentName -n $namespace
            }
            "service" {
                $serviceName = (Get-Content $fileName | Select-String "name:") -split ":" | Select-Object -Last 1
                $serviceName = $serviceName.Trim()
                $service = kubectl get service $serviceName -n $namespace
                Write-Host "Service status: $service" -ForegroundColor Green
            }
        }
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Host "Error applying ${fileName}: ${errorMessage}" -ForegroundColor Red
        throw $_
    }
}

# Main redeployment script
try {
    Write-Host "Starting redeployment process..." -ForegroundColor Cyan

    # Check Minikube status
    Check-MinikubeStatus

    # Clean up existing resources
    Cleanup-Resources

    # Recreate namespace
    Write-Host "`nRecreating namespace 'gogreen-app'..." -ForegroundColor Yellow
    kubectl delete namespace gogreen-app --ignore-not-found
    Start-Sleep -Seconds 5
    kubectl create namespace gogreen-app
    kubectl config set-context --current --namespace=gogreen-app

    # Apply ConfigMap and Secrets
    Write-Host "`nDeploying ConfigMap and Secrets..." -ForegroundColor Yellow
    Apply-Manifest "configmap.yaml" "configmap"
    Apply-Manifest "secret.yaml" "secret"

    # Create storage resources
    Write-Host "`nDeploying Storage Resources..." -ForegroundColor Yellow
    Apply-Manifest "postgres-pv-pvc.yaml" "persistentvolume"

    # Deploy Database
    Write-Host "`nDeploying Database..." -ForegroundColor Yellow
    Apply-Manifest "postgres-deployment.yaml" "deployment"
    Apply-Manifest "postgres-service.yaml" "service"
    Wait-ForPodReadiness "spring-book-db"

    # Deploy Backend
    Write-Host "`nDeploying Backend..." -ForegroundColor Yellow
    Apply-Manifest "backend-deployment.yaml" "deployment"
    Apply-Manifest "backend-service.yaml" "service"
    Wait-ForPodReadiness "backend"

    # Get backend NodePort and Minikube IP
    Write-Host "`nConfiguring backend URL..." -ForegroundColor Yellow
    $MINIKUBE_IP = (minikube ip)
    $BACKEND_PORT = (kubectl get svc backend-service -n gogreen-app -o jsonpath='{.spec.ports[0].nodePort}')
    $BACKEND_URL = "http://$($MINIKUBE_IP):$($BACKEND_PORT)/api/v1"

    # Update frontend deployment with backend URL
    Write-Host "`nUpdating frontend configuration with backend URL: $BACKEND_URL" -ForegroundColor Yellow
    $frontendContent = Get-Content -Path frontend-deployment.yaml -Raw
    $frontendContent = $frontendContent -replace 'NEXT_PUBLIC_API_URL=.*', "NEXT_PUBLIC_API_URL=$BACKEND_URL"
    $frontendContent | Set-Content -Path frontend-deployment.yaml

    # Deploy Frontend
    Write-Host "`nDeploying Frontend..." -ForegroundColor Yellow
    Apply-Manifest "frontend-deployment.yaml" "deployment"
    Apply-Manifest "frontend-service.yaml" "service"
    Wait-ForPodReadiness "frontend"

    # Deploy pgAdmin
    Write-Host "`nDeploying pgAdmin..." -ForegroundColor Yellow
    Apply-Manifest "pgadmin-deployment.yaml" "deployment"
    Apply-Manifest "pgadmin-service.yaml" "service"
    Wait-ForPodReadiness "pgadmin"

    # Show service URLs
    Write-Host "`nService URLs:" -ForegroundColor Green
    Write-Host "Frontend URL: $(minikube service frontend-service --url -n gogreen-app)" -ForegroundColor Yellow
    Write-Host "Backend URL: $(minikube service backend-service --url -n gogreen-app)" -ForegroundColor Yellow
    Write-Host "pgAdmin URL: $(minikube service pgadmin-service --url -n gogreen-app)" -ForegroundColor Yellow

    # Final verification
    Write-Host "`nVerifying all resources:" -ForegroundColor Yellow
    kubectl get all -n gogreen-app

    Write-Host "`nRedeployment completed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "`nRedeployment failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}