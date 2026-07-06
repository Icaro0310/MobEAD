# Terraform Otimizado para Portugal - VersÃ£o Final
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.117.1"  # VersÃ£o especÃ­fica estÃ¡vel
    }
  }
  
  # Backend local para evitar problemas de state
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# Resource Group com retry
resource "azurerm_resource_group" "main" {
  name     = "rg-unylea-final"
  location = "West Europe"  # Ideal para Portugal
  
  tags = {
    Curso = "Unylea-DevOps-Unidade4"
    Aluno = "Icaro Galvao do Nascimento"
    Projeto = "IaC-Terraform-Ansible-Azure"
  }
  
  timeouts {
    create = "30m"
    delete = "30m"
  }
}

# VM Windows Server 2019 - ConfiguraÃ§Ã£o otimizada
resource "azurerm_windows_virtual_machine" "main" {
  name                = "vm-unylea-winserver-2019"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1s"  # Free Tier
  admin_username      = "azureuser"
  admin_password      = "Unylea@2024!DevOps"
  network_interface_ids = [azurerm_network_interface.main.id]
  
  # ConfiguraÃ§Ãµes de otimizaÃ§Ã£o
  zone                 = 1  # Zona de disponibilidade
  patch_mode          = "AutomaticByOS"
  hotpatching_enabled  = false
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 127  # Size otimizado
  }
  
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  
  # User Data otimizado para Portugal
  custom_data = base64encode(<<EOF
<powershell>
# Configurar WinRM para Ansible
Set-ExecutionPolicy Unrestricted -Force
winrm quickconfig -q -Force
winrm set winrm/config/service '@{Basic="true"}' -Force
winrm set winrm/config/service '@{AllowUnencrypted="true"}' -Force
winrm set winrm/config/client '@{Basic="true"}' -Force
winrm create winrm/config/Listener?Address=*+Transport=HTTP "@{Port=`"5985`"}" -Force
New-NetFirewallRule -Name "WinRM-HTTP-In" -DisplayName "WinRM over HTTP" -Protocol TCP -LocalPort 5985 -Direction Inbound -Action Allow -Force

# Habilitar RDP
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0 -Force
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -Force

# Instalar IIS
Install-WindowsFeature -Name Web-Server -IncludeManagementTools -Force

# Criar pÃ¡gina HTML
$html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Servidor IIS - Unylea DevOps</title>
    <style>
        body { font-family: Arial; text-align: center; margin-top: 50px; }
        .container { background: #f0f0f0; padding: 30px; border-radius: 10px; }
        h1 { color: #0078d4; }
        .info { background: #e3f2fd; padding: 20px; margin: 20px 0; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>ðŸŽ‰ Servidor IIS Instalado com Sucesso!</h1>
        <div class="info">
            <h2>Unylea | Engenheiro DevOps | Unidade 4</h2>
            <p><strong>Aluno:</strong> Icaro Galvao do Nascimento</p>
            <p><strong>Ferramentas:</strong> Terraform + Ansible + Azure</p>
            <p><strong>RegiÃ£o:</strong> West Europe (Portugal)</p>
            <p><strong>Status:</strong> âœ… Configurado Automaticamente</p>
        </div>
        <p><em>Provisionado via Terraform + Ansible</em></p>
    </div>
</body>
</html>
"@
$html | Out-File -FilePath "C:\inetpub\wwwroot\index.html" -Encoding UTF8 -Force

Write-Output "Configuracao concluida com sucesso!"
</powershell>
EOF
  )
  
  timeouts {
    create = "45m"
    update = "30m"
    delete = "30m"
  }
}

# Network Interface otimizada
resource "azurerm_network_interface" "main" {
  name                = "nic-unylea-winserver"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
  
  tags = {
    Curso = "Unylea-DevOps-Unidade4"
    Aluno = "Icaro Galvao do Nascimento"
  }
  
  timeouts {
    create = "30m"
    delete = "30m"
  }
}

# Public IP Standard (sem limites)
resource "azurerm_public_ip" "main" {
  name                = "pip-unylea-winserver"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                = "Standard"  # Sem limites de Basic SKU
  zones               = [1]
  
  tags = {
    Curso = "Unylea-DevOps-Unidade4"
    Aluno = "Icaro Galvao do Nascimento"
  }
  
  timeouts {
    create = "20m"
    delete = "20m"
  }
}

# Virtual Network otimizado
resource "azurerm_virtual_network" "main" {
  name                = "vnet-unylea"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  
  tags = {
    Curso = "Unylea-DevOps-Unidade4"
    Aluno = "Icaro Galvao do Nascimento"
  }
  
  timeouts {
    create = "20m"
    delete = "20m"
  }
}

# Subnet otimizada
resource "azurerm_subnet" "main" {
  name                 = "snet-unylea"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
  
  timeouts {
    create = "20m"
    delete = "20m"
  }
}

# Network Security Group completo
resource "azurerm_network_security_group" "main" {
  name                = "nsg-unylea-winserver"
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
  
  tags = {
    Curso = "Unylea-DevOps-Unidade4"
    Aluno = "Icaro Galvao do Nascimento"
  }
  
  timeouts {
    create = "20m"
    delete = "20m"
  }
}

# Conectar NSG Ã  subnet
resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
  
  timeouts {
    create = "20m"
    delete = "20m"
  }
}

# Outputs completos
output "instance_public_ip" {
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

output "winrm_endpoint" {
  description = "Endpoint WinRM para Ansible"
  value       = "http://${azurerm_windows_virtual_machine.main.public_ip_address}:5985"
}

output "vm_name" {
  description = "Nome da VM criada"
  value       = azurerm_windows_virtual_machine.main.name
}

output "resource_group" {
  description = "Resource Group"
  value       = azurerm_resource_group.main.name
}

output "location" {
  description = "RegiÃ£o (otimizada para Portugal)"
  value       = azurerm_resource_group.main.location
}
