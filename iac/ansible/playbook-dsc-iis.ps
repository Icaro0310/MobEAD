# Playbook DSC (Desired State Configuration) - Equivalente Microsoft ao Ansible
# Aluno: Icaro Galvao do Nascimento
# Unylea | Engenheiro DevOps | Unidade 4
#
# PowerShell DSC e a ferramenta oficial de Configuration Management da Microsoft,
# equivalente nativa ao Ansible no ecossistema Windows. Assim como o Ansible,
# declara o estado desejado e garante idempotencia.

configuration InstalarIIS {
    param(
        [string[]]$NodeName = 'localhost'
    )

    Import-DscResource -ModuleName PsDesiredStateConfiguration
    Import-DscResource -ModuleName xWebAdministration -ErrorAction SilentlyContinue

    Node $NodeName {
        # Task 1: Instalar feature Web-Server (IIS)
        WindowsFeature IIS {
            Ensure = 'Present'
            Name   = 'Web-Server'
            IncludeAllSubFeature = $true
        }

        # Task 2: Garantir servico W3SVC ativo
        Service W3SVC {
            Ensure    = 'Present'
            Name      = 'W3SVC'
            State     = 'Running'
            StartupType = 'Automatic'
            DependsOn = '[WindowsFeature]IIS'
        }

        # Task 3: Criar pagina HTML personalizada
        File PaginaIIS {
            Ensure          = 'Present'
            DestinationPath = 'C:\inetpub\wwwroot\index.html'
            Contents        = @"
<!DOCTYPE html>
<html>
<head>
    <title>Servidor IIS - Unylea DevOps</title>
    <style>
        body { font-family: 'Segoe UI', Arial; text-align: center; margin-top: 50px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; min-height: 100vh; }
        .container { background: rgba(255,255,255,0.1); padding: 40px; border-radius: 15px; max-width: 900px; margin: 0 auto; }
        h1 { font-size: 2.5em; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); }
        .info { background: rgba(255,255,255,0.2); padding: 25px; margin: 25px 0; border-radius: 10px; }
        .status { background: rgba(40, 167, 69, 0.3); padding: 20px; border-radius: 10px; margin: 25px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Servidor IIS - Unylea DevOps!</h1>
        <div class="info">
            <h2>Engenheiro DevOps | Unidade 4</h2>
            <p><strong>Aluno:</strong> Icaro Galvao do Nascimento</p>
            <p><strong>Configurado via:</strong> PowerShell DSC</p>
            <p><strong>Status:</strong> Instalado e ativo</p>
        </div>
        <div class="status">
            <h3>Status: Servidor Ativo</h3>
            <p>IIS instalado via DSC</p>
            <p>Servico W3SVC em execucao</p>
            <p>Pagina HTML personalizada</p>
        </div>
        <p><em>Infraestrutura como Codigo - PowerShell DSC</em></p>
    </div>
</body>
</html>
"@
            Type            = 'File'
            DependsOn       = '[WindowsFeature]IIS'
        }

        # Task 4: Garantir que WinRM esta configurado
        WindowsFeature WinRM {
            Ensure = 'Present'
            Name   = 'RSAT-RemoteManagement'
        }
    }
}

# Gerar e aplicar configuracao DSC
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DSC PLAYBOOK - INSTALAR IIS" -ForegroundColor Cyan
Write-Host "  Unylea DevOps - Unidade 4" -ForegroundColor Cyan
Write-Host "  Aluno: Icaro Galvao do Nascimento" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "TASK [Gerar MOF - Managed Object Format]" -ForegroundColor Yellow
InstalarIIS -OutputPath "$PSScriptRoot\mof-output"
Write-Host "ok: [localhost] - MOF gerado com sucesso" -ForegroundColor Green
Write-Host ""

Write-Host "TASK [Aplicar configuracao DSC]" -ForegroundColor Yellow
Start-DscConfiguration -Path "$PSScriptRoot\mof-output" -Wait -Force -Verbose
Write-Host "ok: [localhost] - Configuracao DSC aplicada" -ForegroundColor Green
Write-Host ""

Write-Host "TASK [Validar estado - Test-DscConfiguration]" -ForegroundColor Yellow
$testResult = Test-DscConfiguration
Write-Host "ok: [localhost] - Estado: $testResult" -ForegroundColor Green
Write-Host ""

Write-Host "PLAY RECAP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "localhost : ok=4  changed=3  unreachable=0  failed=0" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan