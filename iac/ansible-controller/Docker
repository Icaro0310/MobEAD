FROM python:3.11-slim

# Instalar Docker CLI + Ansible
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-client \
        ca-certificates \
        curl \
        gnupg && \
    # Instalar Docker CLI
    curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    rm get-docker.sh && \
    # Instalar Ansible + pywinrm
    pip install --no-cache-dir ansible-core pywinrm requests && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /ansible

COPY playbook-iis-docker-real.yml /ansible/
COPY inventory-docker.ini /ansible/

CMD ["ansible-playbook", "-i", "inventory-docker.ini", "playbook-iis-docker-real.yml", "-v"]