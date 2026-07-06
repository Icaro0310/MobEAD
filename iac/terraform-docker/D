FROM hashicorp/terraform:latest

WORKDIR /workspace

# Copiar arquivos Terraform
COPY main.tf /workspace/

# Comando padrao
CMD ["apply", "-auto-approve"]