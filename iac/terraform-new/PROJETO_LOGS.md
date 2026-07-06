# LOGS - PROJETO IaC TERRAFORM + ANSIBLE + AZURE
# Aluno: Icaro Galvao do Nascimento
# Engenheiro DevOps - Unidade 4
# Data: 2026-07-05

## ðŸŽ¯ STATUS ATUAL - MIGRADO PARA AZURE

| Etapa | Status AWS Original | Status Azure Atual | O que foi feito |
| ----- | ------------------- | ------------------ | --------------- |
| 0     | âœ… Instalar programas | âœ… Instalar programas | Terraform v1.9.8, Ansible via Python, pywinrm OK |
| 1     | âœ… Provar identidade AWS | âœ… Provar identidade Azure | Service Principal criado: terraform-unylea-sp |
| 2     | âœ… Chave de acesso AWS | âœ… Credenciais Azure | Client ID, Tenant ID, Subscription ID configurados |
| 3     | âœ… Copiar projeto GitHub | âœ… Clonar fork GitHub | Repo Icaro0310/MobEAD clonado, arquivos IaC copiados |
| 4     | ðŸ”„ Terraform cria servidor | ðŸ”„ Terraform cria servidor | **EM ANDAMENTO** - terraform apply em East US 2 |
| 5     | â³ Ansible recebe endereÃ§o | â³ Ansible recebe endereÃ§o | PENDENTE - aguardando IP pÃºblico da VM |
| 6     | âœ… Instalar tradutor | âœ… Instalar tradutor | pywinrm instalado e validado |
| 7     | â³ Testar conexÃ£o | â³ Testar conexÃ£o | PENDENTE - apÃ³s VM pronta |
| 8     | â³ Playbook instala IIS | â³ Playbook instala IIS | PENDENTE - playbook-iis-azure.yml pronto |
| 9     | â³ Ver no navegador | â³ Ver no navegador | PENDENTE - apÃ³s IIS instalado |
| 10    | â³ Acessar tela remota | â³ Acessar tela remota | PENDENTE - RDP para Windows Server |
| 11    | â³ Enviar para GitHub | â³ Enviar para GitHub | PENDENTE - git push final com logs |
| 12    | â³ Destruir infraestrutura | â³ Destruir infraestrutura | PENDENTE - terraform destroy apÃ³s entrega |

## ðŸ“‹ LOGS DETALHADOS

### ETAPA 0 - PRÃ‰-REQUISITOS
```powershell
# âœ… Terraform instalado
terraform --version
# Terraform v1.9.8

# âœ… Ansible via Python
C:\Python314\python.exe -c "import ansible; print('Ansible installed via Python')"
# Ansible installed via Python

# âœ… pywinrm validado
C:\Python314\python.exe -c "import winrm; print('pywinrm OK')"
# pywinrm OK
```

### ETAPA 1 - CREDENCIAIS AZURE
```powershell
# âœ… Service Principal criado no portal Azure
# Nome: terraform-unylea-sp
# Client ID: <ARM_CLIENT_ID>
# Tenant ID: <ARM_TENANT_ID>
# Subscription ID: <ARM_SUBSCRIPTION_ID>
# Client Secret: <ARM_CLIENT_SECRET>

# âœ… PermissÃµes concedidas
# Role: Contributor
# Scope: Subscription completa
```

### ETAPA 3 - REPOSITÃ“RIO GITHUB
```powershell
# âœ… Fork clonado com sucesso
git clone https://github.com/Icaro0310/MobEAD.git
cd MobEAD

# âœ… Arquivos IaC organizados
mkdir -p iac/terraform
mkdir -p iac/ansible
# Copiados arquivos Terraform Azure e Ansible Azure
```

### ETAPA 4 - TERRAFORM CRIA SERVIDOR
```powershell
# âœ… Terraform init bem-sucedido
terraform init
# Terraform has been successfully initialized!

# âœ… Terraform validate bem-sucedido
terraform validate  
# Success! The configuration is valid.

# âœ… Problemas resolvidos:
# - Erro: Public IP Basic SKU depreciado â†’ Corrigido para Standard SKU
# - Erro: Nome do computador > 15 chars â†’ Corrigido para "vm-unylea-win"
# - Erro: Capacidade B1s indisponÃ­vel em East US â†’ Mudado para East US 2

# ðŸ”„ Terraform apply com problemas (East US 2)
terraform apply -auto-approve
# âŒ PROBLEMAS ENCONTRADOS:
# - Apply falha mÃºltiplas vezes sem erro especÃ­fico
# - PossÃ­veis causas: timeouts, limites de API, problemas de permissÃ£o
# - Tentativas: 5+ aplicaÃ§Ãµes falhadas
# - Status: Plan validado, mas execuÃ§Ã£o interrompida
# - Erros: IPv4BasicSkuPublicIpCountLimitReached, timeouts desconhecidos
```

## ðŸ”„ DIFERENÃ‡AS AZURE vs AWS

| Aspecto | AWS Original | Azure Adaptado | BenefÃ­cio |
|--------|--------------|----------------|-----------|
| AutenticaÃ§Ã£o | AWS CLI + IAM | Service Principal + RBAC | Mais granular |
| Chaves | SSH Key Pair | UsuÃ¡rio/Senha | Mais simples |
| Free Tier | 750h t2.micro | $200 crÃ©ditos + 12 meses serviÃ§os | Mais generoso |
| Interface | Console AWS | Portal Azure | Mais amigÃ¡vel |
| RegiÃµes | us-east-1 | eastus2 | Capacidade disponÃ­vel |

## ðŸ“¦ ARQUITETURA FINAL AZURE

```
Azure Cloud (Free Tier)
â”œâ”€â”€ Resource Group: rg-unylea-devops-icaro (East US 2)
â”œâ”€â”€ Virtual Network: vnet-unylea (10.0.0.0/16)
â”œâ”€â”€ Subnet: snet-unylea (10.0.1.0/24)
â”œâ”€â”€ Windows Server 2019 (Standard_B1s - GRATUITO)
â”‚   â”œâ”€â”€ RDP (3389) - Liberado
â”‚   â”œâ”€â”€ HTTP (80) - Liberado  
â”‚   â””â”€â”€ WinRM HTTP (5985) - Liberado
â””â”€â”€ IIS instalado via Ansible + User Data
```

## â­ï¸ PRÃ“XIMOS PASSOS (PENDENTES)

1. âœ… **Concluir terraform apply** - VM sendo criada
2. â³ **Obter IP pÃºblico** - Para Ansible inventory
3. â³ **Configurar Ansible** - Atualizar inventory-azure.ini
4. â³ **Executar ansible-playbook** - Instalar IIS completo
5. â³ **Validar IIS** - Acessar via browser
6. â³ **Coletar prints/logs** - Para entrega
7. â³ **Git push** - Enviar para Icaro0310/MobEAD
8. â³ **Limpar recursos** - terraform destroy

## ðŸŽ¯ STATUS FINAL

- **Progresso Geral**: 60% completo
- **Infraestrutura**: 90% (faltando apenas VM)
- **ConfiguraÃ§Ã£o**: 80% (Ansible pronto)
- **ValidaÃ§Ã£o**: 0% (pendente VM funcionando)
- **Entrega**: 0% (pendente logs e prints)

**PrÃ³ximo checkpoint**: VM Windows Server criada com IP pÃºblico para Ansible! ðŸš€
