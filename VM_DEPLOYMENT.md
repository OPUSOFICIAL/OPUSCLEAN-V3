# Deployment em VM - PostgreSQL Puro

## Resumo Executivo

Este guia cobre o deployment do Acelera Full Facilities em uma VM com PostgreSQL standalone (não Neon Serverless).

## ✅ Status da Migração

- **Código:** 100% compatível com PostgreSQL puro (`pg` driver)
- **Dump disponível:** `attached_assets/database-dump-vm-20251112.sql` (555KB)
- **Dependências:** Limpas (Neon apenas como dep opcional do drizzle-orm)
- **Documentação:** Atualizada em DOCUMENTACAO_TECNICA.md seções 3.6 e 3.7

## Pré-requisitos da VM

### 1. PostgreSQL 12+
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install postgresql postgresql-contrib

# CentOS/RHEL
sudo yum install postgresql-server postgresql-contrib
sudo postgresql-setup initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### 2. Node.js 18+
```bash
# Via NodeSource
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install nodejs

# Verificar
node --version
npm --version
```

### 3. Git
```bash
sudo apt install git
```

## Setup do Banco de Dados

### 1. Criar Usuário e Database
```sql
-- Conectar como postgres
sudo -u postgres psql

-- Criar usuário
CREATE USER acelera_user WITH PASSWORD 'SuaSenhaForte123!';

-- Criar database
CREATE DATABASE acelera_prod OWNER acelera_user;

-- Conceder privilégios
GRANT ALL PRIVILEGES ON DATABASE acelera_prod TO acelera_user;

-- Habilitar extensões (conectar ao banco primeiro)
\c acelera_prod
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Sair
\q
```

### 2. Configurar Acesso Remoto (se necessário)
```bash
# Editar pg_hba.conf
sudo nano /etc/postgresql/14/main/pg_hba.conf

# Adicionar linha (ajustar IP conforme necessário)
host    acelera_prod    acelera_user    0.0.0.0/0    md5

# Editar postgresql.conf
sudo nano /etc/postgresql/14/main/postgresql.conf

# Descomentar e ajustar
listen_addresses = '*'

# Reiniciar PostgreSQL
sudo systemctl restart postgresql
```

## Deployment da Aplicação

### 1. Clonar Repositório
```bash
cd /opt
sudo git clone <seu-repositorio-url> acelera
cd acelera
sudo chown -R $USER:$USER .
```

### 2. Instalar Dependências
```bash
npm install
```

### 3. Configurar Variáveis de Ambiente
```bash
# Criar arquivo .env
cat > .env << 'EOF'
# Database
DATABASE_URL=postgres://acelera_user:SuaSenhaForte123!@localhost:5432/acelera_prod

# Pool Configuration (ajustar conforme carga)
PGPOOL_MAX=20
PGPOOL_IDLE_TIMEOUT=30000
PGPOOL_CONNECTION_TIMEOUT=10000

# Encryption (gerar com: openssl rand -base64 32)
ENCRYPTION_KEY=sua_chave_de_32_caracteres_aqui

# Session (gerar com: openssl rand -base64 64)
SESSION_SECRET=sua_chave_de_sessao_aqui

# Environment
NODE_ENV=production
PORT=5000
EOF

# Ajustar permissões
chmod 600 .env
```

### 4. Restaurar Banco de Dados
```bash
# Se migração de dados existentes
psql postgres://acelera_user:SuaSenhaForte123!@localhost:5432/acelera_prod \
  < attached_assets/database-dump-vm-20251112.sql

# Se banco novo, aplicar schema
npm run db:push

# Popular dados iniciais
npm run db:seed
```

### 5. Build da Aplicação
```bash
npm run build
```

### 6. Testar Localmente
```bash
npm start

# Em outro terminal, testar
curl http://localhost:5000
```

## Configurar como Serviço (systemd)

### Criar Service Unit
```bash
sudo nano /etc/systemd/system/acelera.service
```

```ini
[Unit]
Description=Acelera Full Facilities
After=network.target postgresql.service

[Service]
Type=simple
User=acelera
WorkingDirectory=/opt/acelera
Environment=NODE_ENV=production
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=10

# Limites
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

### Ativar e Iniciar
```bash
# Criar usuário de serviço
sudo useradd -r -s /bin/false acelera
sudo chown -R acelera:acelera /opt/acelera

# Habilitar serviço
sudo systemctl daemon-reload
sudo systemctl enable acelera
sudo systemctl start acelera

# Verificar status
sudo systemctl status acelera

# Ver logs
sudo journalctl -u acelera -f
```

## Nginx como Reverse Proxy

### Instalar Nginx
```bash
sudo apt install nginx
```

### Configurar Site
```bash
sudo nano /etc/nginx/sites-available/acelera
```

```nginx
server {
    listen 80;
    server_name seu-dominio.com;

    client_max_body_size 50M;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Assets estáticos
    location /attached_assets/ {
        alias /opt/acelera/attached_assets/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

### Ativar Site
```bash
sudo ln -s /etc/nginx/sites-available/acelera /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## SSL com Let's Encrypt

```bash
# Instalar Certbot
sudo apt install certbot python3-certbot-nginx

# Obter certificado
sudo certbot --nginx -d seu-dominio.com

# Renovação automática já está configurada
sudo systemctl status certbot.timer
```

## Backup Automatizado

### Script de Backup
```bash
sudo nano /usr/local/bin/backup-acelera.sh
```

```bash
#!/bin/bash
BACKUP_DIR="/backups/acelera"
DATE=$(date +%Y%m%d-%H%M%S)
DB_URL="postgres://acelera_user:SuaSenhaForte123!@localhost:5432/acelera_prod"

# Criar diretório se não existir
mkdir -p $BACKUP_DIR

# Backup do banco
pg_dump --file=$BACKUP_DIR/db-$DATE.sql \
        --format=plain \
        --no-owner \
        --no-privileges \
        "$DB_URL"

# Backup dos assets
tar -czf $BACKUP_DIR/assets-$DATE.tar.gz /opt/acelera/attached_assets/

# Manter apenas últimos 30 dias
find $BACKUP_DIR -name "*.sql" -mtime +30 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete

echo "Backup concluído: $DATE"
```

### Configurar Cron
```bash
sudo chmod +x /usr/local/bin/backup-acelera.sh

# Adicionar ao crontab
sudo crontab -e

# Backup diário às 2h
0 2 * * * /usr/local/bin/backup-acelera.sh >> /var/log/acelera-backup.log 2>&1
```

## Monitoramento

### Health Check
```bash
# Criar health check script
cat > /opt/acelera/health-check.sh << 'EOF'
#!/bin/bash
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000)
if [ $RESPONSE -eq 200 ]; then
    echo "✅ Aplicação OK"
    exit 0
else
    echo "❌ Aplicação com problemas: HTTP $RESPONSE"
    exit 1
fi
EOF

chmod +x /opt/acelera/health-check.sh
```

### Logs
```bash
# Logs da aplicação
sudo journalctl -u acelera -f

# Logs do PostgreSQL
sudo tail -f /var/log/postgresql/postgresql-14-main.log

# Logs do Nginx
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

## Troubleshooting

### Aplicação não inicia
```bash
# Verificar logs
sudo journalctl -u acelera -n 100

# Verificar se porta está disponível
sudo netstat -tlnp | grep 5000

# Verificar conexão com banco
psql $DATABASE_URL -c "SELECT 1"
```

### Erro de conexão com banco
```bash
# Verificar se PostgreSQL está rodando
sudo systemctl status postgresql

# Verificar conexões ativas
sudo -u postgres psql -c "SELECT * FROM pg_stat_activity;"

# Verificar configuração do pool
cat .env | grep PGPOOL
```

### Performance lenta
```bash
# Aumentar pool de conexões
nano .env
# PGPOOL_MAX=30

# Reiniciar serviço
sudo systemctl restart acelera

# Verificar uso do banco
sudo -u postgres psql -c "SELECT * FROM pg_stat_database WHERE datname = 'acelera_prod';"
```

## Checklist de Deploy

- [ ] PostgreSQL instalado e rodando
- [ ] Usuário e database criados
- [ ] Extensões habilitadas (uuid-ossp)
- [ ] Código clonado
- [ ] Dependências instaladas (`npm install`)
- [ ] `.env` configurado com DATABASE_URL correto
- [ ] Banco restaurado ou schema aplicado
- [ ] Build executado (`npm run build`)
- [ ] Aplicação testada localmente
- [ ] Serviço systemd configurado
- [ ] Nginx configurado como proxy
- [ ] SSL/TLS configurado (Let's Encrypt)
- [ ] Backup automático configurado
- [ ] Monitoramento ativo

## Variáveis de Ambiente Completas

```bash
# Database
DATABASE_URL=postgres://acelera_user:senha@localhost:5432/acelera_prod
PGPOOL_MAX=20
PGPOOL_IDLE_TIMEOUT=30000
PGPOOL_CONNECTION_TIMEOUT=10000

# Security
ENCRYPTION_KEY=<32_caracteres>
SESSION_SECRET=<64_caracteres>

# Application
NODE_ENV=production
PORT=5000

# Microsoft SSO (opcional)
MICROSOFT_CLIENT_ID=<seu_client_id>
MICROSOFT_CLIENT_SECRET=<seu_client_secret>
MICROSOFT_TENANT_ID=<seu_tenant_id>
MICROSOFT_REDIRECT_URI=https://seu-dominio.com/auth/microsoft/callback

# AI Providers (opcional)
GROQ_API_KEY=<sua_chave>
OPENAI_API_KEY=<sua_chave>
GOOGLE_AI_API_KEY=<sua_chave>
```

## Contato e Suporte

- **Documentação técnica completa:** Ver `DOCUMENTACAO_TECNICA.md`
- **Dump do banco:** `attached_assets/database-dump-vm-20251112.sql`
- **Configuração do pool:** Seção 3.6 em `DOCUMENTACAO_TECNICA.md`
- **Processo de backup/restore:** Seção 3.7.1 em `DOCUMENTACAO_TECNICA.md`
