variable "location" {
  description = "RegiÃ£o Azure"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
  default     = "rg-unylea-devops-icaro"
}

variable "vm_name" {
  description = "Nome da VM Windows Server"
  type        = string
  default     = "vm-unylea-winserver-2019"
}

variable "vm_size" {
  description = "Tamanho da VM (B1s Ã© free tier)"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "UsuÃ¡rio administrador"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Senha do administrador"
  type        = string
  sensitive   = true
  default     = "Unylea@2024!AzureDevOps"
}
