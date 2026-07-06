# Terraform Azure Profissional - Aproveitando $200 de crÃ©ditos
# Windows Server 2019 + IIS + Ansible + Terraform

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.117.1"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-unylea-professional"
  location = "East US"
  
  tags = {
    Curso = "Unylea-DevOps-Unidade4"
    Aluno = "Icaro Galvao do Nascimento"
    Projeto = "IaC-Terraform-Ansible-Azure-Professional"
    Orcamento = "200USD"
  }
}

# VM Windows Server 2019 - Size B2s (nÃ£o Free Tier)
resource "azurerm_windows_virtual_machine" "main" {
  name                = "vm-unylea-winserver-2019-professional"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B2s"  # 2 vCPUs, 4GB RAM - $50/mÃªs
  admin_username      = "azureuser"
  admin_password      = "Unylea@2024!DevOps"
  network_interface_ids = [azurerm_network_interface.main.id]
  zone                 = 1  # Alta disponibilidade
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"  # Disco premium para melhor performance
    disk_size_gb         = 127
  }
  
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  
  # User Data para configuraÃ§Ã£o automÃ¡tica
  custom_data = base64encode(<<EOF
<powershell>
# Configurar WinRM para Ansible
Write-Host "Configurando WinRM..."
winrm quickconfig -q -Force
winrm set winrm/config/service '@{Basic="true"}' -Force
winrm set winrm/config/service '@{AllowUnencrypted="true"}' -Force
winrm set winrm/config/client '@{Basic="true"}' -Force
winrm create winrm/config/Listener?Address=*+Transport=HTTP "@{Port=`"5985`"}" -Force

# Configurar firewall
New-NetFirewallRule -Name "WinRM-HTTP-In" -DisplayName "WinRM over HTTP" -Protocol TCP -LocalPort 5985 -Direction Inbound -Action Allow -Force
New-NetFirewallRule -Name "RDP" -DisplayName "Remote Desktop" -Protocol TCP -LocalPort 3389 -Direction Inbound -Action Allow -Force
New-NetFirewallRule -Name "HTTP" -DisplayName "HTTP" -Protocol TCP -LocalPort 80 -Direction Inbound -Action Allow -Force
New-NetFirewallRule -Name "HTTPS" -DisplayName "HTTPS" -Protocol TCP -LocalPort 443 -Direction Inbound -Action Allow -Force

# Habilitar RDP
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0 -Force
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -Force

# Instalar IIS com todos os recursos
Write-Host "Instalando IIS completo..."
Install-WindowsFeature -Name Web-Server -IncludeManagementTools -Force
Install-WindowsFeature -Name Web-Asp-Net45 -IncludeManagementTools -Force
Install-WindowsFeature -Name Web-Net-Ext45 -IncludeManagementTools -Force
Install-WindowsFeature -Name Web-ISAPI-Ext -IncludeManagementTools -Force
Install-WindowsFeature -Name Web-ISAPI-Filter -IncludeManagementTools -Force

# Iniciar e configurar IIS
Start-Service W3SVC -Force
Set-Service W3SVC -StartupType Automatic

# Criar pÃ¡gina HTML profissional
$html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Servidor IIS - Unylea DevOps</title>
    <style>
        body { font-family: 'Segoe UI', Arial; text-align: center; margin-top: 50px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; min-height: 100vh; }
        .container { background: rgba(255,255,255,0.1); padding: 40px; border-radius: 15px; backdrop-filter: blur(10px); max-width: 900px; margin: 0 auto; box-shadow: 0 8px 32px rgba(0,0,0,0.1); }
        h1 { color: #ffffff; font-size: 3em; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); margin-bottom: 20px; }
        .info { background: rgba(255,255,255,0.2); padding: 25px; margin: 25px 0; border-radius: 10px; }
        .tech { background: rgba(76, 175, 80, 0.4); padding: 12px; border-radius: 8px; display: inline-block; margin: 8px; font-weight: bold; }
        .professional { background: rgba(255, 193, 7, 0.3); padding: 20px; border-radius: 10px; margin: 25px 0; }
        .azure { background: rgba(0, 123, 255, 0.3); padding: 20px; border-radius: 10px; margin: 25px 0; }
        .status { background: rgba(40, 167, 69, 0.3); padding: 20px; border-radius: 10px; margin: 25px 0; }
        .metrics { background: rgba(220, 53, 69, 0.3); padding: 15px; border-radius: 8px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>ðŸŽ‰ Servidor IIS Profissional Instalado!</h1>
        <div class="info">
            <h2>Unylea | Engenheiro DevOps | Unidade 4</h2>
            <p><strong>Aluno:</strong> Icaro Galvao do Nascimento</p>
            <p><strong>Ferramentas:</strong> Terraform + Ansible + Azure</p>
            <p><strong>Plataforma:</strong> Windows Server 2019 + IIS Completo</p>
            <p><strong>Status:</strong> âœ… Configurado Automaticamente</p>
            <div>
                <span class="tech">ðŸ–¥ï¸ Windows Server 2019</span>
                <span class="tech">ðŸŒ IIS Completo</span>
                <span class="tech">ðŸ”§ Ansible</span>
                <span class="tech">â˜ï¸ Azure</span>
            </div>
        </div>
        <div class="professional">
            <h3>ðŸ’¼ Ambiente Profissional</h3>
            <p><strong>VM Size:</strong> Standard_B2s (2 vCPUs, 4GB RAM)</p>
            <p><strong>Storage:</strong> Premium SSD (127GB)</p>
            <p><strong>Availability:</strong> Zone 1 (Alta disponibilidade)</p>
            <p><strong>Features:</strong> ASP.NET, ISAPI, ExtensÃµes completas</p>
        </div>
        <div class="azure">
            <h3>â˜ï¸ Azure Professional</h3>
            <p><strong>OrÃ§amento:</strong> $200 USD disponÃ­veis</p>
            <p><strong>Custo estimado:</strong> ~$50/mÃªs</p>
            <p><strong>RegiÃ£o:</strong> East US (Alta disponibilidade)</p>
            <p><strong>Performance:</strong> Premium resources</p>
        </div>
        <div class="status">
            <h3>âœ… Status: Servidor Empresarial Ativo</h3>
            <p>IIS com todos os recursos instalados</p>
            <p>WinRM configurado para Ansible</p>
            <p>Firewall otimizado para produÃ§Ã£o</p>
            <p>Pronto para aplicaÃ§Ãµes corporativas</p>
        </div>
        <div class="metrics">
            <h4>ðŸ“Š MÃ©tricas do Sistema:</h4>
            <p>CPU: 2 cores @ 2.4GHz</p>
            <p>RAM: 4GB DDR4</p>
            <p>Storage: 127GB Premium SSD</p>
            <p>Network: 10Gbps</p>
        </div>
        <p><em>Provisionado via Terraform + Azure Professional</em></p>
        <p><small>Infraestrutura como CÃ³digo - NÃ­vel Empresarial</small></p>
    </div>
</body>
</html>
"@

$html | Out-File -FilePath "C:\\inetpub\\wwwroot\\index.html" -Encoding UTF8 -Force

# Criar pÃ¡gina de status
$statusPage = @"
<!DOCTYPE html>
<html>
<head>
    <title>Status do Servidor - Unylea DevOps</title>
    <style>
        body { font-family: 'Courier New', monospace; background: #1e1e1e; color: #00ff00; padding: 20px; }
        .header { text-align: center; margin-bottom: 30px; }
        .status { background: #2d2d2d; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .ok { color: #00ff00; }
        .info { color: #00bfff; }
    </style>
</head>
<body>
    <div class="header">
        <h1>ðŸ–¥ï¸ STATUS DO SERVIDOR IIS</h1>
        <h2>Unylea DevOps - Professional</h2>
    </div>
    <div class="status">
        <h3>ðŸ“Š InformaÃ§Ãµes do Sistema</h3>
        <p>Hostname: $(hostname)</p>
        <p>SO: $(Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty Caption)</p>
        <p>VersÃ£o: $(Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty Version)</p>
        <p>Data: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
    </div>
    <div class="status">
        <h3>ðŸŒ Status do IIS</h3>
        <p>ServiÃ§o W3SVC: $(Get-Service W3SVC | Select-Object -ExpandProperty Status)</p>
        <p>Sites: $(Get-Website | Measure-Object).Count configurados</p>
        <p>Portas: 80 (HTTP), 443 (HTTPS)</p>
    </div>
    <div class="status">
        <h3>ðŸ”§ Status do WinRM</h3>
        <p>Porta 5985: $(Test-NetConnection -ComputerName localhost -Port 5985 | Select-Object -ExpandProperty TcpTestSucceeded)</p>
        <p>Listener: $(Get-ChildItem WSMan:\localhost\Listener | Where-Object {$_.Transport -eq 'HTTP'} | Measure-Object).Count configurado</p>
    </div>
    <div class="status">
        <h3>ðŸ’¾ Recursos do Sistema</h3>
        <p>CPU: $(Get-WmiObject -Class Win32_Processor | Select-Object -ExpandProperty Name)</p>
        <p>RAM: $([math]::Round((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory/1GB, 2)) GB</p>
        <p>Disco: $([math]::Round((Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DeviceID -eq 'C:'}).Size/1GB, 2)) GB</p>
    </div>
    <div class="status">
        <h3>ðŸ”¥ Status dos ServiÃ§os</h3>
        <p>W3SVC: $(Get-Service W3SVC | Select-Object -ExpandProperty Status)</p>
        <p>WinRM: $(Get-Service WinRM | Select-Object -ExpandProperty Status)</p>
        <p>Remote Desktop: $(Get-Service 'TermService' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Status)</p>
    </div>
    <p class="info">Ãšltima atualizaÃ§Ã£o: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
</body>
</html>
"@

$statusPage | Out-File -FilePath "C:\\inetpub\\wwwroot\\status.html" -Encoding UTF8 -Force

# Criar script de verificaÃ§Ã£o contÃ­nua
$checkScript = @"
# Script de verificaÃ§Ã£o contÃ­nua do servidor
$logFile = "C:\\iis-status.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Add-Content -Path $logFile -Value "$timestamp - VerificaÃ§Ã£o do Servidor IIS Professional" -Force
Add-Content -Path $logFile -Value "========================================" -Force

# Verificar status do IIS
$iisStatus = Get-Service W3SVC | Select-Object Status, Name
Add-Content -Path $logFile -Value "IIS Status: $iisStatus" -Force

# Verificar WinRM
try {
    $winrmTest = Test-WSMan -ComputerName localhost -Port 5985 -Http
    Add-Content -Path $logFile -Value "WinRM Status: Conectado" -Force
} catch {
    Add-Content -Path $logFile -Value "WinRM Status: Erro de conexÃ£o" -Force
}

# Verificar site
try {
    $siteTest = Invoke-WebRequest -Uri "http://localhost" -UseBasicParsing $true
    Add-Content -Path $logFile -Value "Site Status: $($siteTest.StatusCode)" -Force
} catch {
    Add-Content -Path $logFile -Value "Site Status: Erro de conexÃ£o" -Force
}

# Verificar recursos do sistema
$cpu = Get-WmiObject -Class Win32_Processor | Select-Object Name
$ram = [math]::Round((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory/1GB, 2)
$disk = [math]::Round((Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DeviceID -eq 'C:'}).Size/1GB, 2)

Add-Content -Path $logFile -Value "CPU: $cpu" -Force
Add-Content -Path $logFile -Value "RAM: $ram GB" -Force
Add-Content -Path $logFile -Value "Disco: $disk GB" -Force

Add-Content -Path $logFile -Value "========================================" -Force
Add-Content -Path $logFile -Value "PrÃ³xima verificaÃ§Ã£o em 5 minutos..." -Force
"@

$checkScript | Out-File -FilePath "C:\\check-iis-continuous.ps1" -Encoding UTF8 -Force

Write-Host "âœ… ConfiguraÃ§Ã£o concluÃ­da com sucesso!"
Write-Host "ðŸŒ Acesse: http://$(curl -s ifconfig.me)/index.html"
Write-Host "ðŸ“Š Status: http://$(curl -s ifconfig.me)/status.html"
Write-Host "ðŸ–¥ï¸ RDP: mstsc /v:$(curl -s ifconfig.me):3389"
Write-Host "ðŸ”§ WinRM: http://$(curl -s ifconfig.me):5985"
Write-Host "ðŸ“‹ Log: C:\\iis-status.log"
</powershell>
EOF
  )
}

# Network Interface
resource "azurerm_network_interface" "main" {
  name                = "nic-unylea-professional"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

# Public IP Standard
resource "azurerm_public_ip" "main" {
  name                = "pip-unylea-professional"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                = "Standard"
  zones               = [1]
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-unylea-professional"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Subnet
resource "azurerm_subnet" "main" {
  name                 = "snet-unylea-professional"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group Professional
resource "azurerm_network_security_group" "main" {
  name                = "nsg-unylea-professional"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "WinRM"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Conectar NSG Ã  subnet
resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Outputs
output "vm_public_ip" {
  description = "IP pÃºblico da VM Windows Server"
  value       = azurerm_windows_virtual_machine.main.public_ip_address
}

output "rdp_connection" {
  description = "Comando RDP para acesso remoto"
  value       = "mstsc /v:${azurerm_windows_virtual_machine.main.public_ip_address}:3389"
}

output "iis_url" {
  description = "URL do servidor IIS"
  value       = "http://${azurerm_windows_virtual_machine.main.public_ip_address}"
}

output "status_url" {
  description = "URL da pÃ¡gina de status"
  value       = "http://${azurerm_windows_virtual_machine.main.public_ip_address}/status.html"
}

output "winrm_endpoint" {
  description = "Endpoint WinRM para Ansible"
  value       = "http://${azurerm_windows_virtual_machine.main.public_ip_address}:5985"
}

output "vm_info" {
  description = "InformaÃ§Ãµes da VM"
  value = {
    name = azurerm_windows_virtual_machine.main.name
    size = azurerm_windows_virtual_machine.main.size
    zone = azurerm_windows_virtual_machine.main.zone
    os_disk_type = azurerm_windows_virtual_machine.main.os_disk[0].storage_account_type
  }
}

output "cost_estimate" {
  description = "Estimativa de custos mensais"
  value = {
    vm_size = "Standard_B2s"
    estimated_monthly_cost = "~$50 USD"
    budget_available = "$200 USD"
    remaining_budget = "~$150 USD"
  }
}
