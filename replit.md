# Acelera it - Full Facilities - Project Summary

## Overview
Acelera it Full Facilities is a modular platform designed to streamline facilities management, specifically for Clean and Maintenance operations. It offers web administration and mobile applications for scheduling, work order management, QR code-based task execution, and public service requests. The platform supports multi-company, multi-site, and multi-zone environments, providing real-time analytics, focusing on efficiency, cost reduction, and productivity.

## User Preferences
Preferred communication style: Simple, everyday language.

## System Architecture

### UI/UX Decisions
The system features an enterprise-grade, corporate design utilizing `shadcn/ui` with Radix UI and Tailwind CSS. It emphasizes professionalism with module-specific colors (blue for Clean, orange for Maintenance), responsive design, and a corporate SaaS aesthetic for pre-login pages. Visual elements include custom branding, Lucide React icons, Framer Motion animations, and full-width layouts.

### Technical Implementations
The frontend uses React, TypeScript, Wouter for routing, and TanStack Query for data management. The backend is an Express.js server in TypeScript with Drizzle ORM for PostgreSQL. Key features include a hierarchical multi-tenancy model with role-based access control, comprehensive equipment management, QR code-based task execution, robust work order management with virtual calendars and automated scheduling. Authentication supports Microsoft SSO and email/password, secured with JWT and Bcrypt. An AI integration configuration page is present, with chat assistant functionality under development. A TV Mode Dashboard provides real-time, gamified metrics. User management offers full CRUD and custom role assignments. Recent enhancements include a granular permission system with user type validation and frontend filtering, enhanced shift-based scheduling with weekday filtering, and full-featured edit forms using reusable components. The custom roles system features automatic creation of 3 default client roles upon customer provisioning: "Operador" (mobile-only, 4 permissions), "Cliente" (web, 8 permissions), and "Administrador" (web, 38 client permissions). Roles are associated with the customer's company via `companyId` reference, following the hierarchical structure: Companies → Customers → Roles. The roles interface includes per-category "Select All" checkboxes with smart state indicators showing partial selections. Admin OPUS users have automatic access to view and manage all roles without explicit permission checks. 

**Real-Time Updates (Sistema Totalmente Reativo)**: O sistema implementa um modelo completamente reativo com WebSocket para atualizações instantâneas em TODOS os recursos. O servidor WebSocket roda no mesmo servidor HTTP no path `/ws`, usando autenticação JWT. Quando qualquer dado muda, o backend transmite notificações para todos os clientes conectados via WebSocket, e o frontend automaticamente invalida o cache do React Query e recarrega os dados afetados, garantindo que todos os usuários vejam as mudanças **imediatamente sem refresh manual da página**.

**Recursos com broadcasts em tempo real:**
- **Operações Principais**: Work Orders (Ordens de Serviço), Customers (Clientes), Sites (Locais), Zones (Zonas)
- **Gestão de Acesso**: Users (Usuários), Roles (Funções Personalizadas)
- **Manutenção**: Equipment (Equipamentos), Maintenance Plans (Planos de Manutenção), Maintenance Checklists
- **Limpeza**: Services (Serviços), Cleaning Activities (Atividades de Limpeza), Checklists
- **Outros**: QR Code Points, Dashboard Goals, AI Integrations

**Feedback Visual Sutil**: Toasts discretos aparecem automaticamente quando atualizações em tempo real ocorrem, informando o usuário sobre o recurso que foi criado/atualizado/excluído, com duração de 2 segundos para não interromper o fluxo de trabalho.

**Características Técnicas**: 
- Reconexão automática com backoff exponencial
- Heartbeat/ping-pong para detectar conexões quebradas  
- Integração perfeita com React Query para invalidação de cache
- Substitui completamente polling e staleTime, eliminando requisições desnecessárias
- Implementação: `server/websocket.ts` (servidor), `client/src/hooks/useWebSocket.ts` (hook do cliente), `client/src/App.tsx` (toasts), broadcasts em todos os endpoints CRUD em `server/routes.ts`

**Controle de Sessão Única**: Sistema de autenticação com controle de sessão única, permitindo apenas um login ativo por conta. Quando um usuário faz login em um novo dispositivo/navegador, a sessão anterior é automaticamente invalidada via WebSocket. O sistema:
- Gera `sessionId` único usando nanoid para cada login
- Armazena sessionId no token JWT
- Rastreia sessões ativas no WebSocket (`userId → sessionId`)
- Detecta novo login e invalida sessão anterior automaticamente
- Envia mensagem `session_invalidated` via WebSocket para o cliente antigo
- Frontend detecta invalidação, mostra toast "Essa conta foi logada em outro aparelho", e redireciona para login em 2 segundos
- Implementação: `server/routes.ts` (geração sessionId no login), `server/websocket.ts` (rastreamento e invalidação), `client/src/App.tsx` (detecção e redirecionamento)

Performance optimizations include database indexing, parallel query execution, and accurate real-time data reporting. Photo uploads are optimized with automatic image compression and smaller batch sizes for improved performance on slow connections. An offline-first Android APK is supported by a comprehensive sync infrastructure, utilizing IndexedDB for offline storage, a priority-based sync queue, and robust error handling.

### System Design Choices
The project is configured for the Replit cloud environment, with automated PostgreSQL provisioning and a modular design for future expansion. It includes an adaptive subdomain-based branding system that dynamically applies client branding (logos and module colors) based on the subdomain, with robust fallback mechanisms and asset serving.

## External Dependencies

### Database & Storage
- PostgreSQL (Neon hosting)
- Drizzle ORM
- Drizzle Kit

### UI Components & Styling
- Radix UI
- shadcn/ui
- Tailwind CSS
- Lucide React
- React Icons
- Framer Motion

### Mobile (Android APK - Expo React Native)
O app móvel foi reconstruído usando Expo React Native para melhor experiência offline e build simplificado.

**Estrutura do projeto mobile:**
- `/mobile` - Projeto Expo separado
- `/mobile/src/db/database.ts` - Schema SQLite e operações CRUD
- `/mobile/src/services/syncService.ts` - Sincronização com servidor
- `/mobile/src/hooks/` - Hooks (useAuth, useNetwork, useSync, useWorkOrders)
- `/mobile/src/screens/` - Telas (Login, CustomerSelect, WorkOrders)

**Tecnologias:**
- Expo SDK 52
- Expo SQLite (armazenamento local)
- Expo Network (detecção de conectividade)
- Expo Secure Store (credenciais)
- React Native
- TypeScript

**Funcionalidades offline:**
- SQLite local com tabelas: work_orders, qr_codes, users, pending_sync
- Sincronização automática a cada 1 minuto quando online
- Fila de pendências para alterações offline (concluir/pausar OS)
- Baixa OSs abertas/pausadas de hoje + próximo dia
- Exclui OSs concluídas após sincronização

**Build APK:**
- Instruções: `/mobile/INSTRUCOES_BUILD_APK.md`
- Scripts: `gerar-apk.bat` (Windows), `gerar-apk.sh` (Mac/Linux)
- Requer: Node.js 18+, conta Expo gratuita
- Build na nuvem via EAS Build (5-15 min)

### Frontend Framework
- React 18
- TypeScript
- Vite
- Wouter
- TanStack Query
- React Hook Form
- Zod

### Backend & API
- Express.js
- TypeScript
- WebSocket (ws) - Real-time updates
- Passport.js
- Passport Local
- OpenID Client
- JWT
- Bcrypt.js

### Security & Middleware
- Helmet.js
- CORS
- Express Rate Limit
- Express Session
- Connect PG Simple

### AI & Chat
- Groq SDK
- Google Generative AI
- OpenAI SDK
- Zod

### Utilities
- date-fns
- nanoid
- QRCode
- QR Scanner
- jsPDF
- jsPDF AutoTable
- html2canvas
- XLSX
- Memoizee