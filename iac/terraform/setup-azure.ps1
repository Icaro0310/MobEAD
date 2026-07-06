# Configurar variÃ¡veis de ambiente para Azure
# Execute estes comandos no PowerShell antes de rodar terraform

$env:ARM_CLIENT_ID = "<ARM_CLIENT_ID>"
$env:ARM_CLIENT_SECRET = "<ARM_CLIENT_SECRET>"
$env:ARM_SUBSCRIPTION_ID = "<ARM_SUBSCRIPTION_ID>"  # Subscription ID correto
$env:ARM_TENANT_ID = "<ARM_TENANT_ID>"

Write-Output "VariÃ¡veis Azure configuradas!"
Write-Output "Client ID: $env:ARM_CLIENT_ID"
Write-Output "Tenant ID: $env:ARM_TENANT_ID"
