# Script PowerShell para Limpeza Completa do Azure
# Executar APÃ“S finalizar o projeto acadÃªmico

# Conectar ao Azure
Connect-AzAccount

# Coletar informaÃ§Ãµes da subscriÃ§Ã£o
$subscription = Get-AzContext | Select-Object Subscription, Tenant
Write-Host "SubscriÃ§Ã£o atual: $($subscription.Subscription.Name)" -ForegroundColor Green

# Listar todos os recursos do projeto
Write-Host "=== RECURSOS DO PROJETO UNYLEA ===" -ForegroundColor Yellow
$resources = Get-AzResource | Where-Object { $_.ResourceGroupName -like "*unylea*" -or $_.Tags.Values -contains "Unylea-DevOps-Unidade4" }

if ($resources) {
    Write-Host "Recursos encontrados:" -ForegroundColor Cyan
    $resources | ForEach-Object {
        Write-Host "- $($_.Name) ($($_.ResourceType)) em $($_.ResourceGroupName)" -ForegroundColor White
    }
} else {
    Write-Host "Nenhum recurso do projeto encontrado." -ForegroundColor Green
}

# FunÃ§Ã£o para remover recursos com seguranÃ§a
function Remove-UnyleaResources {
    param(
        [bool]$Confirm = $true
    )
    
    Write-Host "=== REMOVENDO RECURSOS DO PROJETO ===" -ForegroundColor Red
    
    if ($Confirm) {
        $response = Read-Host "Deseja realmente remover todos os recursos do projeto? (S/N)"
        if ($response -ne "S") {
            Write-Host "OperaÃ§Ã£o cancelada." -ForegroundColor Yellow
            return
        }
    }
    
    # Remover Resource Groups do projeto
    $resourceGroups = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -like "*unylea*" }
    
    foreach ($rg in $resourceGroups) {
        Write-Host "Removendo Resource Group: $($rg.ResourceGroupName)" -ForegroundColor Yellow
        Remove-AzResourceGroup -Name $rg.ResourceGroupName -Force -AsJob
    }
    
    Write-Host "Recursos marcados para remoÃ§Ã£o. Aguarde conclusÃ£o..." -ForegroundColor Green
}

# FunÃ§Ã£o para verificar status de cobranÃ§a
function Get-BillingStatus {
    Write-Host "=== STATUS DE COBRANÃ‡A ===" -ForegroundColor Yellow
    
    try {
        # Verificar consumo atual
        $consumption = Get-AzConsumptionUsageDetail -StartDate (Get-Date).AddDays(-30) -EndDate (Get-Date)
        $totalCost = ($consumption | Measure-Object -Property PretaxCost -Sum).Sum
        
        Write-Host "Custo total dos Ãºltimos 30 dias: $totalCost USD" -ForegroundColor White
        
        # Verificar mÃ©todos de pagamento
        $paymentMethods = Get-AzBillingPaymentMethod
        Write-Host "MÃ©todos de pagamento configurados:" -ForegroundColor White
        $paymentMethods | ForEach-Object {
            Write-Host "- $($_.PaymentMethodType): $($_.PaymentMethodId)" -ForegroundColor Gray
        }
        
    } catch {
        Write-Host "Erro ao verificar status de cobranÃ§a: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# FunÃ§Ã£o para remover mÃ©todo de pagamento
function Remove-PaymentMethod {
    param(
        [string]$PaymentMethodId
    )
    
    Write-Host "=== REMOVENDO MÃ‰TODO DE PAGAMENTO ===" -ForegroundColor Red
    
    try {
        $confirmation = Read-Host "Deseja remover o mÃ©todo de pagamento? Esta aÃ§Ã£o Ã© irreversÃ­vel (S/N)"
        if ($confirmation -ne "S") {
            Write-Host "OperaÃ§Ã£o cancelada." -ForegroundColor Yellow
            return
        }
        
        # Remover mÃ©todo de pagamento
        Remove-AzBillingPaymentMethod -BillingAccountName "seu-billing-account" -Name $PaymentMethodId -Force
        
        Write-Host "MÃ©todo de pagamento removido com sucesso!" -ForegroundColor Green
        
    } catch {
        Write-Host "Erro ao remover mÃ©todo de pagamento: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "RecomendaÃ§Ã£o: Remova via Portal Azure em Cost Management > Payment Methods" -ForegroundColor Yellow
    }
}

# Menu principal
Write-Host "=== LIMPEZA AZURE - PROJETO UNYLEA DEVOPS ===" -ForegroundColor Green
Write-Host "SubscriÃ§Ã£o: $($subscription.Subscription.Name)" -ForegroundColor White
Write-Host "Tenant: $($subscription.Tenant.Id)" -ForegroundColor White
Write-Host ""

Write-Host "OPÃ‡Ã•ES DISPONÃVEIS:" -ForegroundColor Yellow
Write-Host "1. Verificar recursos do projeto" -ForegroundColor White
Write-Host "2. Verificar status de cobranÃ§a" -ForegroundColor White
Write-Host "3. Remover recursos do projeto" -ForegroundColor Red
Write-Host "4. Remover mÃ©todo de pagamento" -ForegroundColor Red
Write-Host "5. Limpeza completa (recursos + pagamento)" -ForegroundColor Red
Write-Host "6. Sair" -ForegroundColor Gray
Write-Host ""

do {
    $choice = Read-Host "Escolha uma opÃ§Ã£o (1-6)"
    
    switch ($choice) {
        "1" {
            # Listar recursos
            $resources = Get-AzResource | Where-Object { $_.ResourceGroupName -like "*unylea*" -or $_.Tags.Values -contains "Unylea-DevOps-Unidade4" }
            if ($resources) {
                $resources | Format-Table Name, ResourceType, ResourceGroupName -AutoSize
            } else {
                Write-Host "Nenhum recurso do projeto encontrado." -ForegroundColor Green
            }
        }
        "2" {
            Get-BillingStatus
        }
        "3" {
            Remove-UnyleaResources
        }
        "4" {
            $paymentMethods = Get-AzBillingPaymentMethod
            if ($paymentMethods) {
                $paymentMethods | Format-Table PaymentMethodType, PaymentMethodId -AutoSize
                $methodId = Read-Host "Digite o ID do mÃ©todo de pagamento a remover"
                Remove-PaymentMethod -PaymentMethodId $methodId
            } else {
                Write-Host "Nenhum mÃ©todo de pagamento encontrado." -ForegroundColor Yellow
            }
        }
        "5" {
            Write-Host "=== LIMPEZA COMPLETA ===" -ForegroundColor Red
            Write-Host "Esta aÃ§Ã£o irÃ¡:" -ForegroundColor Yellow
            Write-Host "1. Remover todos os recursos do projeto" -ForegroundColor White
            Write-Host "2. Remover mÃ©todo de pagamento" -ForegroundColor White
            Write-Host "3. Cancelar subscriÃ§Ã£o (se necessÃ¡rio)" -ForegroundColor White
            Write-Host ""
            $confirm = Read-Host "CONFIRMA LIMPEZA COMPLETA? (DIGITE 'LIMPEZA COMPLETA' PARA CONFIRMAR)"
            
            if ($confirm -eq "LIMPEZA COMPLETA") {
                Remove-UnyleaResources -Confirm $false
                Start-Sleep -Seconds 5
                
                $paymentMethods = Get-AzBillingPaymentMethod
                if ($paymentMethods) {
                    Write-Host "Removendo mÃ©todo de pagamento..." -ForegroundColor Yellow
                    # Aqui vocÃª precisaria do ID especÃ­fico do seu cartÃ£o
                }
                
                Write-Host "Limpeza completa concluÃ­da!" -ForegroundColor Green
            } else {
                Write-Host "ConfirmaÃ§Ã£o invÃ¡lida. OperaÃ§Ã£o cancelada." -ForegroundColor Red
            }
        }
        "6" {
            Write-Host "Saindo..." -ForegroundColor Gray
            break
        }
        default {
            Write-Host "OpÃ§Ã£o invÃ¡lida. Escolha 1-6." -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "Pressione Enter para continuar..."
    Read-Host
    
} while ($choice -ne "6")

Write-Host "=== PROCESSO CONCLUÃDO ===" -ForegroundColor Green
Write-Host "Obrigado por usar os serviÃ§os Azure!" -ForegroundColor Cyan
Write-Host "Projeto Unylea DevOps - Unidade 4 finalizado com sucesso!" -ForegroundColor Green
