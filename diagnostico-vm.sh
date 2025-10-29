#!/bin/bash
echo "🔍 DIAGNÓSTICO VM"
echo "================"

echo ""
echo "1️⃣ Servidor:"
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:3007/

echo ""
echo "2️⃣ HTML:"
curl -s http://localhost:3007/ | grep -o '<html' && echo "✅ OK" || echo "❌ ERRO"

echo ""
echo "3️⃣ Assets JS:"
JS=$(curl -s http://localhost:3007/ | grep -o '/assets/index-[^"]*\.js' | head -1)
echo "Arquivo: $JS"
curl -s -o /dev/null -w "HTTP %{http_code}\n" "http://localhost:3007$JS"

echo ""
echo "4️⃣ Arquivos compilados:"
ls -lh dist/public/index.html 2>/dev/null && echo "✅ index.html OK" || echo "❌ Falta index.html"
ls -lh dist/index.js 2>/dev/null && echo "✅ backend OK" || echo "❌ Falta backend"
echo "Assets: $(ls dist/public/assets/*.js 2>/dev/null | wc -l) arquivos JS"

echo ""
echo "5️⃣ PM2:"
pm2 list | grep newfacilities
