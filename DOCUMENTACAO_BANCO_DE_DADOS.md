# Documentação do Banco de Dados - OPUS CLEAN

**Data de criação:** Novembro 2025  
**SGBD:** PostgreSQL (Neon)  
**ORM:** Drizzle ORM  
**Versão do Sistema:** 1.0

---

## 📋 Índice

1. [Enums](#enums)
2. [Tabelas Principais](#tabelas-principais)
3. [Tabelas de Relacionamento](#tabelas-de-relacionamento)
4. [Tabelas de Configuração](#tabelas-de-configuração)
5. [Tabelas de Logs](#tabelas-de-logs)
6. [Campos Especiais](#campos-especiais)

---

## 🏷️ Enums

### user_role
Papéis de usuário no sistema:
- `admin` - Administrador do sistema
- `gestor_cliente` - Gestor do cliente
- `supervisor_site` - Supervisor de site
- `operador` - Operador de campo
- `auditor` - Auditor

### user_type
Tipo de usuário:
- `opus_user` - Usuário da OPUS
- `customer_user` - Usuário do cliente

### auth_provider
Provedor de autenticação:
- `local` - Autenticação local (email/senha)
- `microsoft` - Microsoft Entra ID (SSO)

### work_order_status
Status das ordens de serviço:
- `aberta` - OS criada, aguardando execução
- `em_execucao` - OS em andamento
- `pausada` - OS pausada temporariamente
- `vencida` - OS passou do prazo
- `concluida` - OS finalizada
- `cancelada` - OS cancelada

### work_order_type
Tipos de ordem de serviço:
- `programada` - Gerada pelo plano de limpeza
- `corretiva_interna` - Criada via QR code de execução
- `corretiva_publica` - Criada via QR code público

### priority
Níveis de prioridade:
- `baixa` - Baixa prioridade
- `media` - Média prioridade (padrão)
- `alta` - Alta prioridade
- `critica` - Prioridade crítica

### qr_code_type
Tipos de QR code:
- `execucao` - Para operadores executarem OSs
- `atendimento` - Para público solicitar serviços

### frequency
Frequências de limpeza:
- `diaria` - Todos os dias
- `semanal` - Semanalmente
- `mensal` - Mensalmente
- `trimestral` - A cada 3 meses
- `semestral` - A cada 6 meses
- `anual` - Anualmente
- `turno` - Por turno
- `custom` - Frequência personalizada

### bathroom_counter_action
Ações nos contadores de banheiro:
- `increment` - Incrementar contador
- `decrement` - Decrementar contador
- `reset` - Resetar contador

### permission_key
Permissões granulares do sistema (66 permissões):
- **Dashboard:** `dashboard_view`
- **Work Orders:** `workorders_view`, `workorders_create`, `workorders_edit`, `workorders_delete`, `workorders_comment`, `workorders_evaluate`
- **Agendamentos:** `schedule_view`, `schedule_create`, `schedule_edit`, `schedule_delete`
- **Checklists:** `checklists_view`, `checklists_create`, `checklists_edit`, `checklists_delete`
- **QR Codes:** `qrcodes_view`, `qrcodes_create`, `qrcodes_edit`, `qrcodes_delete`
- **Planta Baixa:** `floor_plan_view`, `floor_plan_edit`
- **Heatmap:** `heatmap_view`
- **Sites:** `sites_view`, `sites_create`, `sites_edit`, `sites_delete`
- **Usuários:** `users_view`, `users_create`, `users_edit`, `users_delete`
- **Clientes:** `customers_view`, `customers_create`, `customers_edit`, `customers_delete`
- **Relatórios:** `reports_view`
- **Auditoria:** `audit_logs_view`
- **Configurações:** `service_settings_view`, `service_settings_edit`
- **Roles:** `roles_manage`
- **Usuários OPUS:** `opus_users_view`, `opus_users_create`, `opus_users_edit`, `opus_users_delete`
- **Usuários Cliente:** `client_users_view`, `client_users_create`, `client_users_edit`, `client_users_delete`

---

## 📊 Tabelas Principais

### 1. companies (Empresas)
Empresas que utilizam o sistema (multi-tenant).

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| name | varchar | Nome da empresa | ✅ |
| cnpj | varchar | CNPJ da empresa | ❌ |
| email | varchar | Email da empresa | ❌ |
| phone | varchar | Telefone da empresa | ❌ |
| address | varchar | Endereço da empresa | ❌ |
| is_active | boolean | Empresa ativa | ✅ (padrão: true) |
| created_at | timestamp | Data de criação | ✅ (auto) |
| updated_at | timestamp | Data de atualização | ✅ (auto) |

---

### 2. customers (Clientes/Contratantes)
Clientes contratantes dos serviços de limpeza.

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| company_id | varchar | ID da empresa | ✅ FK → companies |
| name | varchar | Nome do cliente | ✅ |
| email | varchar | Email do cliente | ❌ |
| phone | varchar | Telefone do cliente | ❌ |
| document | varchar | CPF/CNPJ | ❌ |
| address | varchar | Endereço | ❌ |
| city | varchar | Cidade | ❌ |
| state | varchar | Estado | ❌ |
| zip_code | varchar | CEP | ❌ |
| contact_person | varchar | Pessoa de contato | ❌ |
| notes | text | Observações | ❌ |
| is_active | boolean | Cliente ativo | ✅ (padrão: true) |
| created_at | timestamp | Data de criação | ✅ (auto) |
| updated_at | timestamp | Data de atualização | ✅ (auto) |

---

### 3. sites (Locais/Sites)
Locais físicos onde os serviços são realizados.

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| company_id | varchar | ID da empresa | ✅ FK → companies |
| customer_id | varchar | ID do cliente | ❌ FK → customers |
| name | varchar | Nome do site | ✅ |
| address | varchar | Endereço do site | ❌ |
| description | text | Descrição do site | ❌ |
| floor_plan_image_url | varchar | URL da planta baixa | ❌ |
| is_active | boolean | Site ativo | ✅ (padrão: true) |
| created_at | timestamp | Data de criação | ✅ (auto) |
| updated_at | timestamp | Data de atualização | ✅ (auto) |

---

### 4. zones (Zonas/Áreas)
Áreas/zonas dentro de um site (ex: Sala 101, Banheiro 2º andar).

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| site_id | varchar | ID do site | ✅ FK → sites |
| name | varchar | Nome da zona | ✅ |
| description | text | Descrição da zona | ❌ |
| area_m2 | decimal(10,2) | Área em m² | ❌ |
| capacity | integer | Capacidade (pessoas) | ❌ |
| category | varchar | Categoria da zona | ❌ |
| position_x | decimal(5,2) | Posição X na planta | ❌ |
| position_y | decimal(5,2) | Posição Y na planta | ❌ |
| size_scale | decimal(3,2) | Escala de tamanho | ❌ |
| color | varchar | Cor da zona | ❌ |
| is_active | boolean | Zona ativa | ✅ (padrão: true) |
| created_at | timestamp | Data de criação | ✅ (auto) |
| updated_at | timestamp | Data de atualização | ✅ (auto) |

---

### 5. users (Usuários do Sistema)
Usuários do sistema (operadores, gestores, administradores).

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| company_id | varchar | ID da empresa | ❌ FK → companies |
| customer_id | varchar | ID do cliente | ❌ FK → customers |
| username | varchar | Nome de usuário | ✅ UNIQUE |
| email | varchar | Email | ✅ UNIQUE |
| password | varchar | Senha (hash Bcrypt) | ❌ |
| name | varchar | Nome completo | ✅ |
| role | user_role | Papel do usuário | ✅ |
| user_type | user_type | Tipo de usuário | ✅ (padrão: opus_user) |
| assigned_client_id | varchar | Cliente atribuído | ❌ |
| auth_provider | auth_provider | Provedor de autenticação | ✅ (padrão: local) |
| external_id | varchar | ID externo (MS Entra) | ❌ |
| ms_tenant_id | varchar | Tenant ID Microsoft | ❌ |
| is_active | boolean | Usuário ativo | ✅ (padrão: true) |
| created_at | timestamp | Data de criação | ✅ (auto) |
| updated_at | timestamp | Data de atualização | ✅ (auto) |

---

### 6. service_types (Tipos de Serviço)
Tipos de serviço disponíveis (ex: Limpeza, Manutenção).

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| name | varchar | Nome do tipo | ✅ |
| description | text | Descrição | ❌ |
| code | varchar | Código único | ✅ UNIQUE |
| is_active | boolean | Tipo ativo | ✅ (padrão: true) |
| created_at | timestamp | Data de criação | ✅ (auto) |
| updated_at | timestamp | Data de atualização | ✅ (auto) |
| customer_id | varchar | ID do cliente | ❌ FK → customers |

---

### 7. service_categories (Categorias de Serviço)
Categorias dentro de tipos de serviço.

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| type_id | varchar | ID do tipo | ❌ FK → service_types |
| name | varchar | Nome da categoria | ✅ |
| description | text | Descrição | ❌ |
| code | varchar | Código único | ✅ UNIQUE |
| is_active | boolean | Categoria ativa | ✅ (padrão: true) |
| created_at | timestamp | Data de criação | ✅ (auto) |
| updated_at | timestamp | Data de atualização | ✅ (auto) |
| customer_id | varchar | ID do cliente | ❌ FK → customers |

---

### 8. services (Serviços Disponíveis)
Serviços específicos que podem ser executados.

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| name | varchar | Nome do serviço | ✅ |
| description | text | Descrição do serviço | ❌ |
| estimated_duration_minutes | integer | Duração estimada (min) | ❌ |
| priority | priority | Prioridade padrão | ✅ (padrão: media) |
| requirements | text | Requisitos | ❌ |
| is_active | boolean | Serviço ativo | ✅ (padrão: true) |
| created_at | timestamp | Data de criação | ✅ (auto) |
| updated_at | timestamp | Data de atualização | ✅ (auto) |
| customer_id | varchar | ID do cliente | ❌ FK → customers |
| category_id | varchar | ID da categoria | ❌ FK → service_categories |
| type_id | varchar | ID do tipo | ❌ FK → service_types |

---

### 9. cleaning_activities (Atividades de Limpeza)
Planos de limpeza recorrentes (programação).

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| company_id | varchar | ID da empresa | ✅ FK → companies |
| service_id | varchar | ID do serviço | ❌ FK → services |
| site_id | varchar | ID do site | ❌ FK → sites |
| zone_id | varchar | ID da zona | ❌ FK → zones |
| name | varchar | Nome da atividade | ✅ |
| description | text | Descrição | ❌ |
| frequency | frequency | Frequência | ✅ |
| frequency_config | jsonb | Configuração da frequência | ❌ |
| checklist_template_id | varchar | ID do checklist | ❌ FK → checklist_templates |
| sla_config_id | varchar | ID do SLA | ❌ FK → sla_configs |
| is_active | boolean | Atividade ativa | ✅ (padrão: true) |
| created_at | timestamp | Data de criação | ✅ (auto) |
| updated_at | timestamp | Data de atualização | ✅ (auto) |
| start_time | time | Horário de início | ❌ |
| end_time | time | Horário de término | ❌ |

---

### 10. checklist_templates (Templates de Checklist)
Templates de checklist para OSs.

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| company_id | varchar | ID da empresa | ✅ FK → companies |
| service_id | varchar | ID do serviço | ❌ FK → services |
| site_id | varchar | ID do site | ❌ FK → sites |
| name | varchar | Nome do template | ✅ |
| description | text | Descrição | ❌ |
| items | jsonb | Itens do checklist (JSON) | ✅ |
| created_at | timestamp | Data de criação | ✅ (auto) |
| updated_at | timestamp | Data de atualização | ✅ (auto) |
| zone_id | varchar | ID da zona | ❌ FK → zones |

**Estrutura do campo `items` (JSON):**
```json
[
  {
    "id": "item-123",
    "label": "Limpar chão",
    "type": "checkbox",
    "required": true,
    "description": "Varrer e passar pano"
  },
  {
    "id": "item-456",
    "label": "Anexar foto",
    "type": "photo",
    "required": false,
    "minPhotos": 1
  }
]
```

---

### 11. work_orders (Ordens de Serviço) ⭐
**Tabela central do sistema** - Ordens de trabalho/serviço.

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| number | integer | Número sequencial da OS | ✅ |
| company_id | varchar | ID da empresa | ✅ FK → companies |
| zone_id | varchar | ID da zona | ❌ FK → zones |
| service_id | varchar | ID do serviço | ❌ FK → services |
| cleaning_activity_id | varchar | ID da atividade de limpeza | ❌ FK → cleaning_activities |
| checklist_template_id | varchar | ID do template checklist | ❌ FK → checklist_templates |
| type | work_order_type | Tipo da OS | ✅ |
| status | work_order_status | Status atual | ✅ (padrão: aberta) |
| priority | priority | Prioridade | ✅ (padrão: media) |
| title | varchar | Título da OS | ✅ |
| description | text | Descrição detalhada | ❌ |
| assigned_user_id | varchar | Operador atribuído | ❌ FK → users |
| origin | varchar | Origem da OS | ❌ |
| qr_code_point_id | varchar | QR code de origem | ❌ FK → qr_code_points |
| requester_name | varchar | Nome do solicitante | ❌ |
| requester_contact | varchar | Contato do solicitante | ❌ |
| scheduled_date | date | Data agendada (YYYY-MM-DD) | ❌ |
| due_date | date | Data de vencimento | ❌ |
| scheduled_start_at | timestamp | Início programado | ❌ |
| scheduled_end_at | timestamp | Fim programado | ❌ |
| started_at | timestamp | Início real da execução | ❌ |
| completed_at | timestamp | Conclusão da OS | ❌ |
| estimated_hours | decimal(5,2) | Horas estimadas | ❌ |
| sla_start_minutes | integer | SLA para iniciar (min) | ❌ |
| sla_complete_minutes | integer | SLA para concluir (min) | ❌ |
| observations | text | Observações | ❌ |
| checklist_data | jsonb | Dados do checklist preenchido | ❌ |
| attachments | jsonb | Anexos (fotos, etc) | ❌ |
| customer_rating | integer | Avaliação do cliente (1-5) | ❌ |
| customer_rating_comment | text | Comentário da avaliação | ❌ |
| rated_at | timestamp | Data da avaliação | ❌ |
| rated_by | varchar | Avaliador | ❌ FK → users |
| created_at | timestamp | Data de criação | ✅ (auto) |
| updated_at | timestamp | Data de atualização | ✅ (auto) |

**Índice único:** `work_orders_company_number_unique` (company_id, number)

**Estrutura do campo `checklist_data` (JSON):**
```json
{
  "item-123": true,
  "item-456": {
    "type": "photo",
    "photos": ["url1", "url2"],
    "count": 2
  },
  "item-789": "Texto de resposta"
}
```

---

### 12. qr_code_points (Pontos de QR Code)
QR codes físicos instalados nos sites.

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| zone_id | varchar | ID da zona | ✅ FK → zones |
| service_id | varchar | ID do serviço | ❌ FK → services |
| code | varchar | Código do QR | ✅ UNIQUE |
| type | qr_code_type | Tipo do QR code | ✅ |
| name | varchar | Nome descritivo | ✅ |
| description | text | Descrição | ❌ |
| size_cm | integer | Tamanho em cm | ✅ (padrão: 5) |
| is_active | boolean | QR code ativo | ✅ (padrão: true) |
| created_at | timestamp | Data de criação | ✅ (auto) |
| updated_at | timestamp | Data de atualização | ✅ (auto) |

---

### 13. work_order_comments (Comentários em OSs)
Comentários e histórico de OSs.

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| work_order_id | varchar | ID da OS | ✅ FK → work_orders |
| user_id | varchar | ID do usuário | ✅ FK → users |
| comment | text | Texto do comentário | ✅ |
| attachments | jsonb | Anexos (fotos) | ❌ |
| is_reopen_request | boolean | Pedido de reabertura | ✅ (padrão: false) |
| created_at | timestamp | Data de criação | ✅ (auto) |
| updated_at | timestamp | Data de atualização | ✅ (auto) |

**Comentários de sistema:**
- Início: `⏯️ [Nome] iniciou a execução da OS`
- Pausa: `⏸️ [Nome] pausou a OS\n\n📝 Motivo: [motivo]`
- Retomada: `▶️ [Nome] retomou a execução da OS`
- Conclusão: `✅ OS Finalizada! Checklist: ...`

---

## 🔗 Tabelas de Relacionamento

### 14. service_zones (Serviços x Zonas)
Relacionamento N:N entre serviços e zonas.

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| service_id | varchar | ID do serviço | ✅ FK → services |
| zone_id | varchar | ID da zona | ✅ FK → zones |
| is_active | boolean | Relacionamento ativo | ✅ (padrão: true) |
| created_at | timestamp | Data de criação | ✅ (auto) |
| updated_at | timestamp | Data de atualização | ✅ (auto) |

**Constraint único:** `unique_service_zone` (service_id, zone_id)

---

### 15. user_site_assignments (Usuários x Sites)
Sites atribuídos a usuários.

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| user_id | varchar | ID do usuário | ✅ FK → users |
| site_id | varchar | ID do site | ✅ FK → sites |
| created_at | timestamp | Data de criação | ✅ (auto) |
| updated_at | timestamp | Data de atualização | ✅ (auto) |

---

### 16. user_role_assignments (Usuários x Roles)
Atribuição de roles customizados a usuários.

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| user_id | varchar | ID do usuário | ✅ FK → users |
| role_id | varchar | ID do role | ✅ FK → custom_roles |
| customer_id | varchar | ID do cliente | ❌ FK → customers |
| created_at | timestamp | Data de criação | ✅ (auto) |

---

## ⚙️ Tabelas de Configuração

### 17. custom_roles (Roles Customizados)
Roles personalizados do sistema.

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| company_id | varchar | ID da empresa | ✅ FK → companies |
| name | varchar | Nome do role | ✅ |
| description | text | Descrição | ❌ |
| is_system_role | boolean | Role do sistema | ✅ (padrão: false) |
| is_active | boolean | Role ativo | ✅ (padrão: true) |
| created_at | timestamp | Data de criação | ✅ (auto) |
| updated_at | timestamp | Data de atualização | ✅ (auto) |

**System Roles:**
- Administrador
- Cliente
- Operador

---

### 18. role_permissions (Permissões por Role)
Permissões atribuídas a cada role.

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| role_id | varchar | ID do role | ✅ FK → custom_roles |
| permission | permission_key | Chave da permissão | ✅ |
| created_at | timestamp | Data de criação | ✅ (auto) |

---

### 19. sla_configs (Configurações de SLA)
SLAs para tipos de OSs.

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| company_id | varchar | ID da empresa | ✅ FK → companies |
| name | varchar | Nome do SLA | ✅ |
| category | varchar | Categoria | ❌ |
| time_to_start_minutes | integer | Tempo para iniciar (min) | ✅ |
| time_to_complete_minutes | integer | Tempo para concluir (min) | ✅ |
| created_at | timestamp | Data de criação | ✅ (auto) |
| updated_at | timestamp | Data de atualização | ✅ (auto) |

---

### 20. site_shifts (Turnos por Site)
Turnos de trabalho em cada site.

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| site_id | varchar | ID do site | ✅ FK → sites |
| name | varchar | Nome do turno | ✅ |
| start_time | time | Horário de início | ✅ |
| end_time | time | Horário de fim | ✅ |
| is_active | boolean | Turno ativo | ✅ (padrão: true) |
| created_at | timestamp | Data de criação | ✅ (auto) |
| updated_at | timestamp | Data de atualização | ✅ (auto) |

---

### 21. dashboard_goals (Metas do Dashboard)
Metas de performance do dashboard.

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| company_id | varchar | ID da empresa | ✅ FK → companies |
| goal_type | varchar | Tipo de meta | ✅ |
| goal_value | decimal(10,2) | Valor da meta | ✅ |
| current_period | varchar | Período atual | ✅ |
| is_active | boolean | Meta ativa | ✅ (padrão: true) |
| created_at | timestamp | Data de criação | ✅ (auto) |
| updated_at | timestamp | Data de atualização | ✅ (auto) |

---

### 22. webhook_configs (Configurações de Webhooks)
Webhooks para integrações externas.

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| company_id | varchar | ID da empresa | ✅ FK → companies |
| name | varchar | Nome do webhook | ✅ |
| url | varchar | URL do webhook | ✅ |
| events | jsonb | Eventos que disparam | ✅ |
| is_active | boolean | Webhook ativo | ✅ (padrão: true) |
| created_at | timestamp | Data de criação | ✅ (auto) |
| updated_at | timestamp | Data de atualização | ✅ (auto) |

---

### 23. company_counters (Contadores da Empresa)
Contadores sequenciais (ex: número de OS).

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| company_id | varchar | ID da empresa | ✅ FK → companies |
| key | varchar | Chave do contador | ✅ |
| next_number | integer | Próximo número | ✅ (padrão: 1) |
| updated_at | timestamp | Data de atualização | ✅ (auto) |

---

### 24. bathroom_counters (Contadores de Banheiro)
Sistema de contagem de uso de banheiros.

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| zone_id | varchar | ID da zona | ✅ FK → zones |
| current_count | integer | Contagem atual | ✅ (padrão: 0) |
| limit_count | integer | Limite de contagem | ✅ |
| last_reset | timestamp | Último reset | ✅ (auto) |
| auto_reset_turn | boolean | Reset automático por turno | ✅ (padrão: true) |
| created_at | timestamp | Data de criação | ✅ (auto) |
| updated_at | timestamp | Data de atualização | ✅ (auto) |

---

## 📝 Tabelas de Logs

### 25. audit_logs (Logs de Auditoria)
Logs de todas as ações no sistema.

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| company_id | varchar | ID da empresa | ❌ FK → companies |
| user_id | varchar | ID do usuário | ❌ FK → users |
| entity_type | varchar | Tipo da entidade | ✅ |
| entity_id | varchar | ID da entidade | ✅ |
| action | varchar | Ação realizada | ✅ |
| changes | jsonb | Mudanças realizadas | ❌ |
| metadata | jsonb | Metadados adicionais | ❌ |
| timestamp | timestamp | Data/hora da ação | ✅ (auto) |
| created_at | timestamp | Data de criação | ✅ (auto) |

---

### 26. bathroom_counter_logs (Logs dos Contadores)
Histórico de mudanças nos contadores de banheiro.

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| counter_id | varchar | ID do contador | ✅ FK → bathroom_counters |
| user_id | varchar | ID do usuário | ❌ FK → users |
| delta | integer | Mudança no valor | ✅ |
| action | bathroom_counter_action | Tipo de ação | ✅ |
| previous_value | integer | Valor anterior | ✅ |
| new_value | integer | Novo valor | ✅ |
| work_order_id | varchar | OS relacionada | ❌ FK → work_orders |
| created_at | timestamp | Data de criação | ✅ (auto) |

---

### 27. public_request_logs (Logs de Solicitações Públicas)
Logs de solicitações via QR codes públicos.

| Campo | Tipo | Descrição | Obrigatório |
|-------|------|-----------|-------------|
| id | varchar | Identificador único | ✅ PK |
| qr_code_point_id | varchar | ID do QR code | ❌ FK → qr_code_points |
| ip_hash | varchar | Hash do IP | ✅ |
| user_agent | text | User agent do navegador | ❌ |
| request_data | jsonb | Dados da solicitação | ❌ |
| created_at | timestamp | Data de criação | ✅ (auto) |

---

## 🔐 Campos Especiais e Regras de Negócio

### Campos de Data com Timezone Fix

Os campos `scheduled_date` e `due_date` nas work_orders usam transformação especial para evitar problemas de timezone:

```typescript
// Schema
scheduledDate: date("scheduled_date")

// Transformação aplicada no Zod
.transform((val) => {
  if (!val) return null;
  if (typeof val === 'string') return val;
  return val.toISOString().split('T')[0];
})
```

**Formato:** `YYYY-MM-DD` (string, sem conversão para Date object)

---

### IDs Gerados

Todos os IDs são `varchar` gerados via `nanoid()` ou padrões customizados:

**Exemplos:**
- Companies: `company-opus-default`
- Users: `user-operador.teste2-1761934891110`
- Work Orders: `7e7a1990-fca8-44bb-a58a-bcf8ffa3c81a`
- Checklist Templates: `checklist-1759332028080-yP1zdZiE7V`

---

### Campos JSONB Estruturados

#### checklist_templates.items
```json
[
  {
    "id": "1759332012650",
    "label": "Anexar fotos antes",
    "type": "photo",
    "required": true,
    "minPhotos": 2
  }
]
```

#### work_orders.checklist_data
```json
{
  "1759332012650": {
    "type": "photo",
    "photos": ["url1.jpg", "url2.jpg"],
    "count": 2
  },
  "1759436504239": "Sim"
}
```

#### work_orders.attachments
```json
[
  {
    "url": "https://...",
    "type": "image/jpeg",
    "uploadedBy": "user-id",
    "uploadedAt": "2025-10-31T18:30:00Z"
  }
]
```

---

### Numeração Sequencial de OSs

Work orders têm numeração sequencial por empresa usando `company_counters`:

```sql
-- Índice único
UNIQUE INDEX work_orders_company_number_unique (company_id, number)
```

**Exemplo:**
- Empresa A: OS #1, #2, #3...
- Empresa B: OS #1, #2, #3... (numeração independente)

---

## 🔄 Relacionamentos Principais

```
companies
  ├── customers
  │     └── sites
  │           └── zones
  │                 ├── qr_code_points
  │                 ├── bathroom_counters
  │                 └── service_zones
  │
  ├── users
  │     ├── user_site_assignments
  │     ├── user_role_assignments
  │     ├── work_order_comments
  │     └── assigned_work_orders
  │
  ├── work_orders (CENTRAL)
  │     ├── work_order_comments
  │     ├── zone
  │     ├── service
  │     ├── assigned_user
  │     └── checklist_template
  │
  ├── cleaning_activities
  ├── checklist_templates
  ├── custom_roles
  │     └── role_permissions
  └── sla_configs
```

---

## 📊 Estatísticas do Banco

- **Total de Tabelas:** 27
- **Total de Enums:** 11
- **Tabela Central:** work_orders (maior volume de dados)
- **Campos JSONB:** 13
- **Campos com Timezone Fix:** 2 (scheduled_date, due_date)
- **Relacionamentos N:N:** 3 (service_zones, user_site_assignments, user_role_assignments)

---

## 🚀 Comandos Úteis

### Push do Schema para Banco
```bash
npm run db:push
```

### Force Push (quando há warnings de data-loss)
```bash
npm run db:push --force
```

### Seed do Banco
```bash
npm run db:seed
```

---

## 📌 Notas Importantes

1. **Multi-tenancy:** Sistema isolado por `company_id`
2. **Soft Delete:** Uso de `is_active` em vez de delete físico
3. **Auditoria:** Toda mudança crítica é registrada em `audit_logs`
4. **Segurança:** Senhas em Bcrypt, JWT para autenticação
5. **Performance:** Índices em campos FK e campos de busca frequente
6. **Timezone:** Campos de data pura usam transformação para evitar timezone issues

---

**Última atualização:** Novembro 2025  
**Versão:** 1.0  
**Mantido por:** Equipe OPUS Clean
