#!/bin/bash
# Script de instalação para Ubuntu + Nginx
echo "=== Instalando Nginx no Ubuntu ==="

# Atualizar sistema
apt-get update
apt-get upgrade -y

# Instalar Nginx
apt-get install -y nginx

# Habilitar Nginx
systemctl enable nginx
systemctl start nginx

# Criar página HTML personalizada
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Servidor Web - Unylea DevOps</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            text-align: center; 
            margin-top: 50px; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
            color: white; 
            min-height: 100vh; 
        } 
        .container { 
            background: rgba(255,255,255,0.1); 
            padding: 30px; 
            border-radius: 10px; 
            backdrop-filter: blur(10px); 
            max-width: 800px;
            margin: 0 auto;
        } 
        h1 { 
            color: #ffffff; 
            font-size: 2.5em; 
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3); 
        } 
        .info { 
            background: rgba(255,255,255,0.2); 
            padding: 20px; 
            margin: 20px 0; 
            border-radius: 5px; 
        } 
        .tech { 
            background: rgba(76, 175, 80, 0.3); 
            padding: 10px; 
            border-radius: 5px; 
            display: inline-block; 
            margin: 5px; 
        }
        .status {
            background: rgba(255, 193, 7, 0.3);
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎉 Servidor Web Instalado com Sucesso!</h1>
        <div class="info">
            <h2>Unylea | Engenheiro DevOps | Unidade 4</h2>
            <p><strong>Aluno:</strong> Icaro Galvao do Nascimento</p>
            <p><strong>Ferramentas:</strong> Terraform + Ansible + Azure</p>
            <p><strong>Plataforma:</strong> Ubuntu 18.04 + Nginx</p>
            <p><strong>Região:</strong> East US</p>
            <div>
                <span class="tech">🐧 Ubuntu 18.04</span>
                <span class="tech">🌐 Nginx</span>
                <span class="tech">☁️ Azure</span>
                <span class="tech">🔧 Terraform</span>
            </div>
        </div>
        <div class="status">
            <h3>✅ Status: Configurado Automaticamente</h3>
            <p>Servidor web funcionando perfeitamente!</p>
            <p>Pronto para Ansible configurar aplicações</p>
        </div>
        <p><em>Provisionado via Terraform + Custom Data</em></p>
        <p><small>Infraestrutura como Código - IaC</small></p>
    </div>
</body>
</html>
EOF

# Configurar Nginx
cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80;
    server_name _;

    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# Reiniciar Nginx
systemctl restart nginx

# Criar script de verificação
cat > /opt/check-web.sh << 'EOF'
#!/bin/bash
echo "=== Verificação do Servidor Web ==="
echo "Data: $(date)"
echo "Uptime: $(uptime)"
echo ""
echo "=== Status do Nginx ==="
systemctl status nginx
echo ""
echo "=== Teste de Conectividade ==="
curl -s http://localhost | head -10
echo ""
echo "=== Logs do Nginx ==="
tail -20 /var/log/nginx/access.log
EOF

chmod +x /opt/check-web.sh

# Instalar Apache2 (alternativa ao IIS)
apt-get install -y apache2

# Criar página Apache
cat > /var/www/html/apache-index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Apache2 - Unylea DevOps</title>
    <style>
        body { font-family: Arial; text-align: center; margin-top: 50px; background: #ff6b35; color: white; }
        .container { background: rgba(255,255,255,0.1); padding: 30px; border-radius: 10px; }
        h1 { font-size: 2.5em; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔥 Apache2 Server</h1>
        <h2>Unylea | Engenheiro DevOps</h2>
        <p>Servidor Apache funcionando!</p>
        <p><small>Alternativa ao IIS - mesmo resultado</small></p>
    </div>
</body>
</html>
EOF

# Configurar Apache
a2enmod rewrite
systemctl enable apache2
systemctl start apache2

echo "✅ Configuração concluída com sucesso!"
echo "🌐 Acesse http://$(curl -s ifconfig.me) para ver o servidor"
echo "📊 Execute /opt/check-web.sh para verificar status"
echo "🔥 Apache2 também disponível em http://$(curl -s ifconfig.me)/apache-index.html"