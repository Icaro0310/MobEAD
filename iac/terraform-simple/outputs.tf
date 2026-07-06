output "vm_public_ip" {
  description = "IP pÃºblico da VM Windows Server"
  value       = azurerm_windows_virtual_machine.main.public_ip_address
}

output "vm_name" {
  description = "Nome da VM"
  value       = azurerm_windows_virtual_machine.main.name
}

output "rdp_connection" {
  description = "Comando RDP"
  value       = "mstsc /v:${azurerm_windows_virtual_machine.main.public_ip_address}:3389"
}

output "winrm_endpoint" {
  description = "Endpoint WinRM HTTP"
  value       = "http://${azurerm_windows_virtual_machine.main.public_ip_address}:5985"
}

output "iis_url" {
  description = "URL do IIS apÃ³s instalaÃ§Ã£o"
  value       = "http://${azurerm_windows_virtual_machine.main.public_ip_address}"
}
