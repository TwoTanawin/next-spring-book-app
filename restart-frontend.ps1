# Get all deployments in the namespace first
Write-Host "Current deployments in gogreen-app namespace:" -ForegroundColor Cyan
kubectl get deployments -n gogreen-app

# Delete and reapply the frontend service
Write-Host "`nDeleting existing frontend service..." -ForegroundColor Yellow
kubectl delete -f frontend-service.yaml -n gogreen-app
Start-Sleep -Seconds 2

Write-Host "Applying frontend service..." -ForegroundColor Yellow
kubectl apply -f frontend-service.yaml -n gogreen-app
Start-Sleep -Seconds 2

# Restart the frontend deployment
Write-Host "`nRestarting frontend deployment..." -ForegroundColor Yellow
kubectl rollout restart deployment frontend -n gogreen-app

# Watch rollout status
Write-Host "`nWatching rollout status:" -ForegroundColor Green
kubectl rollout status deployment frontend -n gogreen-app

# Verify service status
Write-Host "`nChecking service status:" -ForegroundColor Green
kubectl get svc frontend-service -n gogreen-app

# Check endpoints
Write-Host "`nChecking endpoints:" -ForegroundColor Green
kubectl get endpoints frontend-service -n gogreen-app

# Describe service
Write-Host "`nService details:" -ForegroundColor Green
kubectl describe svc frontend-service -n gogreen-app

Write-Host "`nRestart process completed!" -ForegroundColor Cyan