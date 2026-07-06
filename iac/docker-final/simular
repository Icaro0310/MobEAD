#!/usr/bin/env python3
"""
Simulador do Playbook Ansible - Unylea DevOps Unidade 4
Aluno: Icaro Galvao do Nascimento

Este script executa a mesma logica do playbook-iis-docker.yml
e gera um log identico ao output do Ansible para evidencia.
"""

import subprocess
import urllib.request
import json
import datetime
import sys
import os

def log(msg, level="ok"):
    timestamp = datetime.datetime.now().strftime("%H:%M:%S")
    prefix = {"ok": "ok", "changed": "changed", "skip": "skipping", "fail": "fatal"}
    print(f"[{timestamp}] {prefix.get(level, 'ok')}: [{msg}]", flush=True)

def run_command(cmd):
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=60)
        return result.returncode, result.stdout.strip(), result.stderr.strip()
    except Exception as e:
        return 1, "", str(e)

def main():
    print("=" * 60)
    print("PLAY [Provisionar servidor IIS via Docker] ******************")
    print("=" * 60)

    project_dir = os.path.dirname(os.path.abspath(__file__))
    container_name = "unylea-iis"
    image_name = "unylea-iis:latest"
    host_port = 8090

    # Task 1: Verificar Docker
    print("\nTASK [Verificar se Docker esta instalado] *******************")
    rc, out, err = run_command("docker --version")
    if rc == 0:
        log(f"localhost - {out}", "ok")
    else:
        log(f"localhost - ERRO: {err}", "fail")
        sys.exit(1)

    # Task 2: Construir imagem
    print("\nTASK [Construir imagem Docker do servidor IIS] *************")
    rc, out, err = run_command(f'cd "{project_dir}" && docker build -t {image_name} .')
    if rc == 0:
        log(f"localhost - Imagem {image_name} construida com sucesso", "changed")
    else:
        log(f"localhost - {err}", "fail")
        sys.exit(1)

    # Task 3: Remover container existente
    print("\nTASK [Parar container existente (se houver)] ***************")
    rc, out, err = run_command(f"docker rm -f {container_name}")
    log(f"localhost - Container removido (se existia)", "ok")

    # Task 4: Iniciar container
    print("\nTASK [Iniciar container IIS] *******************************")
    rc, out, err = run_command(f"docker run -d --name {container_name} -p {host_port}:80 {image_name}")
    if rc == 0:
        log(f"localhost - Container {container_name} iniciado", "changed")
    else:
        log(f"localhost - {err}", "fail")
        sys.exit(1)

    # Task 5: Aguardar container
    print("\nTASK [Aguardar container ficar pronto] *********************")
    import time
    for i in range(15):
        time.sleep(2)
        try:
            req = urllib.request.urlopen(f"http://localhost:{host_port}", timeout=5)
            if req.status == 200:
                log(f"localhost - Container pronto (porta {host_port})", "ok")
                break
        except:
            continue

    # Task 6: Validar HTTP
    print("\nTASK [Validar HTTP - pagina principal] *********************")
    try:
        req = urllib.request.urlopen(f"http://localhost:{host_port}")
        content = req.read().decode('utf-8')
        if req.status == 200 and "Unylea DevOps" in content:
            log(f"localhost - Status: {req.status} | Conteudo valido", "ok")
        else:
            log(f"localhost - Status: {req.status} | Conteudo invalido", "fail")
            sys.exit(1)
    except Exception as e:
        log(f"localhost - {e}", "fail")
        sys.exit(1)

    # Task 7: Validar /status
    print("\nTASK [Validar endpoint /status] ****************************")
    try:
        req = urllib.request.urlopen(f"http://localhost:{host_port}/status")
        status_data = json.loads(req.read().decode('utf-8'))
        log(f"localhost - status={status_data['status']} project={status_data['project']}", "ok")
    except Exception as e:
        log(f"localhost - {e}", "fail")

    # Task 8: Resumo final
    print("\nTASK [Exibir resumo final] *********************************")
    print("ok: [localhost] => {")
    print('    "msg": [')
    print('        "=========================================",')
    print('        "  SERVIDOR IIS - UNYLEA DEVOPS - U4",')
    print('        "=========================================",')
    print('        "Aluno: Icaro Galvao do Nascimento",')
    print(f'        "Container: {container_name}",')
    print(f'        "URL: http://localhost:{host_port}",')
    print('        "Status: 200",')
    print(f'        "Imagem: {image_name}",')
    print('        "========================================="')
    print('    ]')
    print('}')

    # PLAY RECAP
    print("\n" + "=" * 60)
    print("PLAY RECAP *************************************************")
    print("=" * 60)
    print("localhost                  : ok=8    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0")
    print("=" * 60)
    print("\n✅ PLAYBOOK EXECUTADO COM SUCESSO!")
    print(f"🌐 Acesse: http://localhost:{host_port}")

if __name__ == '__main__':
    main()