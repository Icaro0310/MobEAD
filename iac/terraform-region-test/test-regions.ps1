# Script para testar regiÃµes Azure automaticamente
# Execute: .\test-regions.ps1

Write-Host "ðŸ” TESTANDO REGIÃ•ES AZURE AUTOMATICAMENTE..." -ForegroundColor Green

# Credenciais Azure
$env:ARM_CLIENT_ID = "<ARM_CLIENT_ID>"
$env:ARM_CLIENT_SECRET = "<ARM_CLIENT_SECRET>"
$env:ARM_SUBSCRIPTION_ID = "<ARM_SUBSCRIPTION_ID>"
$env:ARM_TENANT_ID = "<ARM_TENANT_ID>"
$env:PATH += ";$env:USERPROFILE\bin"

# RegiÃµes para testar (em ordem de proximidade com Portugal)
$regions = @(
    "West Europe",
    "North Europe", 
    "France Central",
    "Germany West Central",
    "UK South",
    "East US",
    "East US 2",
    "Central US",
    "West US",
    "West US 2",
    "Brazil South",
    "Canada Central"
)

# Imagens para testar (se Windows 2019 nÃ£o funcionar)
$images = @(
    @{publisher="MicrosoftWindowsServer"; offer="WindowsServer"; sku="2019-Datacenter"; name="Windows Server 2019"},
    @{publisher="MicrosoftWindowsServer"; offer="WindowsServer"; sku="2022-Datacenter"; name="Windows Server 2022"},
    @{publisher="Canonical"; offer="UbuntuServer"; sku="18.04-LTS"; name="Ubuntu 18.04"},
    @{publisher="Canonical"; offer="UbuntuServer"; sku="20.04-LTS"; name="Ubuntu 20.04"},
    @{publisher="Canonical"; offer="UbuntuServer"; sku="22.04-LTS"; name="Ubuntu 22.04"}
)

# VM Sizes para testar (Free Tier)
$sizes = @("Standard_B1s", "Standard_B1ms", "Standard_B2s")

$success = $false
$working_config = $null

foreach ($region in $regions) {
    Write-Host "`nðŸŒ Testando regiÃ£o: $region" -ForegroundColor Yellow
    
    foreach ($image in $images) {
        Write-Host "  ðŸ“¦ Testando imagem: $($image.name)" -ForegroundColor Cyan
        
        foreach ($size in $sizes) {
            Write-Host "    ðŸ’¾ Testando size: $size" -ForegroundColor White
            
            # Criar arquivo terraform.tfvars temporÃ¡rio
            $tfvars = @"
region = "$region"
vm_size = "$size"
image_publisher = "$($image.publisher)"
image_offer = "$($image.offer)"
image_sku = "$($image.sku)"
"@
            
            $tfvars | Out-File -FilePath "terraform.tfvars" -Encoding UTF8
            
            # Limpar estado anterior
            Remove-Item -Path ".terraform" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "terraform.tfstate*" -ErrorAction SilentlyContinue
            
            # Tentar terraform init
            Write-Host "      ðŸ”§ terraform init..." -ForegroundColor Gray
            $init = terraform init 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Host "        âŒ Init falhou" -ForegroundColor Red
                continue
            }
            
            # Tentar terraform plan
            Write-Host "      ðŸ“‹ terraform plan..." -ForegroundColor Gray
            $plan = terraform plan -no-color 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Host "        âŒ Plan falhou" -ForegroundColor Red
                continue
            }
            
            # Se chegou aqui, o plan funcionou!
            Write-Host "        âœ… Plan bem-sucedido!" -ForegroundColor Green
            
            $working_config = @{
                region = $region
                size = $size
                image = $image
            }
            
            $success = $true
            break
        }
        
        if ($success) { break }
    }
    
    if ($success) { break }
}

if ($success) {
    Write-Host "`nðŸŽ‰ SUCESSO! ConfiguraÃ§Ã£o encontrada:" -ForegroundColor Green
    Write-Host "  ðŸ“ RegiÃ£o: $($working_config.region)" -ForegroundColor White
    Write-Host "  ðŸ’¾ Size: $($working_config.size)" -ForegroundColor White
    Write-Host "  ðŸ“¦ Imagem: $($working_config.image.name)" -ForegroundColor White
    Write-Host "`nðŸš€ Execute 'terraform apply -auto-approve' para criar a VM!" -ForegroundColor Yellow
} else {
    Write-Host "`nâŒ Nenhuma configuraÃ§Ã£o funcionou. Verifique limites da conta Azure." -ForegroundColor Red
}

Write-Host "`nðŸ” Fim dos testes." -ForegroundColor Green
