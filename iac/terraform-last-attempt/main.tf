# VersÃ£o MINIMAL para projeto acadÃªmico - Seguindo script original
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

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-unylea-devops"
  location = "West Europe"
}

# VM Windows Server 2019
resource "azurerm_windows_virtual_machine" "main" {
  name                = "vm-unylea-winserver-2019"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = "Unylea@2024!DevOps"
  network_interface_ids = [azurerm_network_interface.main.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  # User Data para configurar WinRM e IIS automaticamente
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
  name                = "nic-unylea-winserver"
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
  name                = "pip-unylea-winserver"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                = "Standard"
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-unylea"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Subnet
resource "azurerm_subnet" "main" {
  name                 = "snet-unylea"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group
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
}

# Conectar NSG Ã  subnet
resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Outputs (seguindo script original)
output "instance_public_ip" {
  description = "IP pÃºblico da VM Windows Server"
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
  description = "Endpoint WinRM HTTP"
  value       = "http://${azurerm_windows_virtual_machine.main.public_ip_address}:5985"
}
