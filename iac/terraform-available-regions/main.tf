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
  skip_provider_registration = true
}

# Testar regiÃµes que aceitam novos clientes
locals {
  # RegiÃµes que geralmente aceitam novos clientes Free Tier
  available_regions = [
    "East US",          # EUA Leste (sempre disponÃ­vel)
    "East US 2",        # EUA Leste 2
    "Central US",       # EUA Central
    "North Europe",     # Irlanda (pode aceitar)
    "France Central",   # FranÃ§a (pode aceitar)
    "Germany West Central", # Alemanha (pode aceitar)
    "UK South",         # Reino Unido (pode aceitar)
    "Canada Central",  # CanadÃ¡
    "Japan East",       # JapÃ£o
    "Australia East",   # AustrÃ¡lia
  ]
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-unylea-available-${replace(var.region, " ", "")}"
  location = var.region
  
  tags = {
    Curso = "Unylea-DevOps-Unidade4"
    Aluno = "Icaro Galvao do Nascimento"
    Projeto = "IaC-Terraform-Ansible-Azure"
  }
}

# VM Windows Server 2019
resource "azurerm_windows_virtual_machine" "main" {
  name                = "vm-unylea-winserver-${replace(var.region, " ", "")}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size
  admin_username      = "azureuser"
  admin_password      = "Unylea@2024!DevOps"
  network_interface_ids = [azurerm_network_interface.main.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = "latest"
  }

  # User Data para WinRM e IIS
  custom_data = base64encode(<<EOF
<powershell>
# Configurar WinRM
winrm quickconfig -q
winrm set winrm/config/service '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/client '@{Basic="true"}'
winrm create winrm/config/Listener?Address=*+Transport=HTTP "@{Port=`"5985`"}"
New-NetFirewallRule -Name "WinRM-HTTP-In" -DisplayName "WinRM over HTTP" -Protocol TCP -LocalPort 5985 -Direction Inbound -Action Allow

# Habilitar RDP
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Instalar IIS
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

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
            <p><strong>RegiÃ£o:</strong> ${var.region}</p>
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
}

# Network Interface
resource "azurerm_network_interface" "main" {
  name                = "nic-unylea-winserver-${replace(var.region, " ", "")}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

# Public IP
resource "azurerm_public_ip" "main" {
  name                = "pip-unylea-winserver-${replace(var.region, " ", "")}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                = "Standard"
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-unylea-${replace(var.region, " ", "")}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Subnet
resource "azurerm_subnet" "main" {
  name                 = "snet-unylea-${replace(var.region, " ", "")}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = "nsg-unylea-winserver-${replace(var.region, " ", "")}"
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
}

# Conectar NSG Ã  subnet
resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Outputs
output "vm_public_ip" {
  description = "IP pÃºblico da VM"
  value       = azurerm_windows_virtual_machine.main.public_ip_address
}

output "rdp_connection" {
  description = "Comando RDP"
  value       = "mstsc /v:${azurerm_windows_virtual_machine.main.public_ip_address}:3389"
}

output "iis_url" {
  description = "URL do IIS"
  value       = "http://${azurerm_windows_virtual_machine.main.public_ip_address}"
}

output "winrm_endpoint" {
  description = "Endpoint WinRM"
  value       = "http://${azurerm_windows_virtual_machine.main.public_ip_address}:5985"
}

output "region" {
  description = "RegiÃ£o utilizada"
  value       = var.region
}

output "vm_size" {
  description = "Size da VM"
  value       = var.vm_size
}
