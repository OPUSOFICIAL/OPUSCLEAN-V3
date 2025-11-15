# 🔧 Recompilar APK com Servidor Configurado

## ❌ Problema que Você Teve:

O APK estava tentando fazer login mas **não sabia onde estava o servidor**.

## ✅ Solução Aplicada:

Atualizei `capacitor.config.ts` com a URL do servidor Replit:
```
https://5096b304-c27d-40bb-b542-8d20aebdf3ca-00-mp6q3s0er8fy.kirk.replit.dev
```

---

## 📱 Como Recompilar APK:

### **PASSO 1: Baixar Projeto Atualizado**

1. Nesta Replit, clique nos **3 pontinhos (⋮)**
2. Selecione **"Download as ZIP"**
3. Extraia e SUBSTITUA os arquivos antigos

### **PASSO 2: Recompilar**

**🪟 Windows:**
```bash
gerar-apk.bat
```

**🍎 Mac/Linux:**
```bash
./gerar-apk.sh
```

### **PASSO 3: Reinstalar no Celular**

O novo APK estará em: `android/app/build/outputs/apk/debug/app-debug.apk`

**⚠️ IMPORTANTE:** Desinstale o APK antigo primeiro, depois instale o novo!

---

## 🧪 Testar Login:

Agora o login deve funcionar! Use:
- **Usuário:** `admin`
- **Senha:** `admin123`

Depois do login, o app sincroniza dados e **funciona 100% offline**!

---

## 📊 Fluxo Completo:

1. ✅ **Login online** (conecta ao servidor Replit)
2. ✅ **Sincroniza dados** (QR points, zonas, WOs programadas, checklists)
3. ✅ **Modo avião** (agora funciona offline!)
4. ✅ **Escanear QR** → Mostra atividade programada
5. ✅ **Executar checklist** + fotos offline
6. ✅ **Reconectar** → Auto-sync automático

---

## ⚠️ Observações Importantes:

### Servidor Replit Precisa Estar Ativo
- O servidor **hiberna** após inatividade
- Antes de fazer login no APK, acesse a URL no navegador para "acordar" o servidor:
  ```
  https://5096b304-c27d-40bb-b542-8d20aebdf3ca-00-mp6q3s0er8fy.kirk.replit.dev
  ```

### Se Login Falhar:
1. Verifique se o servidor Replit está online (acesse URL acima)
2. Verifique se o celular tem internet
3. Tente fazer login no navegador primeiro para testar credenciais

---

## 🔐 Credenciais de Teste:

**Admin (acesso total):**
- Usuário: `admin`
- Senha: `admin123`

**Usuário operacional:**
- Usuário: `joao.geral`
- Senha: `joao123`

---

**Versão:** 1.0.1 (com servidor configurado)  
**Última atualização:** Novembro 2025
