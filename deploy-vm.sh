#!/bin/bash
set -euo pipefail

APP_DIR="/home/opus/apps/newfacilities"
cd "$APP_DIR"

echo "==> 1) Verificando .env"
grep -q '^PORT=' .env || echo 'PORT=3007' >> .env
sed -i 's/^PORT=.*/PORT=3007/' .env
grep -q '^NODE_ENV=' .env || echo 'NODE_ENV=production' >> .env
sed -i 's/^NODE_ENV=.*/NODE_ENV=production/' .env
grep -q '^DATABASE_URL=' .env || { echo "❌ ERRO: DATABASE_URL não configurado no .env!"; exit 1; }

echo "==> 2) Instalando dependências"
npm ci

echo "==> 3) Build completo (frontend + backend)"
npm run build

echo "==> 4) Verificando arquivos gerados"
if [ ! -f "dist/public/index.html" ]; then
  echo "❌ ERRO: dist/public/index.html não foi gerado!"
  exit 1
fi
if [ ! -f "dist/index.js" ]; then
  echo "❌ ERRO: dist/index.js não foi gerado!"
  exit 1
fi

echo "==> 5) Configurando PM2"
cat > ecosystem.config.cjs <<'CJS'
module.exports = {
  apps: [{
    name: "newfacilities",
    script: "./dist/index.js",
    cwd: "/home/opus/apps/newfacilities",
    env: { 
      NODE_ENV: "production", 
      PORT: "3007" 
    }
  }]
}
CJS

echo "==> 6) Iniciando aplicação"
pm2 delete newfacilities 2>/dev/null || true
pm2 start ecosystem.config.cjs --update-env

echo "==> 7) Verificando status"
pm2 list

echo ""
echo "✅ Deploy concluído!"
echo "📋 Verifique os logs com: pm2 logs newfacilities"
echo "🌐 App rodando na porta 3007"
