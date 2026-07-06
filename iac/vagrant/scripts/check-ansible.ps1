# Script de verificaÃ§Ã£o do Ansible
Write-Host "=== VerificaÃ§Ã£o do Ansible + IIS ==="

# Verificar instalaÃ§Ã£o do Ansible
try {
    $ansibleVersion = ansible --version
    Write-Host "âœ… Ansible instalado: $ansibleVersion"
} catch {
    Write-Host "âŒ Ansible nÃ£o encontrado"
    exit 1
}

# Verificar conectividade WinRM
try {
    $winrmTest = Test-WSMan -ComputerName localhost -Port 5985 -Http -Authentication Basic -Credential (New-Object System.Management.Automation.PSCredential("vagrant", "Unylea@2024!DevOps"))
    Write-Host "âœ… WinRM conectado com sucesso"
} catch {
    Write-Host "âŒ Erro na conexÃ£o WinRM"
    Write-Host "Verifique se o serviÃ§o WinRM estÃ¡ rodando"
}

# Verificar status do IIS
try {
    $iisStatus = Get-Service W3SVC | Select-Object Status, Name
    Write-Host "âœ… Status do IIS: $iisStatus"
} catch {
    Write-Host "âŒ Erro ao verificar status do IIS"
}

# Verificar site
try {
    $siteTest = Invoke-WebRequest -Uri "http://localhost:8080" -UseBasicParsing $true
    Write-Host "âœ… Site respondendo: $($siteTest.StatusCode)"
} catch {
    Write-Host "âŒ Erro no acesso ao site"
}

# Verificar pÃ¡gina Ansible
if (Test-Path "C:\inetpub\wwwroot\index-ansible.html") {
    Write-Host "âœ… PÃ¡gina Ansible criada com sucesso"
} else {
    Write-Host "âŒ PÃ¡gina Ansible nÃ£o encontrada"
}

Write-Host ""
Write-Host "=== URLs de Acesso ==="
Write-Host "ðŸŒ Site principal: http://localhost:8080"
Write-Host "ðŸŒ PÃ¡gina Ansible: http://localhost:8080/index-ansible.html"
Write-Host "ðŸ–¥ï¸ RDP: mstsc /v:localhost:3389"
Write-Host "ðŸ”§ WinRM: http://localhost:5985"
Write-Host ""
Write-Host "=== Logs de VerificaÃ§Ã£o ==="
Write-Host "ðŸ“‹ Log Ansible: C:\ansible-status.log"
Write-Host "ðŸ“‹ Log contÃ­nuo: C:\check-ansible-continuous.ps1"
Write-Host "ðŸ“‹ VerificaÃ§Ã£o manual: C:\check-ansible.ps1"
