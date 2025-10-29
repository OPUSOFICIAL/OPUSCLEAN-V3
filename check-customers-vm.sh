#!/bin/bash
echo "🔍 VERIFICANDO CLIENTES"
echo "====================="

echo ""
echo "1️⃣ Total de customers no banco:"
psql $DATABASE_URL -t -c "SELECT COUNT(*) FROM customers;" 2>/dev/null | xargs

echo ""
echo "2️⃣ Lista de customers:"
psql $DATABASE_URL -c "SELECT id, name, company_id FROM customers LIMIT 5;" 2>/dev/null

echo ""
echo "3️⃣ API de customers (deve retornar lista JSON):"
curl -s http://localhost:3007/api/companies/company-opus-default/customers | head -100
