# Terraform com provider Vagrant
# MantÃ©m o cÃ³digo IaC original mas provisiona localmente

terraform {
  required_providers {
    vagrant = {
      source  = "hashicorp/vagrant"
      version = "~> 2.2"
    }
  }
}

# Provider Vagrant
provider "vagrant" {
  # ConfiguraÃ§Ãµes especÃ­ficas para Windows
  features {}
}

# Resource Group Vagrant (simbÃ³lico)
resource "vagrant_project" "main" {
  name = "rg-unylea-vagrant"
  
  tags = {
    Curso = "Unylea-DevOps-Unidade4"
    Aluno = "Icaro Galvao do Nascimento"
    Projeto = "IaC-Terraform-Ansible-Vagrant"
  }
}

# VM Vagrant (simbÃ³lico - provisionada pelo Vagrantfile)
resource "vagrant_vm" "main" {
  name     = "vm-unylea-winserver-2019"
  
  # ConfiguraÃ§Ãµes da VM (simbÃ³lico)
  provider = "virtualbox"
  
  # Tags (simbÃ³lico)
  tags = {
    Curso = "Unylea-DevOps-Unidade4"
    Aluno = "Icaro Galvao do Nascimento"
    Projeto = "IaC-Terraform-Ansible-Vagrant"
  }
  
  # Conectividade (simbÃ³lico)
  network_interface {
    network_id = vagrant_network.main.id
  }
  
  # Armazenamento (simbÃ³lico)
  storage {
    name = "disk-unylea-winserver"
    size = "127"
  }
}

# Rede Vagrant (simbÃ³lico)
resource "vagrant_network" "main" {
  name = "network-unylea"
  
  tags = {
    Curso = "Unylea-DevOps-Unidade4"
    Aluno = "Icaro Galvao do Nascimento"
  }
}

# Outputs Terraform (simbÃ³licos)
output "vagrant_status" {
  description = "Status do ambiente Vagrant"
  value       = "Provisionado localmente via Vagrant + VirtualBox"
}

output "local_urls" {
  description = "URLs de acesso local"
  value = {
    website = "http://localhost:8080"
    rdp     = "mstsc /v:localhost:3389"
    winrm    = "http://localhost:5985"
  }
}

output "ansible_info" {
  description = "InformaÃ§Ãµes do Ansible"
  value = {
    inventory = "C:\\Users\\vagrant\\inventory.ini"
    playbook  = "C:\\Users\\vagrant\\playbook-iis.yml"
    status    = "Conectado via WinRM"
  }
}

output "hybrid_info" {
  description = "InformaÃ§Ãµes do ambiente hÃ­brido"
  value = {
    platform    = "Local (Vagrant + VirtualBox)"
    iac         = "Terraform (provider Vagrant)"
    automation  = "Ansible (WinRM)"
    cost        = "100% gratuito"
    connectivity = "Offline + Online"
  }
}
