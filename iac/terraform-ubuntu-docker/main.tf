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
  name     = "rg-unylea-ubuntu-iis"
  location = "East US"
  
  tags = {
    Curso = "Unylea-DevOps-Unidade4"
    Aluno = "Icaro Galvao do Nascimento"
    Projeto = "IaC-Terraform-Ansible-Azure"
  }
}

# VM Ubuntu (mais leve e rÃ¡pida)
resource "azurerm_linux_virtual_machine" "main" {
  name                = "vm-unylea-ubuntu-iis"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.main.id]
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # Custom Data para instalar Docker + IIS
  custom_data = base64encode(<<EOF
#!/bin/bash
# Atualizar sistema
apt-get update
apt-get upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl enable docker
systemctl start docker

# Instalar Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Criar diretÃ³rio para IIS
mkdir -p /opt/iis-container

# Criar Dockerfile para IIS
cat > /opt/iis-container/Dockerfile << 'EOF'
FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019
LABEL maintainer="Icaro Galvao do Nascimento"
LABEL description="IIS Server para Unylea DevOps"

# Copiar pÃ¡gina HTML personalizada
COPY index.html /inetpub/wwwroot/

# Expor porta 80
EXPOSE 80

CMD ["cmd", "/c", "ping -t localhost"]
EOF

# Criar pÃ¡gina HTML
cat > /opt/iis-container/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Servidor IIS - Unylea DevOps</title>
    <style>
        body { font-family: Arial; text-align: center; margin-top: 50px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; min-height: 100vh; }
        .container { background: rgba(255,255,255,0.1); padding: 30px; border-radius: 10px; backdrop-filter: blur(10px); }
        h1 { color: #ffffff; font-size: 2.5em; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); }
        .info { background: rgba(255,255,255,0.2); padding: 20px; margin: 20px 0; border-radius: 5px; }
        .tech { background: rgba(76, 175, 80, 0.3); padding: 10px; border-radius: 5px; display: inline-block; margin: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>ðŸŽ‰ Servidor IIS Instalado com Sucesso!</h1>
        <div class="info">
            <h2>Unylea | Engenheiro DevOps | Unidade 4</h2>
            <p><strong>Aluno:</strong> Icaro Galvao do Nascimento</p>
            <p><strong>Ferramentas:</strong> Terraform + Docker + Azure</p>
            <p><strong>Plataforma:</strong> Ubuntu + Docker Container + IIS</p>
            <p><strong>Status:</strong> âœ… Configurado Automaticamente</p>
            <div>
                <span class="tech">ðŸ§ Ubuntu 18.04</span>
                <span class="tech">ðŸ³ Docker</span>
                <span class="tech">ðŸŒ IIS</span>
                <span class="tech">â˜ï¸ Azure</span>
            </div>
        </div>
        <p><em>Provisionado via Terraform + Docker</em></p>
        <p><small>Container Windows Server Core com IIS rodando em Ubuntu via Docker</small></p>
    </div>
</body>
</html>
EOF

# Criar docker-compose.yml
cat > /opt/iis-container/docker-compose.yml << 'EOF'
version: '3.8'

services:
  iis-server:
    build: .
    container_name: unylea-iis
    ports:
      - "80:80"
    restart: unless-stopped
    networks:
      - iis-network

networks:
  iis-network:
    driver: bridge
EOF

# Iniciar os containers
cd /opt/iis-container
docker-compose up -d

# Instalar nginx como proxy (opcional)
apt-get install -y nginx

# Configurar nginx para proxy
cat > /etc/nginx/sites-available/iis << 'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Habilitar site
ln -s /etc/nginx/sites-available/iis /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

# Reiniciar nginx
systemctl restart nginx

# Criar script de verificaÃ§Ã£o
cat > /opt/check-iis.sh << 'EOF'
#!/bin/bash
echo "=== VerificaÃ§Ã£o do Servidor IIS ==="
echo "Data: $(date)"
echo "Uptime: $(uptime)"
echo ""
echo "=== Status dos Containers ==="
docker ps
echo ""
echo "=== Teste de Conectividade ==="
curl -s http://localhost | head -10
echo ""
echo "=== Logs dos Containers ==="
docker logs unylea-iis --tail 20
EOF

chmod +x /opt/check-iis.sh

echo "âœ… ConfiguraÃ§Ã£o concluÃ­da com sucesso!"
echo "ðŸŒ Acesse http://$(curl -s ifconfig.me) para ver o IIS"
echo "ðŸ“Š Execute /opt/check-iis.sh para verificar status"
EOF
  )
}

# Network Interface
resource "azurerm_network_interface" "main" {
  name                = "nic-unylea-ubuntu-iis"
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
  name                = "pip-unylea-ubuntu-iis"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                = "Standard"
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-unylea-ubuntu-iis"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Subnet
resource "azurerm_subnet" "main" {
  name                 = "snet-unylea-ubuntu-iis"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = "nsg-unylea-ubuntu-iis"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
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
}

# Conectar NSG Ã  subnet
resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Outputs
output "vm_public_ip" {
  description = "IP pÃºblico da VM Ubuntu"
  value       = azurerm_linux_virtual_machine.main.public_ip_address
}

output "ssh_connection" {
  description = "Comando SSH para acesso"
  value       = "ssh azureuser@${azurerm_linux_virtual_machine.main.public_ip_address}"
}

output "iis_url" {
  description = "URL do servidor IIS"
  value       = "http://${azurerm_linux_virtual_machine.main.public_ip_address}"
}

output "check_command" {
  description = "Comando para verificar status"
  value       = "ssh azureuser@${azurerm_linux_virtual_machine.main.public_ip_address} '/opt/check-iis.sh'"
}
