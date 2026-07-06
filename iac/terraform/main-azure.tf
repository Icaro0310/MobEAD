# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Curso    = "Unylea-DevOps-Unidade4"
    Aluno    = "Icaro Galvao do Nascimento"
    Projeto  = "IaC-Terraform-Ansible-Azure"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-unylea"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Curso   = "Unylea-DevOps-Unidade4"
    Aluno   = "Icaro Galvao do Nascimento"
  }
}

# Subnet
resource "azurerm_subnet" "main" {
  name                 = "snet-unylea"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group (libera RDP, HTTP, WinRM)
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
    name                       = "HTTP"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "WinRM-HTTP"
    priority                   = 1200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Curso   = "Unylea-DevOps-Unidade4"
    Aluno   = "Icaro Galvao do Nascimento"
  }
}

# Public IP
resource "azurerm_public_ip" "main" {
  name                = "pip-unylea-winserver"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                = "Basic"

  tags = {
    Curso   = "Unylea-DevOps-Unidade4"
    Aluno   = "Icaro Galvao do Nascimento"
  }
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

  tags = {
    Curso   = "Unylea-DevOps-Unidade4"
    Aluno   = "Icaro Galvao do Nascimento"
  }
}

# Windows Server 2019 VM
resource "azurerm_windows_virtual_machine" "main" {
  name                  = var.vm_name
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
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

  # Custom extension para configurar WinRM e IIS
  custom_data = base64encode(templatefile("${path.module}/userdata-azure.ps1", {
    admin_password = var.admin_password
  }))

  tags = {
    Curso   = "Unylea-DevOps-Unidade4"
    Aluno   = "Icaro Galvao do Nascimento"
  }
}
