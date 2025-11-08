#!/bin/bash

# 🔄 Script de Restauração de Backup OPUS
# Uso: bash restore_backup.sh <arquivo_backup.sql>

set -e  # Parar em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir mensagens
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Banner
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║       🗄️  Script de Restauração de Backup OPUS       ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Verificar argumentos
if [ $# -eq 0 ]; then
    print_error "Nenhum arquivo de backup fornecido!"
    echo ""
    echo "Uso: bash $0 <arquivo_backup.sql>"
    echo "Exemplo: bash $0 backups/opus_backup_20251108_192837.sql"
    echo ""
    exit 1
fi

BACKUP_FILE=$1

# Verificar se arquivo existe
if [ ! -f "$BACKUP_FILE" ]; then
    print_error "Arquivo não encontrado: $BACKUP_FILE"
    exit 1
fi

print_success "Arquivo de backup encontrado: $BACKUP_FILE"

# Verificar DATABASE_URL
if [ -z "$DATABASE_URL" ]; then
    print_error "Variável DATABASE_URL não definida!"
    echo ""
    echo "Configure a variável de ambiente:"
    echo "export DATABASE_URL=\"postgresql://usuario:senha@host:5432/database\""
    echo ""
    exit 1
fi

print_success "DATABASE_URL configurada"

# Verificar conexão com banco
print_info "Testando conexão com o banco de dados..."
if ! psql "$DATABASE_URL" -c "SELECT 1;" > /dev/null 2>&1; then
    print_error "Não foi possível conectar ao banco de dados!"
    print_info "Verifique suas credenciais e conexão de rede"
    exit 1
fi

print_success "Conexão com banco estabelecida"

# Obter informações do banco
DB_VERSION=$(psql "$DATABASE_URL" -t -c "SELECT version();" | head -1)
print_info "Versão do PostgreSQL: $(echo $DB_VERSION | cut -d' ' -f2)"

# Contar tabelas existentes
TABLE_COUNT=$(psql "$DATABASE_URL" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" | tr -d ' ')
print_info "Tabelas existentes no banco: $TABLE_COUNT"

# Avisar sobre dados existentes
if [ "$TABLE_COUNT" -gt 0 ]; then
    print_warning "ATENÇÃO: O banco de dados de destino já contém $TABLE_COUNT tabela(s)!"
    print_warning "A restauração irá SUBSTITUIR os dados existentes!"
    echo ""
    
    # Confirmação
    read -p "Deseja continuar com a restauração? (digite 'SIM' para confirmar): " CONFIRM
    
    if [ "$CONFIRM" != "SIM" ]; then
        print_info "Restauração cancelada pelo usuário"
        exit 0
    fi
fi

echo ""
print_info "═══════════════════════════════════════════════════════"
print_info "Iniciando restauração do backup..."
print_info "═══════════════════════════════════════════════════════"
echo ""

# Criar backup de segurança antes de restaurar (opcional)
print_info "Criando backup de segurança do estado atual..."
SAFETY_BACKUP="backups/pre_restore_safety_$(date +%Y%m%d_%H%M%S).sql"

if pg_dump "$DATABASE_URL" --clean --if-exists > "$SAFETY_BACKUP" 2>/dev/null; then
    print_success "Backup de segurança criado: $SAFETY_BACKUP"
else
    print_warning "Não foi possível criar backup de segurança (banco pode estar vazio)"
fi

echo ""

# Restaurar backup
print_info "Restaurando dados do arquivo: $BACKUP_FILE"
print_info "Isso pode levar alguns minutos..."
echo ""

if psql "$DATABASE_URL" < "$BACKUP_FILE"; then
    print_success "Backup restaurado com sucesso!"
else
    print_error "Erro ao restaurar backup!"
    print_warning "Você pode tentar restaurar manualmente usando:"
    echo "psql \"\$DATABASE_URL\" < $BACKUP_FILE"
    exit 1
fi

echo ""
print_info "═══════════════════════════════════════════════════════"
print_info "Verificando restauração..."
print_info "═══════════════════════════════════════════════════════"
echo ""

# Verificar tabelas restauradas
RESTORED_TABLES=$(psql "$DATABASE_URL" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" | tr -d ' ')
print_info "Tabelas no banco: $RESTORED_TABLES"

# Verificar contagens de dados principais
print_info "Estatísticas dos dados restaurados:"

USERS_COUNT=$(psql "$DATABASE_URL" -t -c "SELECT COUNT(*) FROM users;" 2>/dev/null | tr -d ' ' || echo "0")
print_info "  • Usuários: $USERS_COUNT"

CUSTOMERS_COUNT=$(psql "$DATABASE_URL" -t -c "SELECT COUNT(*) FROM customers;" 2>/dev/null | tr -d ' ' || echo "0")
print_info "  • Clientes: $CUSTOMERS_COUNT"

WORKORDERS_COUNT=$(psql "$DATABASE_URL" -t -c "SELECT COUNT(*) FROM work_orders;" 2>/dev/null | tr -d ' ' || echo "0")
print_info "  • Ordens de Serviço: $WORKORDERS_COUNT"

SITES_COUNT=$(psql "$DATABASE_URL" -t -c "SELECT COUNT(*) FROM sites;" 2>/dev/null | tr -d ' ' || echo "0")
print_info "  • Locais: $SITES_COUNT"

ZONES_COUNT=$(psql "$DATABASE_URL" -t -c "SELECT COUNT(*) FROM zones;" 2>/dev/null | tr -d ' ' || echo "0")
print_info "  • Zonas: $ZONES_COUNT"

echo ""
print_success "╔════════════════════════════════════════════════════════╗"
print_success "║          ✅ Restauração concluída com sucesso!        ║"
print_success "╚════════════════════════════════════════════════════════╝"
echo ""

print_info "Próximos passos:"
echo "  1. Teste o login de usuários"
echo "  2. Verifique permissões e acessos"
echo "  3. Execute testes funcionais básicos"
echo ""

print_info "Backup de segurança salvo em: $SAFETY_BACKUP"
print_info "Você pode removê-lo após confirmar que tudo está funcionando"
echo ""
