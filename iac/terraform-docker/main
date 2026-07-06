terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Imagem Docker Nginx (simula Windows Server + IIS)
resource "docker_image" "iis" {
  name         = "unylea-iis:latest"
  keep_locally = true
}

# Container IIS - provisionado via Terraform
resource "docker_container" "iis" {
  name  = "unylea-iis-terraform"
  image = docker_image.iis.image_id
  restart = "unless-stopped"

  ports {
    internal = 80
    external = 8091
  }

  labels {
    label = "project"
    value = "unylea-devops-u4"
  }

  labels {
    label = "student"
    value = "icaro-galvao"
  }

  labels {
    label = "provisioned_by"
    value = "terraform"
  }
}

output "container_name" {
  value = docker_container.iis.name
}

output "container_id" {
  value = docker_container.iis.id
}

output "iis_url" {
  value = "http://localhost:8091"
}

output "iis_port" {
  value = docker_container.iis.ports[0].external
}