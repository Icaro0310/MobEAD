terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Testar diferentes regiÃµes atÃ© encontrar uma que funcione
locals {
  regions = [
    "West Europe",      # Ideal para Portugal
    "North Europe",     # Irlanda
    "France Central",   # FranÃ§a
    "Germany West Central", # Alemanha
    "UK South",         # Reino Unido
    "East US",          # EUA
    "East US 2",        # EUA
    "Central US",       # EUA
    "West US",          # EUA
    "West US 2",        # EUA
    "Canada Central",   # CanadÃ¡
    "Brazil South",     # Brasil
    "Japan East",       # JapÃ£o
    "Australia East",   # AustrÃ¡lia
  ]
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-unylea-test-${replace(var.region, " ", "")}"
  location = var.region
}

# VM - Testar diferentes images se Windows 2019 nÃ£o funcionar
resource "azurerm_windows_virtual_machine" "main" {
  name                = "vm-unylea-test-${replace(var.region, " ", "")}"
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

  # User Data para configurar WinRM e IIS
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

Write-Output "Configuracao concluida com sucesso."
</powershell>
EOF
  )
}

# Network Interface
resource "azurerm_network_interface" "main" {
  name                = "nic-unylea-test-${replace(var.region, " ", "")}"
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
  name                = "pip-unylea-test-${replace(var.region, " ", "")}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                = "Standard"
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-unylea-test-${replace(var.region, " ", "")}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Subnet
resource "azurerm_subnet" "main" {
  name                 = "snet-unylea-test-${replace(var.region, " ", "")}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = "nsg-unylea-test-${replace(var.region, " ", "")}"
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

output "vm_name" {
  description = "Nome da VM"
  value       = azurerm_windows_virtual_machine.main.name
}

output "region" {
  description = "RegiÃ£o testada"
  value       = var.region
}

output "vm_size" {
  description = "Size da VM"
  value       = var.vm_size
}

output "image_info" {
  description = "InformaÃ§Ãµes da imagem"
  value = "${var.image_publisher}:${var.image_offer}:${var.image_sku}"
}
