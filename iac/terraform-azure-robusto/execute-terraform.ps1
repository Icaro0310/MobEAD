# Script PowerShell para execuÃ§Ã£o robusta do Terraform
# ConfiguraÃ§Ã£o avanÃ§ada para superar problemas de conectividade

# Configurar variÃ¡veis de ambiente
$env:ARM_CLIENT_ID = "<ARM_CLIENT_ID>"
$env:ARM_CLIENT_SECRET = "<ARM_CLIENT_SECRET>"
$env:ARM_SUBSCRIPTION_ID = "<ARM_SUBSCRIPTION_ID>"
$env:ARM_TENANT_ID = "<ARM_TENANT_ID>"

# ConfiguraÃ§Ãµes de timeout e retry
$env:ARM_SKIP_PROVIDER_REGISTRATION = "true"
$env:ARM_USE_MSI = "false"
$env:TF_LOG = "INFO"
$env:TF_LOG_PATH = "./terraform-azure-robust.log"

# Adicionar Terraform ao PATH
$env:PATH += ";C:\terraform"

Write-Host "=== EXECUÃ‡ÃƒO ROBUSTA TERRAFORM AZURE ===" -ForegroundColor Green
Write-Host "ConfiguraÃ§Ã£o avanÃ§ada para superar problemas de conectividade" -ForegroundColor Yellow

# FunÃ§Ã£o de retry com backoff exponencial
function Invoke-TerraformWithRetry {
    param(
        [string]$Command,
        [int]$MaxRetries = 3,
        [int]$BaseDelay = 30
    )
    
    $attempt = 1
    $delay = $BaseDelay
    
    while ($attempt -le $MaxRetries) {
        try {
            Write-Host "Tentativa $attempt/$MaxRetries: $Command" -ForegroundColor Cyan
            
            $process = Start-Process -FilePath "terraform" -ArgumentList $Command -NoNewWindow -Wait -PassThru
            
            if ($process.ExitCode -eq 0) {
                Write-Host "âœ… Sucesso na tentativa $attempt" -ForegroundColor Green
                return $true
            } else {
                throw "Terraform falhou com cÃ³digo $($process.ExitCode)"
            }
        }
        catch {
            Write-Host "âŒ Falha na tentativa $attempt: $($_.Exception.Message)" -ForegroundColor Red
            
            if ($attempt -eq $MaxRetries) {
                Write-Host "ðŸš¨ Todas as tentativas falharam" -ForegroundColor Red
                return $false
            }
            
            Write-Host "â³ Aguardando $delay segundos antes da prÃ³xima tentativa..." -ForegroundColor Yellow
            Start-Sleep -Seconds $delay
            
            $attempt++
            $delay = $delay * 2  # Backoff exponencial
        }
    }
    
    return $false
}

# FunÃ§Ã£o para verificar conectividade Azure
function Test-AzureConnectivity {
    try {
        Write-Host "ðŸ” Testando conectividade com Azure..." -ForegroundColor Yellow
        
        # Testar conexÃ£o bÃ¡sica
        $test = az account show --output json 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "âœ… Conectividade Azure confirmada" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "âŒ Erro na conectividade Azure: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    return $false
}

# Limpar estado anterior se necessÃ¡rio
function Clear-TerraformState {
    Write-Host "ðŸ§¹ Limpando estado anterior do Terraform..." -ForegroundColor Yellow
    
    if (Test-Path ".terraform") {
        Remove-Item -Path ".terraform" -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    if (Test-Path "*.tfstate*") {
        Remove-Item -Path "*.tfstate*" -Force -ErrorAction SilentlyContinue
    }
    
    if (Test-Path "*.tflock") {
        Remove-Item -Path "*.tflock" -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host "âœ… Estado limpo" -ForegroundColor Green
}

# Executar fluxo completo
try {
    # Verificar conectividade
    if (-not (Test-AzureConnectivity)) {
        Write-Host "ðŸš¨ Conectividade Azure falhou. Verifique suas credenciais." -ForegroundColor Red
        exit 1
    }
    
    # Limpar estado
    Clear-TerraformState
    
    # Terraform Init
    Write-Host "ðŸ”§ Inicializando Terraform..." -ForegroundColor Yellow
    if (-not (Invoke-TerraformWithRetry -Command "init")) {
        Write-Host "ðŸš¨ Terraform init falhou" -ForegroundColor Red
        exit 1
    }
    
    # Terraform Validate
    Write-Host "âœ… Validando configuraÃ§Ã£o..." -ForegroundColor Yellow
    if (-not (Invoke-TerraformWithRetry -Command "validate")) {
        Write-Host "ðŸš¨ Terraform validate falhou" -ForegroundColor Red
        exit 1
    }
    
    # Terraform Plan
    Write-Host "ðŸ“‹ Gerando plano de execuÃ§Ã£o..." -ForegroundColor Yellow
    if (-not (Invoke-TerraformWithRetry -Command "plan -no-color -out=tfplan")) {
        Write-Host "ðŸš¨ Terraform plan falhou" -ForegroundColor Red
        exit 1
    }
    
    # Terraform Apply com timeout estendido
    Write-Host "ðŸš€ Aplicando configuraÃ§Ã£o (pode levar atÃ© 90 minutos)..." -ForegroundColor Yellow
    Write-Host "â±ï¸ Timeout estendido configurado para 90 minutos" -ForegroundColor Cyan
    
    # Apply com retry e timeout estendido
    $applySuccess = $false
    $maxApplyAttempts = 2  # Menos tentativas para apply
    
    for ($i = 1; $i -le $maxApplyAttempts; $i++) {
        Write-Host "ðŸ”„ Tentativa de apply $i/$maxApplyAttempts" -ForegroundColor Cyan
        
        try {
            # Executar apply com timeout estendido
            $job = Start-Job -ScriptBlock {
                param($terraformPath, $command)
                $env:PATH += ";$terraformPath"
                Set-Location $using:PWD
                terraform $command
            } -ArgumentList "C:\terraform", "apply -auto-approve -lock-timeout=90m tfplan"
            
            # Aguardar com timeout estendido (90 minutos = 5400 segundos)
            $completed = Wait-Job $job -Timeout 5400
            
            if ($completed) {
                $result = Receive-Job $job
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "âœ… Terraform apply concluÃ­do com sucesso!" -ForegroundColor Green
                    $applySuccess = $true
                    break
                } else {
                    Write-Host "âŒ Terraform apply falhou" -ForegroundColor Red
                }
            } else {
                Write-Host "â° Timeout do apply (90 minutos)" -ForegroundColor Red
                Stop-Job $job -Force
                Remove-Job $job -Force
            }
        }
        catch {
            Write-Host "âŒ Erro no apply: $($_.Exception.Message)" -ForegroundColor Red
        }
        finally {
            if (Get-Job -Name $job.Name -ErrorAction SilentlyContinue) {
                Remove-Job $job -Force
            }
        }
        
        if (-not $applySuccess -and $i -lt $maxApplyAttempts) {
            Write-Host "â³ Aguardando 60 segundos antes de retry..." -ForegroundColor Yellow
            Start-Sleep -Seconds 60
        }
    }
    
    if ($applySuccess) {
        Write-Host "ðŸŽ‰ INFRAESTRUTURA CRIADA COM SUCESSO!" -ForegroundColor Green
        Write-Host "ðŸ“Š Exibindo outputs..." -ForegroundColor Yellow
        
        # Exibir outputs
        terraform output -json | ConvertFrom-Json | ForEach-Object {
            Write-Host "ðŸ”¹ $($_.Name): $($_.Value)" -ForegroundColor White
        }
        
        Write-Host ""
        Write-Host "=== PRÃ“XIMOS PASSOS ===" -ForegroundColor Green
        Write-Host "1. Acesse a VM via RDP:" -ForegroundColor Yellow
        Write-Host "   mstsc /v:$(terraform output -raw vm_public_ip):3389" -ForegroundColor White
        Write-Host ""
        Write-Host "2. Acesse o servidor IIS:" -ForegroundColor Yellow
        Write-Host "   http://$(terraform output -raw vm_public_ip)" -ForegroundColor White
        Write-Host ""
        Write-Host "3. Configure o Ansible:" -ForegroundColor Yellow
        Write-Host "   ansible-playbook -i inventory-azure.ini playbook-iis.yml" -ForegroundColor White
        Write-Host ""
        Write-Host "ðŸ’° Custo estimado: ~$50 USD/mÃªs (dentro dos seus $200)" -ForegroundColor Green
        Write-Host "âœ… Projeto Unylea DevOps - Unidade 4 concluÃ­do!" -ForegroundColor Green
        
    } else {
        Write-Host "ðŸš¨ Terraform apply falhou apÃ³s todas as tentativas" -ForegroundColor Red
        Write-Host "ðŸ“‹ Verifique o log: terraform-azure-robust.log" -ForegroundColor Yellow
        exit 1
    }
}
catch {
    Write-Host "ðŸš¨ Erro crÃ­tico: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "ðŸ“‹ Log detalhado disponÃ­vel em: terraform-azure-robust.log" -ForegroundColor Yellow
    exit 1
}

Write-Host "ðŸ ExecuÃ§Ã£o concluÃ­da" -ForegroundColor Green
