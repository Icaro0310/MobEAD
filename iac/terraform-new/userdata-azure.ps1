<powershell>
# Configurar senha do Administrador
$AdminPassword = "${admin_password}"
$SecurePassword = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
Get-LocalUser -Name "azureuser" | Set-LocalUser -Password $SecurePassword
Enable-LocalUser -Name "azureuser"

# Configurar WinRM para Ansible (HTTP - mais simples que HTTPS)
# 1. Habilitar WinRM
winrm quickconfig -q

# 2. Configurar autenticacao basic
winrm set winrm/config/service '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/client '@{Basic="true"}'

# 3. Criar listener WinRM HTTP
winrm create winrm/config/Listener?Address=*+Transport=HTTP "@{Port=`"5985`"}"

# 4. Abrir firewall para WinRM HTTP
New-NetFirewallRule -Name "WinRM-HTTP-In" -DisplayName "WinRM over HTTP" -Protocol TCP -LocalPort 5985 -Direction Inbound -Action Allow

# 5. Aumentar timeout
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'
winrm set winrm/config '@{MaxTimeoutms="1800000"}'

# 6. Reiniciar servico WinRM
Restart-Service WinRM -Force

# 7. Habilitar RDP
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# 8. Instalar IIS (pre-instalacao basica)
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

Write-Output "WinRM e IIS configurados com sucesso."
</powershell>
<persist>true</persist>
