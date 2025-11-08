# 🗄️ Backups do Banco de Dados OPUS

## 📦 Backup Completo

Este diretório contém dumps completos do banco de dados PostgreSQL do sistema OPUS.

### 📋 Conteúdo do Backup

O backup inclui **TODOS** os dados do sistema:

- ✅ **Usuários** - Todos os usuários e suas permissões
- ✅ **Empresas e Clientes** - Estrutura multi-tenant completa
- ✅ **Locais e Zonas** - Hierarquia de sites e zonas
- ✅ **Ordens de Serviço** - Todas as O.S (programadas, corretivas internas, públicas)
- ✅ **Checklists** - Templates e execuções de checklists
- ✅ **Equipamentos** - Cadastro de equipamentos (módulo Manutenção)
- ✅ **Planos de Manutenção** - Planos e atividades de manutenção
- ✅ **QR Codes** - Códigos QR de execução e públicos
- ✅ **Categorias de Serviço** - Categorias personalizadas por cliente
- ✅ **Configurações SLA** - Configurações de SLA por cliente
- ✅ **Conversas da IA** - Histórico de conversas do chat AI
- ✅ **Integrações AI** - Configurações de integração com Google Gemini

### 📊 Informações do Backup

- **Formato**: SQL dump (PostgreSQL)
- **Tamanho**: ~72 MB
- **Linhas**: ~3.271 linhas SQL
- **Opções usadas**: `--clean --if-exists --column-inserts`
  - `--clean`: Adiciona comandos DROP antes de CREATE
  - `--if-exists`: Evita erros se tabelas não existirem
  - `--column-inserts`: Formato legível com nomes de colunas

---

## 🔄 Como Restaurar o Backup

### Método 1: Restauração Automática (Recomendado)

Use o script de restauração fornecido:

```bash
bash backups/restore_backup.sh backups/opus_backup_YYYYMMDD_HHMMSS.sql
```

### Método 2: Restauração Manual

#### Pré-requisitos

1. PostgreSQL instalado (versão 16+)
2. Acesso ao banco de dados de destino
3. Variável de ambiente `DATABASE_URL` configurada

#### Passo a Passo

**1. Verificar conexão com o banco:**

```bash
psql "$DATABASE_URL" -c "SELECT version();"
```

**2. (OPCIONAL) Limpar banco de destino:**

⚠️ **ATENÇÃO**: Isso irá APAGAR todos os dados existentes!

```bash
psql "$DATABASE_URL" -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
```

**3. Restaurar o backup:**

```bash
psql "$DATABASE_URL" < backups/opus_backup_20251108_192837.sql
```

**4. Verificar a restauração:**

```bash
psql "$DATABASE_URL" -c "\dt" # Lista todas as tabelas
psql "$DATABASE_URL" -c "SELECT COUNT(*) FROM users;" # Conta usuários
psql "$DATABASE_URL" -c "SELECT COUNT(*) FROM work_orders;" # Conta O.S
```

---

## 📝 Exemplo de Restauração Completa

```bash
# 1. Definir variável de ambiente (se não estiver definida)
export DATABASE_URL="postgresql://usuario:senha@host:5432/database"

# 2. Fazer backup do banco atual (segurança)
pg_dump "$DATABASE_URL" > backups/pre_restore_backup_$(date +%Y%m%d_%H%M%S).sql

# 3. Limpar banco (CUIDADO!)
psql "$DATABASE_URL" -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

# 4. Restaurar backup
psql "$DATABASE_URL" < backups/opus_backup_20251108_192837.sql

# 5. Verificar
psql "$DATABASE_URL" -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';"
```

---

## 🛡️ Boas Práticas

### Antes de Restaurar

1. ✅ Faça um backup do banco de destino
2. ✅ Teste a restauração em ambiente de desenvolvimento primeiro
3. ✅ Verifique o espaço em disco disponível
4. ✅ Notifique os usuários sobre manutenção (se produção)

### Depois de Restaurar

1. ✅ Verifique a integridade dos dados
2. ✅ Teste login de usuários
3. ✅ Valide permissões e acessos
4. ✅ Execute testes funcionais básicos

---

## 🔐 Segurança

⚠️ **IMPORTANTE**: Este backup contém dados sensíveis:

- Senhas com hash Bcrypt
- Tokens de acesso (JWT secrets)
- Chaves de API criptografadas
- Dados de clientes

**Recomendações:**

1. 🔒 Armazene backups em local seguro
2. 🔒 Use criptografia para armazenamento de longo prazo
3. 🔒 Restrinja acesso apenas a administradores
4. 🔒 Não compartilhe backups por email ou serviços públicos
5. 🔒 Considere usar `pg_dump --no-owner --no-privileges` em ambientes de desenvolvimento

---

## 📅 Agendamento de Backups

### Backup Diário Automatizado

Adicione ao crontab (Linux/Mac):

```bash
# Backup diário às 2h da manhã
0 2 * * * cd /caminho/do/projeto && pg_dump "$DATABASE_URL" --clean --if-exists --column-inserts > "backups/opus_backup_$(date +\%Y\%m\%d_\%H\%M\%S).sql"

# Limpeza de backups antigos (manter últimos 30 dias)
0 3 * * * find /caminho/do/projeto/backups -name "opus_backup_*.sql" -mtime +30 -delete
```

---

## 🆘 Solução de Problemas

### Erro: "relation already exists"

**Causa**: Tabelas já existem no banco de destino  
**Solução**: Use a opção `--clean` no pg_dump ou limpe o schema antes de restaurar

### Erro: "permission denied"

**Causa**: Usuário sem permissões adequadas  
**Solução**: Use um superusuário ou o owner do banco

### Backup muito grande

**Alternativa**: Backup compactado

```bash
pg_dump "$DATABASE_URL" --clean --if-exists | gzip > backups/opus_backup_$(date +%Y%m%d_%H%M%S).sql.gz

# Restaurar backup compactado
gunzip -c backups/opus_backup_YYYYMMDD_HHMMSS.sql.gz | psql "$DATABASE_URL"
```

---

## 📞 Suporte

Para dúvidas ou problemas com backups, consulte:

- [Documentação PostgreSQL - pg_dump](https://www.postgresql.org/docs/current/app-pgdump.html)
- [Documentação PostgreSQL - pg_restore](https://www.postgresql.org/docs/current/app-pgrestore.html)
- [DATABASE_BACKUP_INFO.md](../DATABASE_BACKUP_INFO.md) - Informações específicas do projeto

---

**Última atualização**: 08/11/2025  
**Versão do PostgreSQL**: 16.9 (database) / 17.5 (pg_dump)
