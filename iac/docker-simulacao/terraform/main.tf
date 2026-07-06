# Terraform para Docker SimulaÃ§Ã£o
# Provider Docker para gerenciar containers

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# Rede Docker
resource "docker_network" "unylea_network" {
  name = "unylea-network"
  driver = "bridge"
  ipam_config {
    subnet = "172.20.0.0/16"
  }
}

# Container Windows Server (simulado)
resource "docker_container" "windows_server" {
  name  = "vm-unylea-winserver-2019"
  image = "nginx:alpine"  # Usando nginx como proxy
  
  ports {
    internal = 80
    external = 8080
  }
  
  ports {
    internal = 443
    external = 443
  }
  
  ports {
    internal = 5985
    external = 5985
  }
  
  volumes {
    container_path = "/usr/share/nginx/html"
    host_path      = "${path.cwd}/html"
  }
  
  networks_advanced {
    name = docker_network.unylea_network.name
  }
  
  restart = "unless-stopped"
  
  labels = {
    "curso" = "Unylea-DevOps-Unidade4"
    "aluno" = "Icaro Galvao do Nascimento"
    "projeto" = "IaC-Terraform-Ansible-Docker"
  }
}

# Container Ansible Controller
resource "docker_container" "ansible_controller" {
  name  = "ansible-unylea-controller"
  image = "python:3.9-slim"
  
  ports {
    internal = 22
    external = 2222
  }
  
  volumes {
    container_path = "/ansible"
    host_path      = "${path.cwd}/ansible"
  }
  
  networks_advanced {
    name = docker_network.unylea_network.name
  }
  
  command = [
    "sh", "-c",
    "apt-get update && apt-get install -y openssh-server ansible python3-pip && pip install pywinrm && service ssh start && echo 'root:unylea2024' | chpasswd && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && service ssh restart && tail -f /dev/null"
  ]
  
  labels = {
    "curso" = "Unylea-DevOps-Unidade4"
    "aluno" = "Icaro Galvao do Nascimento"
  }
}

# Container Terraform Controller
resource "docker_container" "terraform_controller" {
  name  = "terraform-unylea-controller"
  image = "hashicorp/terraform:latest"
  
  volumes {
    container_path = "/terraform"
    host_path      = "${path.cwd}/terraform"
  }
  
  networks_advanced {
    name = docker_network.unylea_network.name
  }
  
  command = [
    "sh", "-c",
    "echo '=== Terraform Controller ===' && echo 'ðŸ“¦ Terraform instalado: $(terraform version)' && echo 'ðŸ”§ DiretÃ³rio de trabalho: /terraform' && echo 'âœ… Terraform pronto para uso' && tail -f /dev/null"
  ]
  
  labels = {
    "curso" = "Unylea-DevOps-Unidade4"
    "aluno" = "Icaro Galvao do Nascimento"
  }
}

# Container Nginx Proxy
resource "docker_container" "nginx_proxy" {
  name  = "nginx-unylea-proxy"
  image = "nginx:alpine"
  
  ports {
    internal = 80
    external = 80
  }
  
  ports {
    internal = 443
    external = 443
  }
  
  volumes {
    container_path = "/etc/nginx/nginx.conf"
    host_path      = "${path.cwd}/nginx.conf"
  }
  
  networks_advanced {
    name = docker_network.unylea_network.name
  }
  
  depends_on = [
    docker_container.windows_server
  ]
  
  restart = "unless-stopped"
  
  labels = {
    "curso" = "Unylea-DevOps-Unidade4"
    "aluno" = "Icaro Galvao do Nascimento"
  }
}

# Outputs
output "docker_status" {
  description = "Status dos containers Docker"
  value = "Ambiente Docker configurado com sucesso"
}

output "urls_acesso" {
  description = "URLs de acesso"
  value = {
    servidor_iis = "http://localhost:8080"
    proxy_nginx = "http://localhost"
    ansible_ssh = "ssh root@localhost -p 2222"
  }
}

output "containers_info" {
  description = "InformaÃ§Ãµes dos containers"
  value = {
    windows_server = docker_container.windows_server.name
    ansible_controller = docker_container.ansible_controller.name
    terraform_controller = docker_container.terraform_controller.name
    nginx_proxy = docker_container.nginx_proxy.name
  }
}

output "network_info" {
  description = "InformaÃ§Ãµes da rede"
  value = {
    network_name = docker_network.unylea_network.name
    subnet = "172.20.0.0/16"
    driver = "bridge"
  }
}
