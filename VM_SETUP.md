# Configuração para VM com PostgreSQL Puro

## ✅ Neon DB Removido com Sucesso

O sistema agora usa **PostgreSQL puro** via driver `pg` (node-postgres), compatível com qualquer instalação PostgreSQL em VM.

## 📋 Variáveis de Ambiente Necessárias

Configure as seguintes variáveis de ambiente na sua VM:

```bash
# Database Connection (escolha uma das opções)

# OPÇÃO 1: Connection String completa (recomendado)
DATABASE_URL=postgresql://usuario:senha@localhost:5432/nome_banco

# OPÇÃO 2: Variáveis separadas (o sistema montará a connection string)
PGHOST=localhost
PGPORT=5432
PGUSER=usuario
PGPASSWORD=senha
PGDATABASE=nome_banco

# Outras variáveis necessárias
NODE_ENV=production
ENCRYPTION_KEY=sua-chave-de-criptografia-aqui
```

## 🗄️ Preparação do Banco de Dados

### 1. Criar o banco PostgreSQL na VM:

```bash
# Conectar ao PostgreSQL como superusuário
sudo -u postgres psql

# Criar o banco e usuário
CREATE DATABASE opus_clean;
CREATE USER opus_user WITH ENCRYPTED PASSWORD 'senha_segura';
GRANT ALL PRIVILEGES ON DATABASE opus_clean TO opus_user;

# Dar permissões completas
\c opus_clean
GRANT ALL ON SCHEMA public TO opus_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO opus_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO opus_user;
```

### 2. Importar dump do banco:

```bash
# Usando o dump gerado
psql -U opus_user -d opus_clean < database-dump-complete-20251111-170612.sql
```

### 3. Aplicar schema e migrations:

```bash
# No diretório do projeto
npm run db:push
```

## 🚀 Iniciar Aplicação na VM

```bash
# Desenvolvimento
npm run dev

# Produção
npm run build
npm start
```

## 🔍 Verificação

O sistema está configurado com:
- **Driver**: `pg` (node-postgres) v8.16.3
- **ORM**: Drizzle ORM v0.39.1
- **Dialect**: PostgreSQL (configurado em `drizzle.config.ts`)
- **Connection Pool**: Implementado em `server/db.ts`

## ⚠️ Notas Importantes

1. **Sem referências ao Neon**: Todo código Neon DB foi removido
2. **PostgreSQL padrão**: Funciona com qualquer versão PostgreSQL >= 12
3. **Connection pooling**: Gerenciado pelo driver `pg`
4. **Migrations**: Use `npm run db:push` (Drizzle Kit)

## 📦 Dependências PostgreSQL

```json
{
  "pg": "^8.16.3",
  "drizzle-orm": "^0.39.1",
  "@types/pg": "^8.15.5",
  "connect-pg-simple": "^10.0.0"
}
```

Todas instaladas e prontas para VM! 🎉
