# OPUS - Sistema de Gestão de Facilities

Sistema modular de gestão de facilities com módulos Clean (limpeza) e Manutenção, desenvolvido com React, TypeScript, Express e PostgreSQL.

## 🚀 Quick Start

### Pré-requisitos

- Node.js 18+ 
- PostgreSQL 14+
- npm ou yarn

### Instalação

1. **Clone o repositório**
```bash
git clone <repository-url>
cd opus-facilities
```

2. **Instale as dependências**
```bash
npm install
```

3. **Configure o banco de dados**

Crie um banco PostgreSQL e configure a variável de ambiente:

```bash
export DATABASE_URL="postgresql://user:password@localhost:5432/opus_db"
```

4. **Importe o dump do banco**
```bash
psql $DATABASE_URL < database_dump_final.sql
```

Ou, se preferir criar do zero:

```bash
npm run db:push
```

5. **Inicie o servidor de desenvolvimento**
```bash
npm run dev
```

O sistema estará disponível em `http://localhost:5000`

## 📁 Estrutura do Projeto

```
opus-facilities/
├── client/              # Frontend React + TypeScript
│   ├── src/
│   │   ├── components/  # Componentes reutilizáveis
│   │   ├── contexts/    # Contextos React (Auth, Module, Client)
│   │   ├── hooks/       # Hooks customizados
│   │   ├── lib/         # Utilitários e configurações
│   │   └── pages/       # Páginas da aplicação
│   └── public/          # Arquivos estáticos
├── server/              # Backend Express + TypeScript
│   ├── routes.ts        # Rotas da API
│   ├── auth.ts          # Autenticação e autorização
│   ├── storage.ts       # Interface de persistência
│   └── index.ts         # Entry point do servidor
├── shared/              # Código compartilhado
│   └── schema.ts        # Esquema do banco (Drizzle ORM)
└── database_dump_final.sql  # Dump completo do banco
```

## 🎯 Funcionalidades Principais

### OPUS Clean (Módulo de Limpeza)
- Gestão de ordens de serviço de limpeza
- QR Codes para execução de tarefas
- Checklists configuráveis
- Solicitações públicas de serviço
- Dashboards e relatórios

### OPUS Manutenção (Módulo de Manutenção)
- Gestão de equipamentos
- Planos de manutenção (preventiva, preditiva, corretiva)
- Checklists de manutenção reutilizáveis
- Ordens de serviço automáticas
- Calendário de atividades

### Multi-tenancy
- Suporte a múltiplas empresas
- Hierarquia: Empresas > Locais > Zonas
- Isolamento completo de dados por módulo
- Controle de acesso baseado em funções (RBAC)

### Autenticação
- Login com email/senha
- Integração com Microsoft SSO (Entra ID)
- Gerenciamento de sessões
- Proteção de rotas

## 🔧 Scripts Disponíveis

```bash
npm run dev          # Inicia servidor de desenvolvimento
npm run build        # Build para produção
npm run db:push      # Sincroniza schema com banco de dados
npm run db:studio    # Interface visual do banco (Drizzle Studio)
```

## 📚 Documentação Completa

Para documentação técnica detalhada, arquitetura, fluxos e changelog, consulte:
- [DOCUMENTATION.md](./DOCUMENTATION.md) - Documentação técnica completa
- [replit.md](./replit.md) - Resumo do projeto e preferências

## 🔐 Variáveis de Ambiente

```bash
# Banco de Dados
DATABASE_URL=postgresql://user:password@localhost:5432/opus_db

# Sessão (gere uma chave aleatória segura)
SESSION_SECRET=your-super-secret-session-key

# Microsoft SSO (opcional)
MICROSOFT_CLIENT_ID=your-client-id
MICROSOFT_CLIENT_SECRET=your-client-secret
MICROSOFT_TENANT_ID=your-tenant-id
```

## 🎨 Tecnologias Utilizadas

### Frontend
- React 18
- TypeScript
- Vite
- TailwindCSS + shadcn/ui
- Wouter (routing)
- TanStack Query (data fetching)
- Radix UI (componentes acessíveis)

### Backend
- Node.js + Express
- TypeScript
- Drizzle ORM
- PostgreSQL
- Passport.js (autenticação)
- JWT + bcrypt (segurança)

## 👥 Sistema de Permissões

O sistema possui controle granular de permissões baseado em funções:

- **Administrador**: Acesso total ao sistema
- **Gestor**: Gerenciamento de ordens de serviço e usuários
- **Supervisor**: Visualização e atribuição de tarefas
- **Colaborador**: Execução de tarefas atribuídas

Cada função possui permissões específicas definidas em `server/auth.ts`

## 📱 Acesso Mobile

O sistema possui interface otimizada para mobile, acessível através do mesmo URL. Colaboradores podem:
- Visualizar ordens de serviço atribuídas
- Escanear QR Codes
- Executar checklists
- Adicionar comentários e fotos
- Marcar tarefas como concluídas

## 🐛 Troubleshooting

### Erro de conexão com banco de dados
Verifique se a variável `DATABASE_URL` está configurada corretamente e se o PostgreSQL está rodando.

### Erro ao fazer db:push
Use `npm run db:push --force` se houver conflitos no schema.

### Porta 5000 já em uso
Altere a porta no arquivo `server/index.ts` ou pare o processo que está usando a porta 5000.

## 📄 Licença

Propriedade do Grupo OPUS. Todos os direitos reservados.

## 📞 Suporte

Para suporte técnico ou dúvidas, entre em contato com a equipe de desenvolvimento.

---

**Desenvolvido com ❤️ pelo Grupo OPUS**
