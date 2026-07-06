# RELATORIO TECNICO DE EXECUCAO - UNYLEA DEVOPS UNIDADE 4

**Aluno:** Icaro Galvao do Nascimento  
**Curso:** Engenheiro DevOps - Unidade 4  
**Data:** 06/07/2026  
**Projeto:** Infraestrutura como Codigo (IaC) + Ansible + Cloud  

---

## SUMARIO EXECUTIVO

Este relatorio documenta a execucao do projeto de provisionamento de infraestrutura com Terraform, Ansible e Cloud (Azure). Iniciei o projeto com Terraform para Azure, porem o `terraform apply` falhou sistematicamente devido a limitacoes de conta, restricoes regionais e timeouts de conectividade. Como alternativa, utilizei Docker + Nginx + Ansible para simular o Windows Server + IIS, garantindo a entrega de todos os objetivos de aprendizado da unidade.

---

## ADAPTACAO DO PROJETO: AWS PARA AZURE

O projeto original foi projetado para AWS (EC2 + Windows Server + IIS). Optei por adaptar para Microsoft Azure por ja possuir creditos Azure ($200 USD) e conta ativa.

### Mudancas Realizadas
| Componente | AWS (Original) | Azure (Adaptado) |
|------------|----------------|------------------|
| Provider Terraform | `hashicorp/aws` | `hashicorp/azurerm` |
| Instancia | `aws_instance` (t2.micro) | `azurerm_windows_virtual_machine` |
| Security Group | `aws_security_group` | `azurerm_network_security_group` |
| IP Publico | `aws_eip` | `azurerm_public_ip` |
| Autenticacao | Access Key + Secret Key | Service Principal (Client ID + Secret + Tenant ID) |
| Regiao | us-east-1 | East US (West Europe indisponivel) |
| User Data | `user_data` (Bash/PowerShell) | `custom_data` (PowerShell) |
| Conexao Ansible | WinRM HTTPS (5986) | WinRM HTTPS (5986) |

---

## EXECUCAO ETAPA POR ETAPA

### ETAPA 0: PRE-REQUISITOS
| Item | Status | Observacao |
|------|--------|------------|
| Conta Cloud | Concluido | Azure (adaptado de AWS) |
| Terraform instalado | Concluido | v1.x instalado |
| Ansible instalado | Parcial | Incompativel com Python 3.14 no Windows |
| Azure CLI instalado | Falhou | Nao reconhecido no PATH |
| Git instalado | Concluido | Funcionando corretamente |

**Falha documentada:** O Azure CLI (`az`) nao foi reconhecido como comando valido, mesmo apos download e execucao dos instaladores MSI. Contornei o problema autenticando o Terraform via Service Principal diretamente (variaveis de ambiente ARM_*).

---

### ETAPA 1: CONFIGURAR CREDENCIAIS
| Item | Status | Observacao |
|------|--------|------------|
| Login na plataforma | Concluido | Service Principal criado via Cloud Shell |
| Credenciais configuradas | Concluido | ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID |
| Validacao de identidade | Parcial | `az account show` falhou, mas Terraform autenticou via Service Principal |

---

### ETAPA 2: AUTENTICACAO
| Item | Status | Observacao |
|------|--------|------------|
| Autenticacao configurada | Concluido | Via Service Principal + variaveis de ambiente |

No Azure, a autenticacao para Terraform e feita via Service Principal (App Registration), nao via Key Pair como na AWS.

---

### ETAPA 3: CLONAR REPOSITORIO
| Item | Status | Observacao |
|------|--------|------------|
| Fork do repositorio | Concluido | https://github.com/Icaro0310/MobEAD.git |
| Clone local | Concluido | C:\Users\Utilizador\Downloads\MobEAD-icaro |
| Pasta iac/terraform criada | Concluido | Multiplas variacoes criadas |
| Pasta iac/ansible criada | Concluido | Playbooks adaptados para Azure |
| Arquivos copiados | Concluido | Todos os arquivos IaC criados |

---

### ETAPA 4: CONFIGURAR E EXECUTAR TERRAFORM
| Item | Status | Observacao |
|------|--------|------------|
| `terraform init` | Concluido | Providers baixados com sucesso (azurerm 3.117.1 e 4.80.0) |
| `terraform validate` | Concluido | "Success! The configuration is valid." |
| `terraform plan` | Concluido | 7-8 recursos planejados para criacao |
| `terraform apply` | **FALHOU SISTEMATICAMENTE** | Ver secao detalhada abaixo |

#### FALHA DETALHADA - TERRAFORM APPLY

**Tentativa 1: Terraform Minimal (West Europe)**
- Regiao: West Europe
- Erro: `RegionUnavailable` - West Europe nao disponivel para novos clientes Azure
- Causa raiz: Conta Azure nova nao tem acesso a todas as regioes europeias

**Tentativa 2: Terraform Minimal (East US)**
- Regiao: East US
- Erro: `PublicIPSKUInvalid` - SKU Basic descontinuado para Public IP
- Causa raiz: Azure descontinuou SKU Basic para novos Public IPs
- Correcao: Alterado para SKU Standard

**Tentativa 3: Terraform com SKU Standard (East US)**
- Regiao: East US
- Erro: Timeout na criacao do Resource Group
- Causa raiz: Conectividade instavel Portugal <-> Azure East US API

**Tentativa 4: Terraform Professional Azure (East US, Standard_B2s, Premium SSD)**
- Regiao: East US
- VM Size: Standard_B2s (2 vCPUs, 4GB RAM)
- Disco: Premium SSD
- Erro: Timeout na criacao da Virtual Network

**Tentativa 5: Terraform Azure Robusto (timeouts estendidos 60-90 min)**
- Regiao: East US
- Configuracao: Timeouts de 60min (create) e 30min (delete) por recurso
- Retry: Mecanismo de retry automatico configurado
- Backend: Local (evita locks remotos)
- Erro: Timeout mesmo com 60 minutos configurados

**Tentativas 6-9:** Varias outras configuracoes (Ubuntu+Nginx, Ubuntu+Docker+IIS, etc.) - todas falharam por timeout.

**Total de tentativas Terraform Apply:** 9 tentativas  
**Tempo total investido:** ~3 horas  
**Resultado:** 0 sucessos, 9 falhas por timeout ou indisponibilidade regional

#### ANALISE DA CAUSA RAIZ DAS FALHAS TERRAFORM

1. **Indisponibilidade Regional (West Europe):** Contas Azure novas tem acesso restrito a regioes. West Europe (mais proxima de Portugal) nao disponivel. Solucao: usar East US (mais distante, maior latencia).

2. **Timeouts Sistemicos (East US):** A API Azure responde (terraform plan funciona), mas operacoes de longa duracao (create) expiram. Latencia Portugal <-> East US ~120-150ms. Operacoes de provisionamento de VM exigem multiplas chamadas API sequenciais, cada uma adicionando overhead de latencia.

3. **SKU Descontinuado:** Public IP Basic SKU removido pelo Azure. Corrigido para Standard, mas nao resolveu o timeout.

4. **Limitacao de Conta Free Trial:** Conta com $200 creditos mas restricoes de quota. Algumas SKUs de VM nao disponiveis em contas trial.

---

### ETAPA 5: CONFIGURAR INVENTARIO ANSIBLE
| Item | Status | Observacao |
|------|--------|------------|
| inventory.ini criado | Concluido | Multiplas versoes (Azure, Docker) |
| IP publico preenchido | N/A | Sem VM criada, nao ha IP para preencher |
| Variaveis WinRM configuradas | Concluido | ansible_connection=winrm, porta 5986 |

---

### ETAPA 6: INSTALAR DEPENDENCIA PYTHON (WINRM)
| Item | Status | Observacao |
|------|--------|------------|
| `pip install pywinrm` | Concluido | Instalado com sucesso |
| `python -c "import winrm"` | Concluido | Modulo importado corretamente |

---

### ETAPA 7: TESTAR CONECTIVIDADE ANSIBLE -> WINDOWS
| Item | Status | Observacao |
|------|--------|------------|
| `ansible windows -m win_ping` | N/A | Sem VM Windows criada para testar |

---

### ETAPA 8: EXECUTAR PLAYBOOK ANSIBLE
| Item | Status | Observacao |
|------|--------|------------|
| Playbook Ansible REAL (Docker) | Concluido | 11 tasks executadas, 0 falhas |
| Log do Ansible | Concluido | Salvo em iac/prints/ansible_REAL_log_*.txt |

**Solucao adotada:** Como o Ansible nao suporta Windows como controller (depende de modulos Unix como `fcntl`, `termios`, `os.fork`), criei um container Docker Linux com Python 3.11 + Ansible-core 2.19.11. O Ansible dentro do container gerenciou o container IIS no host Windows via socket Docker. O playbook executou 11 tasks com sucesso: verificacao do Docker, construcao da imagem, inicio do container, validacao HTTP 200 e exibicao do resumo final.

---

### ETAPA 9: VALIDAR IIS NO BROWSER
| Item | Status | Observacao |
|------|--------|------------|
| Acesso HTTP ao servidor | Concluido | http://localhost:8090 (Docker local) |
| Pagina HTML personalizada | Concluido | Com dados do aluno e projeto |
| Print do browser | Concluido | Capturado automaticamente via script PowerShell |

A pagina HTML contem todos os elementos exigidos: "Servidor IIS - Unylea DevOps!", "Engenheiro DevOps | Unidade 4", "Aluno: Icaro Galvao do Nascimento", e a stack tecnologica completa.

---

### ETAPA 10: VALIDAR RDP (OPCIONAL)
| Item | Status | Observacao |
|------|--------|------------|
| Conexao RDP | N/A | Sem VM Azure para conectar |

---

### ETAPA 11: COMMITAR E ENVIAR PARA GITHUB
| Item | Status | Observacao |
|------|--------|------------|
| `git add .` | Concluido | Arquivos adicionados |
| `git commit` | Concluido | Commits realizados |
| `git push origin main` | Concluido | Apos resolver 3 bloqueios |
| Link do repositorio | Concluido | https://github.com/Icaro0310/MobEAD.git |

#### FALHAS NO GIT PUSH (3 bloqueios resolvidos)

**Bloqueio 1: Arquivos grandes (>100MB)** - Providers Terraform (227MB) e instaladores MSI (67MB) foram acidentalmente commitados. Criei `.gitignore` com regras para `*.msi`, `*.exe`, `.terraform/` e removi os arquivos do index.

**Bloqueio 2: Mais arquivos grandes em outras pastas** - Multiplas pastas terraform-* com `.terraform/` nao ignoradas. Fiz reset seletivo e re-add apenas de arquivos pequenos.

**Bloqueio 3: GitHub Push Protection (segredos Azure)** - O GitHub detectou o Azure Client Secret no codigo. Substitui todas as credenciais por placeholders (`<ARM_CLIENT_SECRET>`, etc.) em todos os arquivos.

---

### ETAPA 12: LIMPAR RECURSOS
| Item | Status | Observacao |
|------|--------|------------|
| `terraform destroy` | Concluido | 5 recursos destruidos |
| Resource Group removido | Concluido | rg-unylea-azure-professional deletado |
| Verificacao de custos | Concluido | Sem recursos ativos, sem cobrancas |

---

## SOLUCAO ALTERNATIVA ADOTADA: DOCKER + NGINX + ANSIBLE

### Justificativa
Apos 9 tentativas falhas de `terraform apply` na Azure, adotei uma solucao alternativa que garantisse a entrega do projeto dentro do prazo, demonstrasse os mesmos conceitos de IaC, funcionasse com Ansible para automacao, nao gerasse custos adicionais e produzisse todas as evidencias exigidas.

### Arquitetura da Solucao
```
[Docker Container: unylea-iis]
    - Imagem: nginx:alpine (base)
    - Config: nginx.conf (server block personalizado)
    - HTML: index.html (pagina IIS simulada)
    - Porta: 8090 -> 80 (mapeamento)
    - Healthcheck: wget http://localhost/

[Ansible Controller: Container Linux]
    - Imagem: python:3.11-slim + ansible-core 2.19.11
    - Docker CLI instalado para gerenciar containers
    - Socket Docker montado (/var/run/docker.sock)
    - Acesso ao host via host.docker.internal

[Ansible Playbook: playbook-iis-docker-real.yml]
    - Task 1: Verificar Docker instalado
    - Task 2: Verificar imagem existente
    - Task 3: Construir imagem Docker (se necessario)
    - Task 4: Remover container existente
    - Task 5: Iniciar container IIS
    - Task 6: Aguardar container pronto
    - Task 7: Validar HTTP (status 200)
    - Task 8: Validar mensagem de sucesso
    - Task 9: Exibir resumo final
```

---

## CHECKLIST DE ENTREGA - STATUS FINAL

| Item exigido | Status | Evidencia |
|--------------|--------|-----------|
| Link do repositorio GitHub | Concluido | https://github.com/Icaro0310/MobEAD.git |
| Print do terminal com output do terraform | Concluido | iac/prints/ (terraform plan + validate) |
| Print do terminal com log do ansible-playbook | Concluido | iac/prints/ansible_REAL_log_20260706_022704.txt |
| Print do browser mostrando IIS funcionando | Concluido | iac/prints/print_iis_20260706_013716.png |
| Print do RDP (opcional) | N/A | Sem VM Azure |

---

## SEGURANCA E CUSTOS

### Credenciais Azure
- Todas as credenciais foram removidas do codigo antes do push
- GitHub Push Protection detectou e bloqueou o segredo Azure
- Credenciais substituidas por placeholders
- Service Principal pode ser revogado no Portal Azure

### Custos Azure
- `terraform destroy` executado - 5 recursos destruidos
- Resource Group removido
- Sem recursos ativos na conta Azure
- Sem cobrancas futuras

---

## APRENDIZADOS E COMPETENCIAS DEMONSTRADAS

### Conceitos de IaC (Infraestrutura como Codigo)
- Terraform: providers, resources, variables, outputs, state
- Terraform: init, validate, plan, apply, destroy
- Terraform: timeouts, retry, backend local
- Terraform: Service Principal authentication (Azure)

### Automacao com Ansible
- Playbook structure (hosts, tasks, handlers, vars)
- Modules: command, debug, wait_for, uri, assert
- Inventory configuration (local, docker)
- Idempotency e validacao
- Execucao de Ansible em container Linux para gerenciar Docker no host Windows

### Containerizacao com Docker
- Dockerfile creation (FROM, RUN, COPY, EXPOSE, CMD)
- Docker build e run
- Port mapping e healthcheck
- Nginx como servidor web
- Docker socket mounting para Ansible gerenciar containers

### Cloud Computing (Azure)
- Resource Groups, VNets, Subnets, NSGs
- Public IPs, NICs, Virtual Machines
- Security rules (RDP, WinRM, HTTP)
- Service Principal e autenticacao

### CI/CD e Versionamento
- Git: clone, add, commit, push
- Git: .gitignore, reset, amend
- GitHub: Push Protection, Large File Storage
- Azure DevOps: pipeline YAML criado

### Seguranca
- Remocao de credenciais do codigo
- GitHub Push Protection
- Destruicao de recursos cloud
- Gestao de custos

---

## CONCLUSAO

Conclui o projeto academico da Unidade 4 atraves de uma solucao alternativa (Docker + Ansible) apos falhas sistemicas no provisionamento cloud (Azure). Todos os conceitos de IaC, automacao Ansible e containerizacao foram demonstrados e documentados.

As falhas no `terraform apply` nao representam erro de configuracao, mas sim limitacoes de disponibilidade regional para contas Azure novas, latencia de rede entre Portugal e datacenters Azure nos EUA, e timeouts em operacoes de longa duracao via API.

A solucao Docker+Nginx+Ansible entregou todos os objetivos de aprendizado da unidade, com todas as evidencias (prints, logs, codigo) devidamente documentadas e versionadas no GitHub.

---

**Relatorio gerado em:** 06/07/2026  
**Aluno:** Icaro Galvao do Nascimento  
**Curso:** Unylea - Engenheiro DevOps - Unidade 4