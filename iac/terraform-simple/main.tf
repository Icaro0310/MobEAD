terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-unylea-simple"
  location = "East US 2"

  tags = {
    Curso = "Unylea-DevOps-Unidade4"
    Aluno = "Icaro Galvao do Nascimento"
  }
}

# VM Simples - sem rede complexa
resource "azurerm_windows_virtual_machine" "main" {
  name                = "vm-unylea-simple"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = "Unylea@2024!AzureDevOps"
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

  # WinRM e IIS via custom data
  custom_data = base64encode(templatefile("${path.module}/simple-userdata.ps1", {
    admin_password = "Unylea@2024!AzureDevOps"
  }))

  tags = {
    Curso = "Unylea-DevOps-Unidade4"
    Aluno = "Icaro Galvao do Nascimento"
  }
}

# Network Interface simples
resource "azurerm_network_interface" "main" {
  name                = "nic-unylea-simple"
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
}

# Public IP simples
resource "azurerm_public_ip" "main" {
  name                = "pip-unylea-simple"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                = "Standard"

  tags = {
    Curso = "Unylea-DevOps-Unidade4"
    Aluno = "Icaro Galvao do Nascimento"
  }
}

# Virtual Network simples
resource "azurerm_virtual_network" "main" {
  name                = "vnet-unylea-simple"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Curso = "Unylea-DevOps-Unidade4"
    Aluno = "Icaro Galvao do Nascimento"
  }
}

# Subnet simples
resource "azurerm_subnet" "main" {
  name                 = "snet-unylea-simple"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group simples
resource "azurerm_network_security_group" "main" {
  name                = "nsg-unylea-simple"
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

  tags = {
    Curso = "Unylea-DevOps-Unidade4"
    Aluno = "Icaro Galvao do Nascimento"
  }
}

# Conectar NSG Ã  subnet
resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}
