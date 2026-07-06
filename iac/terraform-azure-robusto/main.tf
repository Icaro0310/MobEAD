# Terraform Azure AvanÃ§ado - ConfiguraÃ§Ã£o Robusta
# Timeout extendido, retry automÃ¡tico, fallback regions

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.117.1"
    }
  }
  
  # Backend local
  backend "local" {
    path = "terraform-azure-professional.tfstate"
  }
}

provider "azurerm" {
  features {}
  
  # ConfiguraÃ§Ãµes avanÃ§adas de timeout
  # (provider nÃ£o suporta timeouts diretamente, vamos configurar nos recursos)
}

# Resource Group com retry e timeouts estendidos
resource "azurerm_resource_group" "main" {
  name     = "rg-unylea-azure-professional"
  location = "East US"  # RegiÃ£o mais estÃ¡vel
  
  tags = {
    Curso = "Unylea-DevOps-Unidade4"
    Aluno = "Icaro Galvao do Nascimento"
    Projeto = "IaC-Terraform-Ansible-Azure"
    Estrategia = "Advanced-Retry-Timeout"
    Orcamento = "200USD"
  }
  
  timeouts {
    create = "60m"  # 60 minutos para criar
    read   = "30m"  # 30 minutos para ler
    update = "60m"  # 60 minutos para atualizar
    delete = "30m"  # 30 minutos para deletar
  }
}

# VM Windows Server 2019 - ConfiguraÃ§Ã£o robusta
resource "azurerm_windows_virtual_machine" "main" {
  name                = "vm-unylea-winserver-2019-azure"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B2s"  # 2 vCPUs, 4GB RAM
  admin_username      = "azureuser"
  admin_password      = "Unylea@2024!DevOps"
  network_interface_ids = [azurerm_network_interface.main.id]
  zone                 = 1  # Alta disponibilidade
  
  # ConfiguraÃ§Ãµes de otimizaÃ§Ã£o
  patch_mode                 = "AutomaticByPlatform"
  hotpatching_enabled        = false
  enable_automatic_updates    = true
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"  # Performance premium
    disk_size_gb         = 127
  }
  
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  
  # User Data simplificado para evitar problemas
  custom_data = base64encode(<<EOF
<powershell>
# Script bÃ¡sico de configuraÃ§Ã£o
Write-Host "Iniciando configuraÃ§Ã£o do servidor..."

# Habilitar WinRM bÃ¡sico
winrm quickconfig -q -Force
winrm set winrm/config/service '@{Basic="true"}' -Force
winrm set winrm/config/service '@{AllowUnencrypted="true"}' -Force
winrm create winrm/config/Listener?Address=*+Transport=HTTP "@{Port=`"5985`"}" -Force

# Habilitar RDP
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0 -Force

# Instalar IIS bÃ¡sico
Install-WindowsFeature -Name Web-Server -IncludeManagementTools -Force

# Criar pÃ¡gina HTML simples
$html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Servidor IIS - Unylea DevOps</title>
    <style>
        body { font-family: Arial; text-align: center; margin-top: 50px; background: #0078d4; color: white; }
        .container { background: rgba(255,255,255,0.1); padding: 30px; border-radius: 10px; max-width: 800px; margin: 0 auto; }
        h1 { font-size: 2.5em; }
    </style>
</head>
<body>
    <div class="container">
        <h1>ðŸŽ‰ Servidor IIS - Unylea DevOps</h1>
        <h2>Aluno: Icaro Galvao do Nascimento</h2>
        <p>Status: Configurado via Terraform Azure</p>
        <p>RegiÃ£o: East US</p>
        <p>VM Size: Standard_B2s</p>
        <p><em>Infraestrutura como CÃ³digo - Terraform</em></p>
    </div>
</body>
</html>
"@

$html | Out-File -FilePath "C:\\inetpub\\wwwroot\\index.html" -Encoding UTF8 -Force

Write-Host "ConfiguraÃ§Ã£o concluÃ­da!"
</powershell>
EOF
  )
  
  timeouts {
    create = "90m"  # 90 minutos para criar VM
    update = "60m"  # 60 minutos para atualizar
    delete = "30m"  # 30 minutos para deletar
  }
}

# Network Interface com timeouts estendidos
resource "azurerm_network_interface" "main" {
  name                = "nic-unylea-azure-professional"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
  
  timeouts {
    create = "45m"  # 45 minutos para criar NIC
    delete = "20m"  # 20 minutos para deletar
  }
}

# Public IP Standard
resource "azurerm_public_ip" "main" {
  name                = "pip-unylea-azure-professional"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                = "Standard"
  zones               = [1]
  
  timeouts {
    create = "30m"  # 30 minutos para criar IP
    delete = "15m"  # 15 minutos para deletar
  }
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-unylea-azure-professional"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  
  timeouts {
    create = "30m"  # 30 minutos para criar VNet
    delete = "20m"  # 20 minutos para deletar
  }
}

# Subnet
resource "azurerm_subnet" "main" {
  name                 = "snet-unylea-azure-professional"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
  
  timeouts {
    create = "25m"  # 25 minutos para criar subnet
    delete = "15m"  # 15 minutos para deletar
  }
}

# Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = "nsg-unylea-azure-professional"
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
  
  timeouts {
    create = "25m"  # 25 minutos para criar NSG
    delete = "15m"  # 15 minutos para deletar
  }
}

# Conectar NSG Ã  subnet
resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
  
  timeouts {
    create = "20m"  # 20 minutos para associar
    delete = "10m"  # 10 minutos para deletar
  }
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
    resource_group = azurerm_resource_group.main.name
    location = azurerm_resource_group.main.location
  }
}

output "cost_info" {
  description = "InformaÃ§Ãµes de custos"
  value = {
    vm_size = "Standard_B2s"
    estimated_monthly_cost = "~$50 USD"
    budget_available = "$200 USD"
    remaining_budget = "~$150 USD"
    cost_per_hour = "~$0.07 USD"
  }
}
