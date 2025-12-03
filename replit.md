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

### Subdomain-Based Client Separation (Multi-Tenant)
O sistema suporta separação de clientes baseada em subdomain usando query parameters. Isso permite que cada cliente tenha seu próprio branding e contexto desde a landing page, antes mesmo do login.

**Funcionamento:**
1. **Detecção de Subdomain (Priority Order):**
   - Query Parameter: `?subdomain=nestle` (Priority 1 - highest)
   - Hostname Subdomain: `nestle.aceelra.com.br` (Priority 2)
   - localStorage Persistence: Subdomain salvo de sessão anterior (Priority 3)

2. **Persistência:**
   - O subdomain é salvo em localStorage (`opus:subdomain`)
   - Todas as navegações preservam o subdomain usando o hook `useSubdomainNavigation`
   - O subdomain persiste durante toda a sessão do usuário

3. **Branding Dinâmico:**
   - BrandingContext carrega branding do cliente por subdomain (pré-login)
   - Aplica logos (loginLogo, sidebarLogo, homeLogo) e cores do módulo
   - Fallback para branding padrão da Acelera se cliente não encontrado

4. **Auto-Set Client após Login:**
   - ClientContext detecta subdomain e busca cliente correspondente
   - Após login, activeClient é automaticamente setado para o cliente do subdomain
   - Na seleção de módulo, o cliente do subdomain tem prioridade

**Arquivos Principais:**
- `client/src/lib/subdomain-detector.ts` - Detecção e persistência de subdomain
- `client/src/hooks/useSubdomainNavigation.ts` - Hook para navegação com subdomain
- `client/src/contexts/ClientContext.tsx` - Auto-set de cliente baseado em subdomain
- `client/src/contexts/BrandingContext.tsx` - Aplicação de branding por subdomain

**Uso:**
- Landing Page: `https://seu-dominio.com/landing?subdomain=nestle`
- Login: O subdomain é preservado automaticamente na navegação
- Dashboard: Cliente do subdomain é ativado automaticamente após login

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

**Versões (Expo SDK 54 - Novembro 2025):**
- Expo SDK 54.0.0
- React Native 0.81.2
- React 19.1.0
- Kotlin 2.0.21
- compileSdkVersion/targetSdkVersion: 35 (Android 16)
- minSdkVersion: 24
- Suporte a 16KB page size (obrigatório Google Play Nov/2025)

**Estrutura do projeto mobile:**
- `/mobile` - Projeto Expo separado
- `/mobile/App.tsx` - Navegação principal e gerenciamento de estado
- `/mobile/src/db/database.ts` - Schema SQLite completo e operações CRUD
- `/mobile/src/services/syncService.ts` - Sincronização bidirecional com servidor
- `/mobile/src/api/client.ts` - Cliente HTTP para todas as operações da API
- `/mobile/src/hooks/` - Hooks (useAuth, useNetwork, useSync, useWorkOrders)
- `/mobile/src/screens/` - Telas completas:
  - `LoginScreen.tsx` - Autenticação
  - `CustomerSelectScreen.tsx` - Seleção de cliente (multi-tenant)
  - `WorkOrdersScreen.tsx` - Lista de OSs com status de sync
  - `WorkOrderExecuteScreen.tsx` - Execução de OS com checklist dinâmico
  - `QRScannerScreen.tsx` - Scanner QR para identificação de pontos
- `/mobile/src/utils/imageUtils.ts` - Captura e compressão de fotos

**Tecnologias:**
- Expo SDK 54 (React Native 0.81, React 19)
- Expo SQLite v16 (armazenamento local)
- @react-native-community/netinfo (detecção de conectividade)
- Expo Secure Store v15 (credenciais)
- Expo Image Picker v17 (captura de fotos)
- Expo Image Manipulator v14 (compressão)
- Expo File System v19 (legacy API)
- TypeScript 5.8

**Funcionalidades implementadas:**
- Checklist dinâmico com tipos: boolean, text, number, select, checkbox, photo
- Captura de fotos com compressão automática (max 1920x1920, quality 0.6)
- Pausar OS com motivo obrigatório e fotos opcionais
- Retomar OS pausada
- Scanner QR para identificar pontos/zonas e listar OSs associadas
- Validação de campos obrigatórios no checklist

**Funcionalidades offline:**
- SQLite local com tabelas: work_orders, qr_codes, users, pending_sync, checklist_templates, checklist_executions, work_order_photos, work_order_comments
- Sincronização automática a cada 1 minuto quando online
- Fila de pendências para alterações offline (iniciar/concluir/pausar/retomar OS)
- Sincronização de fotos, execuções de checklist e comentários
- Baixa OSs abertas/pausadas de hoje + próximo dia
- Baixa checklists templates associados às OSs
- Exclui dados sincronizados para liberar espaço

**Build APK (Local no PC - Recomendado):**
- Instruções completas: `/mobile/INSTRUCOES_BUILD_APK.md`
- Requer: Node.js 20+ LTS, Java JDK 17, Android SDK 35
- Passos: `npm install` → `npx expo install --fix` → `npx expo prebuild --clean` → `./gradlew assembleRelease`
- APK gerado em: `android/app/build/outputs/apk/release/app-release.apk`

**Build APK (Nuvem - Alternativa):**
- Requer: Node.js 20+, conta Expo gratuita
- Passos: `npm install -g eas-cli` → `eas login` → `eas build --platform android --profile preview`
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