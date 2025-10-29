#!/bin/bash
set -euo pipefail

# ====== CONFIGURÁVEIS ======
DB_NAME="opusclean"
# Empresa principal (pelos teus dados, é esta)
COMPANY_ID="company-admin-default"
# Usuários principais para validar roles
USERS=("user-admin-opus" "user-manoel.mariano-1759521589871")
# Domínio público do site
DOMAIN="opusclean.grupoopus.com"
# ===========================

PSQL="sudo -u postgres psql -d ${DB_NAME} -v ON_ERROR_STOP=1"

echo "🔍 VERIFICANDO BANCO ${DB_NAME}"
echo "=============================="

echo ""
echo "1️⃣ Totais de registros:"
$PSQL -t -c "SELECT COUNT(*) FROM companies;"  | xargs | sed 's/^/   Companies: /'
$PSQL -t -c "SELECT COUNT(*) FROM customers;"  | xargs | sed 's/^/   Customers: /'
$PSQL -t -c "SELECT COUNT(*) FROM users;"      | xargs | sed 's/^/   Users: /'
$PSQL -t -c "SELECT COUNT(*) FROM custom_roles;"    | xargs | sed 's/^/   Custom Roles: /'
$PSQL -t -c "SELECT COUNT(*) FROM role_permissions;"| xargs | sed 's/^/   Role Permissions: /'
$PSQL -t -c "SELECT COUNT(*) FROM user_role_assignments;"| xargs | sed 's/^/   User↔Role Assignments: /'

echo ""
echo "2️⃣ CUSTOMERS (empresa ${COMPANY_ID}):"
$PSQL -c "SELECT id, name, company_id, is_active FROM customers WHERE company_id='${COMPANY_ID}' ORDER BY name;"

echo ""
echo "3️⃣ COMPANIES:"
$PSQL -c "SELECT id, name FROM companies ORDER BY id;"

echo ""
echo "4️⃣ ROLES por empresa:"
$PSQL -c "SELECT company_id, id AS role_id, name FROM custom_roles ORDER BY company_id, name;"

echo ""
echo "5️⃣ PERMISSÕES por role (contagem):"
$PSQL -c "SELECT role_id, COUNT(*) AS perms FROM role_permissions GROUP BY role_id ORDER BY role_id;"

echo ""
echo "6️⃣ VÍNCULOS usuário ↔ role:"
$PSQL -c "SELECT user_id, role_id FROM user_role_assignments ORDER BY user_id, role_id;"

echo ""
echo "7️⃣ Roles efetivos dos usuários-alvo:"
for U in "${USERS[@]}"; do
  echo "   • $U"
  $PSQL -c "SELECT r.id, r.name, r.company_id
            FROM custom_roles r
            JOIN user_role_assignments ura ON ura.role_id = r.id
            WHERE ura.user_id = '$U';"
done

echo ""
echo "8️⃣ Sanidade de schema/donos (top 10 tabelas):"
$PSQL -c "SELECT schemaname, tablename, tableowner
          FROM pg_tables
          WHERE schemaname='public'
          ORDER BY tablename
          LIMIT 10;"

echo ""
echo "9️⃣ API LOCAL (Node/Express na 3007):"
curl -sS http://127.0.0.1:3007/api/companies/${COMPANY_ID}/customers | head -c 400; echo
curl -sSI http://127.0.0.1:3007/ | head -n 15

echo ""
echo "🔟 API via NGINX/HTTPS (${DOMAIN}):"
curl -sS https://${DOMAIN}/api/companies/${COMPANY_ID}/customers | head -c 400; echo
curl -sSI https://${DOMAIN}/ | head -n 15

echo ""
echo "✅ PRONTO."
echo "=============================="
