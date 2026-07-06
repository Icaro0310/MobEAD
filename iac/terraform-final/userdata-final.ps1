<powershell>
# Configurar senha do Administrador
$AdminPassword = "${admin_password}"
$SecurePassword = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
Get-LocalUser -Name "azureuser" | Set-LocalUser -Password $SecurePassword
Enable-LocalUser -Name "azureuser"

# Configurar WinRM para Ansible
winrm quickconfig -q
winrm set winrm/config/service '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/client '@{Basic="true"}'
winrm create winrm/config/Listener?Address=*+Transport=HTTP "@{Port=`"5985`"}"
New-NetFirewallRule -Name "WinRM-HTTP-In" -DisplayName "WinRM over HTTP" -Protocol TCP -LocalPort 5985 -Direction Inbound -Action Allow
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
Restart-Service WinRM -Force

# Habilitar RDP
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Instalar IIS bÃ¡sico
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

Write-Output "WinRM e IIS configurados com sucesso."
</powershell>
<persist>true</persist>
