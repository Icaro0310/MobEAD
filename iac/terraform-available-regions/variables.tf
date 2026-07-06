# VariÃ¡veis para teste de regiÃµes disponÃ­veis
variable "region" {
  description = "RegiÃ£o Azure para testar"
  type        = string
  default     = "East US"  # ComeÃ§ar com EUA (sempre disponÃ­vel)
}

variable "vm_size" {
  description = "Size da VM (Free Tier)"
  type        = string
  default     = "Standard_B1s"
}

variable "image_publisher" {
  description = "Publisher da imagem"
  type        = string
  default     = "MicrosoftWindowsServer"
}

variable "image_offer" {
  description = "Offer da imagem"
  type        = string
  default     = "WindowsServer"
}

variable "image_sku" {
  description = "SKU da imagem"
  type        = string
  default     = "2019-Datacenter"
}
