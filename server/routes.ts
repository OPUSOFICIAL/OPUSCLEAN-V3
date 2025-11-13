import type { Express } from "express";
import { createServer, type Server } from "http";
import { storage } from "./storage";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import rateLimit from "express-rate-limit";
import { 
  insertCompanySchema, insertSiteSchema, insertZoneSchema, insertQrCodePointSchema,
  insertUserSchema, insertChecklistTemplateSchema, insertSlaConfigSchema,
  insertCleaningActivitySchema, insertWorkOrderSchema, insertBathroomCounterSchema,
  insertWebhookConfigSchema, insertServiceSchema, insertServiceTypeSchema, insertServiceCategorySchema,
  insertDashboardGoalSchema, insertCustomerSchema,
  insertCustomRoleSchema, insertRolePermissionSchema, insertUserRoleAssignmentSchema,
  insertUserSiteAssignmentSchema, insertPublicRequestLogSchema, insertSiteShiftSchema,
  insertBathroomCounterLogSchema, insertCompanyCounterSchema,
  insertEquipmentSchema, insertMaintenanceChecklistTemplateSchema,
  insertMaintenanceChecklistExecutionSchema, insertMaintenancePlanSchema,
  insertMaintenancePlanEquipmentSchema, insertMaintenanceActivitySchema,
  insertAiIntegrationSchema,
  syncBatchRequestSchema,
  customers,
  type User, type InsertUser
} from "@shared/schema";
import { nanoid } from "nanoid";
import { z } from "zod";
import crypto from "crypto";
import { db } from "./db";
import { eq, and, ne } from "drizzle-orm";
import {
  requireAuth,
  requireAdmin,
  requireManageClients,
  requireManageUsers,
  requireManageWorkOrders,
  requireViewReports,
  requireOwnCustomer,
  requireOpusUser
} from "./middleware/auth";
import { sanitizeUser, sanitizeUsers } from "./utils/security";
import { serializeForAI } from "./utils/serialization";

const JWT_SECRET = process.env.JWT_SECRET || 'kJsXXrXanldoNcZJG/iHeTEI8WdMch4PFWNIao1llTU=';

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  message: { message: "Muitas tentativas de login. Tente novamente em 15 minutos." },
  standardHeaders: true,
  legacyHeaders: false,
});

export async function registerRoutes(app: Express): Promise<Server> {
  
  // Companies
  app.get("/api/companies", async (req, res) => {
    try {
      const companies = await storage.getCompanies();
      res.json(companies);
    } catch (error) {
      res.status(500).json({ message: "Failed to get companies" });
    }
  });

  app.get("/api/companies/:id", async (req, res) => {
    try {
      const company = await storage.getCompany(req.params.id);
      if (!company) {
        return res.status(404).json({ message: "Company not found" });
      }
      res.json(company);
    } catch (error) {
      res.status(500).json({ message: "Failed to get company" });
    }
  });

  app.post("/api/companies", async (req, res) => {
    try {
      const company = insertCompanySchema.parse(req.body);
      const newCompany = await storage.createCompany(company);
      res.status(201).json(newCompany);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      res.status(500).json({ message: "Failed to create company" });
    }
  });

  app.put("/api/companies/:id", async (req, res) => {
    try {
      const company = insertCompanySchema.partial().parse(req.body);
      const updatedCompany = await storage.updateCompany(req.params.id, company);
      res.json(updatedCompany);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      res.status(500).json({ message: "Failed to update company" });
    }
  });

  // Sites
  app.get("/api/companies/:companyId/sites", async (req, res) => {
    try {
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const sites = await storage.getSitesByCompany(req.params.companyId, module);
      res.json(sites);
    } catch (error) {
      res.status(500).json({ message: "Failed to get sites" });
    }
  });

  // Get sites by customer
  app.get("/api/customers/:customerId/sites", async (req, res) => {
    try {
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const sites = await storage.getSitesByCustomer(req.params.customerId, module);
      res.json(sites);
    } catch (error) {
      res.status(500).json({ message: "Failed to get sites" });
    }
  });

  // Create site for customer (new route for customer filtering)
  app.post("/api/customers/:customerId/sites", requireManageWorkOrders, async (req, res) => {
    try {
      console.log("Creating site with data:", req.body, "customerId:", req.params.customerId);
      
      // Get the customer to find their companyId
      const customer = await storage.getCustomer(req.params.customerId);
      if (!customer) {
        return res.status(404).json({ message: "Customer not found" });
      }
      
      const dataToValidate = {
        ...req.body,
        customerId: req.params.customerId,
        companyId: customer.companyId
      };
      
      console.log("Site data to validate:", dataToValidate);
      
      const site = insertSiteSchema.parse(dataToValidate);
      const newSite = await storage.createSite(site);
      res.status(201).json(newSite);
    } catch (error) {
      if (error instanceof z.ZodError) {
        console.error("Validation error creating site:", error.errors);
        return res.status(400).json({ message: "Dados inválidos", errors: error.errors });
      }
      console.error("Error creating site:", error);
      res.status(500).json({ message: "Erro ao criar local" });
    }
  });

  app.get("/api/sites/:id", async (req, res) => {
    try {
      const site = await storage.getSite(req.params.id);
      if (!site) {
        return res.status(404).json({ message: "Site not found" });
      }
      res.json(site);
    } catch (error) {
      res.status(500).json({ message: "Failed to get site" });
    }
  });

  app.post("/api/sites", async (req, res) => {
    try {
      const site = insertSiteSchema.parse({
        ...req.body,
        module: req.body.module || 'clean'
      });
      const newSite = await storage.createSite(site);
      res.status(201).json(newSite);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      res.status(500).json({ message: "Failed to create site" });
    }
  });

  app.put("/api/sites/:id", async (req, res) => {
    try {
      const site = insertSiteSchema.partial().parse(req.body);
      const updatedSite = await storage.updateSite(req.params.id, site);
      res.json(updatedSite);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      res.status(500).json({ message: "Failed to update site" });
    }
  });

  app.delete("/api/sites/:id", async (req, res) => {
    try {
      await storage.deleteSite(req.params.id);
      res.json({ message: "Site excluído com sucesso" });
    } catch (error) {
      console.error("Erro ao excluir site:", error);
      res.status(500).json({ 
        message: error instanceof Error ? error.message : "Falha ao excluir site" 
      });
    }
  });

  // Zones
  app.get("/api/companies/:companyId/zones", async (req, res) => {
    try {
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const zones = await storage.getZonesByCompany(req.params.companyId, module);
      res.json(zones);
    } catch (error) {
      res.status(500).json({ message: "Failed to get zones" });
    }
  });

  // QR Code Points by Company
  app.get("/api/companies/:companyId/qr-points", async (req, res) => {
    try {
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const qrPoints = await storage.getQrCodePointsByCompany(req.params.companyId, module);
      res.json(qrPoints);
    } catch (error) {
      res.status(500).json({ message: "Failed to get QR code points" });
    }
  });

  // QR Points by Customer (filtrado por cliente)
  app.get("/api/customers/:customerId/qr-points", async (req, res) => {
    try {
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const qrPoints = await storage.getQrCodePointsByCustomer(req.params.customerId, module);
      res.json(qrPoints);
    } catch (error) {
      res.status(500).json({ message: "Failed to get customer QR code points" });
    }
  });

  // Cleaning Activities by Customer (filtrado por cliente)
  app.get("/api/customers/:customerId/cleaning-activities", async (req, res) => {
    try {
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const activities = await storage.getCleaningActivitiesByCustomer(req.params.customerId, module);
      res.json(activities);
    } catch (error) {
      res.status(500).json({ message: "Failed to get customer cleaning activities" });
    }
  });

  // Services by Customer (filtrado por cliente)
  app.get("/api/customers/:customerId/services", async (req, res) => {
    try {
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const services = await storage.getServicesByCustomer(req.params.customerId, module);
      res.json(services);
    } catch (error) {
      res.status(500).json({ message: "Failed to get customer services" });
    }
  });

  // Users by Customer (filtrado por cliente)
  app.get("/api/customers/:customerId/users", async (req, res) => {
    try {
      const users = await storage.getUsersByCustomer(req.params.customerId);
      
      // Para cada usuário, buscar seus roles customizados, sites vinculados e remover senha
      const usersWithRoles = await Promise.all(
        users.map(async (user) => {
          const roleAssignments = await storage.getUserRoleAssignments(user.id);
          const siteAssignments = await storage.getUserSiteAssignments(user.id);
          const sanitized = sanitizeUser(user);
          return {
            ...sanitized,
            customRoles: roleAssignments,
            siteAssignments: siteAssignments
          };
        })
      );
      
      res.json(usersWithRoles);
    } catch (error) {
      res.status(500).json({ message: "Failed to get customer users" });
    }
  });

  // Checklist Templates by Customer (filtrado por cliente)  
  app.get("/api/customers/:customerId/checklist-templates", async (req, res) => {
    try {
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const templates = await storage.getChecklistTemplatesByCustomer(req.params.customerId, module);
      res.json(templates);
    } catch (error) {
      res.status(500).json({ message: "Failed to get customer checklist templates" });
    }
  });

  app.post("/api/customers/:customerId/checklist-templates", async (req, res) => {
    try {
      // Validate that the checklist belongs to the customer
      const customerSites = await storage.getSitesByCustomer(req.params.customerId);
      if (customerSites.length === 0) {
        return res.status(404).json({ message: "Customer not found" });
      }
      
      // Use the first site's company for the checklist template
      const companyId = customerSites[0].companyId;
      
      // Keep arrays for multi-site/zone support + ADD customerId for multi-tenant security
      const checklistData = { 
        ...req.body, 
        companyId,
        customerId: req.params.customerId,
      };
      
      console.log("[CHECKLIST CREATE] Data:", JSON.stringify(checklistData, null, 2));
      
      const template = await storage.createChecklistTemplate(checklistData);
      res.json(template);
    } catch (error: any) {
      console.error("Error creating checklist template:", error?.message || error);
      console.error("Stack:", error?.stack);
      res.status(500).json({ message: error?.message || "Failed to create customer checklist template" });
    }
  });

  app.put("/api/customers/:customerId/checklist-templates/:id", async (req, res) => {
    try {
      // Validate that the customer exists and get their company
      const customerSites = await storage.getSitesByCustomer(req.params.customerId);
      if (customerSites.length === 0) {
        return res.status(404).json({ message: "Customer not found" });
      }

      const companyId = customerSites[0].companyId;
      
      // Verify the template belongs to this customer (multi-tenant security)
      const existingTemplate = await storage.getChecklistTemplate(req.params.id);
      if (!existingTemplate || existingTemplate.customerId !== req.params.customerId) {
        return res.status(403).json({ message: "Checklist template not found or access denied" });
      }

      // Keep arrays for multi-site/zone support + ensure customerId stays correct
      const checklistData = { 
        ...req.body, 
        companyId,
        customerId: req.params.customerId,
      };
      
      console.log("[CHECKLIST UPDATE] Data:", JSON.stringify(checklistData, null, 2));
      
      const template = await storage.updateChecklistTemplate(req.params.id, checklistData);
      res.json(template);
    } catch (error) {
      res.status(500).json({ message: "Failed to update customer checklist template" });
    }
  });

  app.delete("/api/customers/:customerId/checklist-templates/:id", async (req, res) => {
    try {
      // Validate that the customer exists
      const customerSites = await storage.getSitesByCustomer(req.params.customerId);
      if (customerSites.length === 0) {
        return res.status(404).json({ message: "Customer not found" });
      }
      
      // Verify the template belongs to this customer (multi-tenant security)
      const existingTemplate = await storage.getChecklistTemplate(req.params.id);
      if (!existingTemplate || existingTemplate.customerId !== req.params.customerId) {
        return res.status(403).json({ message: "Checklist template not found or access denied" });
      }

      // Check if checklist is being used by work orders
      const workOrdersUsingChecklist = await storage.getWorkOrdersByChecklistTemplate(req.params.id);
      if (workOrdersUsingChecklist.length > 0) {
        return res.status(409).json({ 
          message: "Checklist não pode ser excluído pois está sendo usado por ordens de serviço",
          workOrdersCount: workOrdersUsingChecklist.length
        });
      }

      await storage.deleteChecklistTemplate(req.params.id);
      res.json({ success: true });
    } catch (error) {
      res.status(500).json({ message: "Failed to delete customer checklist template" });
    }
  });

  // Work Orders by Customer - List (filtrado por cliente)
  app.get("/api/customers/:customerId/work-orders", async (req, res) => {
    try {
      // Validate that the customer exists
      const customerSites = await storage.getSitesByCustomer(req.params.customerId);
      if (customerSites.length === 0) {
        return res.status(404).json({ message: "Customer not found" });
      }

      // Get all work orders for this customer
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      let workOrders = await storage.getWorkOrdersByCustomer(req.params.customerId, module);
      
      // Apply filters from query params
      const { zoneId, assignedTo, status, serviceId, includeAll } = req.query;
      
      // Automatically filter out canceled work orders for mobile/collaborators
      // unless explicitly requesting all statuses or a specific status
      if (!status && includeAll !== 'true') {
        workOrders = workOrders.filter(wo => wo.status !== 'cancelada');
      }
      
      // Filter by zone if provided
      if (zoneId) {
        workOrders = workOrders.filter(wo => wo.zoneId === zoneId);
      }
      
      // Filter by assignedTo if provided (include unassigned work orders and paused ones)
      if (assignedTo) {
        workOrders = workOrders.filter(wo => 
          wo.assignedUserId === assignedTo || 
          wo.assignedUserId === null || 
          wo.status === 'pausada' // Operadores podem ver O.S. pausadas por qualquer colaborador
        );
      }
      
      // Filter by status if provided
      if (status) {
        workOrders = workOrders.filter(wo => wo.status === status);
      }
      
      // Filter by serviceId if provided
      if (serviceId) {
        workOrders = workOrders.filter(wo => wo.serviceId === serviceId);
      }
      
      res.json(workOrders);
    } catch (error) {
      console.error("Error fetching customer work orders:", error);
      res.status(500).json({ message: "Failed to fetch customer work orders" });
    }
  });

  // Dashboard stats by Customer
  app.get("/api/customers/:customerId/dashboard-stats/:period/:siteId", async (req, res) => {
    try {
      const { customerId, period, siteId } = req.params;
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      
      // Verify customer exists
      const customer = await storage.getCustomer(customerId);
      if (!customer) {
        return res.status(404).json({ message: "Customer not found" });
      }
      
      // Get stats filtered by customer's sites (pode ser vazio se não houver sites)
      const stats = await storage.getDashboardStatsByCustomer(customerId, period, siteId === 'todos' ? '' : siteId, module);
      res.json(stats);
    } catch (error) {
      console.error("Error fetching customer dashboard stats:", error);
      res.status(500).json({ message: "Failed to get dashboard stats" });
    }
  });

  // Analytics by Customer
  app.get("/api/customers/:customerId/analytics/:period/:siteId", async (req, res) => {
    try {
      const { customerId, period, siteId } = req.params;
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      
      // Verify customer exists
      const customer = await storage.getCustomer(customerId);
      if (!customer) {
        return res.status(404).json({ message: "Customer not found" });
      }
      
      // Get analytics filtered by customer (pode ser vazio se não houver sites/work orders)
      const analytics = await storage.getAnalyticsByCustomer(customerId, period, siteId === 'todos' ? '' : siteId, module);
      res.json(analytics);
    } catch (error) {
      console.error("Error fetching customer analytics:", error);
      res.status(500).json({ message: "Failed to get performance analytics" });
    }
  });

  // Work Orders by Customer - Create (filtrado por cliente)
  app.post("/api/customers/:customerId/work-orders", async (req, res) => {
    try {
      // Validate that the customer exists
      const customerSites = await storage.getSitesByCustomer(req.params.customerId);
      if (customerSites.length === 0) {
        return res.status(404).json({ message: "Customer not found" });
      }
      
      // Validate that site belongs to customer
      if (req.body.siteId) {
        const site = await storage.getSite(req.body.siteId);
        if (!site || site.customerId !== req.params.customerId) {
          return res.status(403).json({ message: "Site does not belong to customer" });
        }
      }

      // Validate that zone belongs to customer (via site)
      if (req.body.zoneId) {
        const zone = await storage.getZone(req.body.zoneId);
        if (zone) {
          const zoneSite = await storage.getSite(zone.siteId);
          if (!zoneSite || zoneSite.customerId !== req.params.customerId) {
            return res.status(403).json({ message: "Zone does not belong to customer" });
          }
        }
      }
      
      const workOrder = await storage.createWorkOrder(req.body);
      res.json(workOrder);
    } catch (error) {
      res.status(500).json({ message: "Failed to create customer work order" });
    }
  });

  // Work Orders by Customer - Delete (filtrado por cliente) - APENAS ADMIN
  app.delete("/api/customers/:customerId/work-orders/:id", requireAdmin, async (req, res) => {
    try {
      // Validate that the customer exists
      const customerSites = await storage.getSitesByCustomer(req.params.customerId);
      if (customerSites.length === 0) {
        return res.status(404).json({ message: "Customer not found" });
      }

      // Verify the work order belongs to this customer by checking its site
      const workOrder = await storage.getWorkOrder(req.params.id);
      if (!workOrder) {
        return res.status(404).json({ message: "Work order not found" });
      }

      // Get zone first, then site
      if (!workOrder.zoneId) {
        return res.status(400).json({ message: "Work order has no zone" });
      }
      const zone = await storage.getZone(workOrder.zoneId);
      if (!zone) {
        return res.status(404).json({ message: "Zone not found" });
      }
      const workOrderSite = await storage.getSite(zone.siteId);
      if (!workOrderSite || workOrderSite.customerId !== req.params.customerId) {
        return res.status(403).json({ message: "Work order not found or access denied" });
      }

      await storage.deleteWorkOrder(req.params.id);
      res.json({ success: true });
    } catch (error) {
      res.status(500).json({ message: "Failed to delete customer work order" });
    }
  });

  // QR Points by Customer - Create (filtrado por cliente)
  app.post("/api/customers/:customerId/qr-points", async (req, res) => {
    try {
      // Validate that the customer exists
      const customerSites = await storage.getSitesByCustomer(req.params.customerId);
      if (customerSites.length === 0) {
        return res.status(404).json({ message: "Customer not found" });
      }
      
      // Validate that zone belongs to customer
      if (req.body.zoneId) {
        const zone = await storage.getZone(req.body.zoneId);
        if (zone) {
          const zoneSite = await storage.getSite(zone.siteId);
          if (!zoneSite || zoneSite.customerId !== req.params.customerId) {
            return res.status(403).json({ message: "Zone does not belong to customer" });
          }
        }
      }
      
      // Parse and validate the request body
      const qrPointData = insertQrCodePointSchema.parse(req.body);
      const qrPoint = await storage.createQrCodePoint(qrPointData);
      res.json(qrPoint);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      res.status(500).json({ message: "Failed to create customer QR point" });
    }
  });


  // Reports by Customer (filtrado por cliente)
  app.get("/api/customers/:customerId/reports/metrics", async (req, res) => {
    try {
      const period = req.query.period as string || "30";
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const analytics = await storage.getAnalyticsByCustomer(req.params.customerId, period, "todos", module);
      res.json(analytics);
    } catch (error) {
      res.status(500).json({ message: "Failed to get customer metrics" });
    }
  });

  app.get("/api/customers/:customerId/reports/work-orders-status", async (req, res) => {
    try {
      const period = req.query.period as string || "30";
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const analytics = await storage.getAnalyticsByCustomer(req.params.customerId, period, "todos", module);
      
      // Transform statusBreakdown to the format expected by frontend
      const statusLabels: Record<string, string> = {
        'aberta': 'Aberta',
        'em_execucao': 'Em Execução',
        'concluida': 'Concluída',
        'vencida': 'Vencida',
        'cancelada': 'Cancelada'
      };
      
      const statusColors: Record<string, string> = {
        'aberta': 'bg-yellow-500',
        'em_execucao': 'bg-blue-500',
        'concluida': 'bg-green-500',
        'vencida': 'bg-red-500',
        'cancelada': 'bg-gray-500'
      };
      
      const workOrdersStatus = (analytics?.statusBreakdown || []).map((item: any) => ({
        status: item.status,
        label: statusLabels[item.status] || item.status,
        count: item.count,
        color: statusColors[item.status] || 'bg-gray-500',
        percentage: item.percentage
      }));
      
      res.json(workOrdersStatus);
    } catch (error) {
      res.status(500).json({ message: "Failed to get customer work orders status" });
    }
  });

  app.get("/api/customers/:customerId/reports/sla-performance", async (req, res) => {
    try {
      const period = req.query.period as string || "30";
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const analytics = await storage.getAnalyticsByCustomer(req.params.customerId, period, "todos", module);
      res.json(analytics?.slaPerformance || {});
    } catch (error) {
      res.status(500).json({ message: "Failed to get customer SLA performance" });
    }
  });

  // NOVOS ENDPOINTS ESPECÍFICOS PARA CADA TIPO DE RELATÓRIO

  // 1. Relatório Geral - Visão completa das operações com todos os KPIs principais  
  app.get("/api/customers/:customerId/reports/general", async (req, res) => {
    try {
      const { customerId } = req.params;
      const period = req.query.period as string || '30';
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const generalReport = await storage.getGeneralReport(customerId, period, module);
      res.json(generalReport);
    } catch (error) {
      res.status(500).json({ message: "Failed to get general report" });
    }
  });

  // 2. Análise de SLA - Performance detalhada de cumprimento de prazos
  app.get("/api/customers/:customerId/reports/sla-analysis", async (req, res) => {
    try {
      const { customerId } = req.params;
      const period = req.query.period as string || '30';
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const slaAnalysis = await storage.getSLAAnalysis(customerId, period, module);
      res.json(slaAnalysis);
    } catch (error) {
      res.status(500).json({ message: "Failed to get SLA analysis" });
    }
  });

  // 3. Produtividade - Métricas de eficiência e produtividade operacional
  app.get("/api/customers/:customerId/reports/productivity", async (req, res) => {
    try {
      const { customerId } = req.params;
      const period = req.query.period as string || '30';
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const productivityReport = await storage.getProductivityReport(customerId, period, module);
      res.json(productivityReport);
    } catch (error) {
      res.status(500).json({ message: "Failed to get productivity report" });
    }
  });

  // 4. Performance de Operadores - Análise individual e comparativa
  app.get("/api/customers/:customerId/reports/operators", async (req, res) => {
    try {
      const { customerId } = req.params;
      const period = req.query.period as string || '30';
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const operatorPerformance = await storage.getOperatorPerformance(customerId, period, module);
      res.json(operatorPerformance);
    } catch (error) {
      res.status(500).json({ message: "Failed to get operator performance" });
    }
  });

  // 5. Análise por Locais - Distribuição e performance por zona e site
  app.get("/api/customers/:customerId/reports/locations", async (req, res) => {
    try {
      const { customerId } = req.params;
      const period = req.query.period as string || '30';
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const locationAnalysis = await storage.getLocationAnalysis(customerId, period, module);
      res.json(locationAnalysis);
    } catch (error) {
      res.status(500).json({ message: "Failed to get location analysis" });
    }
  });

  // 6. Análise Temporal - Tendências e padrões ao longo do tempo
  app.get("/api/customers/:customerId/reports/temporal", async (req, res) => {
    try {
      const { customerId } = req.params;
      const period = req.query.period as string || '30';
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const temporalAnalysis = await storage.getTemporalAnalysis(customerId, period, module);
      res.json(temporalAnalysis);
    } catch (error) {
      res.status(500).json({ message: "Failed to get temporal analysis" });
    }
  });

  app.get("/api/customers/:customerId/reports/assets", async (req, res) => {
    try {
      const { customerId } = req.params;
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const assetReport = await storage.getAssetReport(customerId, module);
      res.json(assetReport);
    } catch (error) {
      res.status(500).json({ message: "Failed to get asset report" });
    }
  });

  app.get("/api/sites/:siteId/zones", async (req, res) => {
    try {
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const zones = await storage.getZonesBySite(req.params.siteId, module);
      res.json(zones);
    } catch (error) {
      res.status(500).json({ message: "Failed to get zones" });
    }
  });

  // Get zones for a customer (all zones or filtered by sites)
  app.get("/api/customers/:customerId/zones", async (req, res) => {
    try {
      const { customerId } = req.params;
      const { siteIds, module } = req.query;
      const moduleParam = module as 'clean' | 'maintenance' | undefined;
      
      // Get all customer sites first
      const customerSites = await storage.getSitesByCustomer(customerId, moduleParam);
      
      // If no siteIds provided, return zones from ALL customer sites
      if (!siteIds) {
        const allZones = [];
        for (const site of customerSites) {
          const zones = await storage.getZonesBySite(site.id, moduleParam);
          allZones.push(...zones);
        }
        return res.json(allZones);
      }
      
      // If siteIds provided, validate and return zones from specified sites only
      const siteIdArray = typeof siteIds === 'string' ? siteIds.split(',') : [];
      const validSiteIds = new Set(customerSites.map(site => site.id));
      
      const invalidSites = siteIdArray.filter(siteId => !validSiteIds.has(siteId.trim()));
      if (invalidSites.length > 0) {
        return res.status(403).json({ 
          message: "One or more sites do not belong to this customer",
          invalidSites 
        });
      }
      
      const allZones = [];
      for (const siteId of siteIdArray) {
        const zones = await storage.getZonesBySite(siteId.trim(), moduleParam);
        allZones.push(...zones);
      }
      
      res.json(allZones);
    } catch (error) {
      res.status(500).json({ message: "Failed to get zones" });
    }
  });

  // Get zones by multiple sites (DEPRECATED - use /api/customers/:customerId/zones instead)
  app.get("/api/zones", async (req, res) => {
    try {
      const { siteIds, module } = req.query;
      if (!siteIds) {
        return res.status(400).json({ message: "siteIds parameter is required" });
      }
      
      const siteIdArray = typeof siteIds === 'string' ? siteIds.split(',') : [];
      const moduleParam = module as 'clean' | 'maintenance' | undefined;
      const allZones = [];
      
      for (const siteId of siteIdArray) {
        const zones = await storage.getZonesBySite(siteId.trim(), moduleParam);
        allZones.push(...zones);
      }
      
      res.json(allZones);
    } catch (error) {
      res.status(500).json({ message: "Failed to get zones" });
    }
  });

  app.get("/api/zones/:id", async (req, res) => {
    try {
      const zone = await storage.getZone(req.params.id);
      if (!zone) {
        return res.status(404).json({ message: "Zone not found" });
      }
      res.json(zone);
    } catch (error) {
      res.status(500).json({ message: "Failed to get zone" });
    }
  });

  app.post("/api/zones", async (req, res) => {
    try {
      const zone = insertZoneSchema.parse({
        ...req.body,
        module: req.body.module || 'clean'
      });
      const newZone = await storage.createZone(zone);
      res.status(201).json(newZone);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      res.status(500).json({ message: "Failed to create zone" });
    }
  });

  app.put("/api/zones/:id", async (req, res) => {
    try {
      const zone = insertZoneSchema.partial().parse(req.body);
      const updatedZone = await storage.updateZone(req.params.id, zone);
      res.json(updatedZone);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      res.status(500).json({ message: "Failed to update zone" });
    }
  });

  app.patch("/api/zones/:id", async (req, res) => {
    try {
      const zone = insertZoneSchema.partial().parse(req.body);
      const updatedZone = await storage.updateZone(req.params.id, zone);
      res.json(updatedZone);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      res.status(500).json({ message: "Failed to update zone" });
    }
  });

  app.delete("/api/zones/:id", async (req, res) => {
    try {
      await storage.deleteZone(req.params.id);
      res.json({ message: "Zone deleted successfully" });
    } catch (error) {
      console.error("Error deleting zone:", error);
      res.status(500).json({ message: "Failed to delete zone" });
    }
  });

  // QR Code Points
  app.get("/api/zones/:zoneId/qr-points", async (req, res) => {
    try {
      const points = await storage.getQrCodePointsByZone(req.params.zoneId);
      res.json(points);
    } catch (error) {
      res.status(500).json({ message: "Failed to get QR code points" });
    }
  });

  // List all QR points (debug endpoint)  
  app.get("/api/qr-points", async (req, res) => {
    try {
      // Lista todos os QR points da empresa padrão
      const points = await storage.getQrCodePointsByCompany("company-opus-default");
      res.json(points || []);
    } catch (error) {
      console.error("Error getting QR points:", error);
      res.status(500).json({ message: "Failed to get QR points" });
    }
  });

  app.get("/api/qr-points/:id", async (req, res) => {
    try {
      const point = await storage.getQrCodePoint(req.params.id);
      if (!point) {
        return res.status(404).json({ message: "QR code point not found" });
      }
      res.json(point);
    } catch (error) {
      res.status(500).json({ message: "Failed to get QR code point" });
    }
  });

  app.get("/api/qr-points/code/:code", async (req, res) => {
    try {
      const point = await storage.getQrCodePointByCode(req.params.code);
      if (!point) {
        return res.status(404).json({ message: "QR code point not found" });
      }
      res.json(point);
    } catch (error) {
      res.status(500).json({ message: "Failed to get QR code point" });
    }
  });

  // QR Code Resolution - Returns all context in one call - REQUIRES AUTH
  app.get("/api/qr-scan/resolve", requireAuth, async (req, res) => {
    try {
      const code = req.query.code as string;
      const user = req.user!;
      
      if (!code) {
        return res.status(400).json({ message: "QR code parameter is required" });
      }

      const resolved = await storage.resolveQrCode(code);
      
      if (!resolved) {
        return res.status(404).json({ message: "QR code not found or inactive" });
      }

      // Verificar se o usuário tem acesso ao módulo do QR code
      const qrModule = resolved.qrPoint.module;
      const userModules = user.modules || [];
      
      if (!userModules.includes(qrModule)) {
        console.warn(`[QR ACCESS DENIED] User ${user.id} tentou acessar QR code do módulo ${qrModule} mas só tem acesso a: ${userModules.join(', ')}`);
        return res.status(403).json({ 
          error: 'Acesso negado',
          message: `Você não tem acesso ao módulo ${qrModule === 'clean' ? 'OPUS Clean' : 'OPUS Manutenção'}.`
        });
      }

      // Verificar se o usuário tem acesso ao cliente do QR code
      // Admin pode acessar qualquer cliente
      if (user.role !== 'admin' && user.customerId !== resolved.customer.id) {
        console.warn(`[QR ACCESS DENIED] User ${user.id} tentou acessar QR code do cliente ${resolved.customer.id} mas pertence ao cliente ${user.customerId}`);
        return res.status(403).json({ 
          error: 'Acesso negado',
          message: 'Você não tem permissão para acessar QR codes deste cliente.'
        });
      }

      // Disable caching for dynamic QR resolution
      res.set({
        'Cache-Control': 'no-store, no-cache, must-revalidate, max-age=0',
        'Pragma': 'no-cache',
        'Expires': '0'
      });
      
      res.json(resolved);
    } catch (error) {
      console.error("Error resolving QR code:", error);
      res.status(500).json({ message: "Failed to resolve QR code" });
    }
  });

  // QR Code Resolution - NEW correct endpoint format - REQUIRES AUTH
  app.get("/api/qrs/:code/resolve", requireAuth, async (req, res) => {
    try {
      const code = req.params.code;
      const user = req.user!;
      
      if (!code) {
        return res.status(400).json({ message: "QR code parameter is required" });
      }

      const resolved = await storage.resolveQrCode(code);
      
      if (!resolved) {
        return res.status(404).json({ message: "QR code not found or inactive" });
      }

      // Verificar se o usuário tem acesso ao módulo do QR code
      const qrModule = resolved.qrPoint.module;
      const userModules = user.modules || [];
      
      if (!userModules.includes(qrModule)) {
        console.warn(`[QR ACCESS DENIED] User ${user.id} tentou acessar QR code do módulo ${qrModule} mas só tem acesso a: ${userModules.join(', ')}`);
        return res.status(403).json({ 
          error: 'Acesso negado',
          message: `Você não tem acesso ao módulo ${qrModule === 'clean' ? 'OPUS Clean' : 'OPUS Manutenção'}.`
        });
      }

      // Verificar se o usuário tem acesso ao cliente do QR code
      // Admin pode acessar qualquer cliente
      if (user.role !== 'admin' && user.customerId !== resolved.customer.id) {
        console.warn(`[QR ACCESS DENIED] User ${user.id} tentou acessar QR code do cliente ${resolved.customer.id} mas pertence ao cliente ${user.customerId}`);
        return res.status(403).json({ 
          error: 'Acesso negado',
          message: 'Você não tem permissão para acessar QR codes deste cliente.'
        });
      }

      res.json(resolved);
    } catch (error) {
      console.error("Error resolving QR code:", error);
      res.status(500).json({ message: "Failed to resolve QR code" });
    }
  });

  app.post("/api/qr-points", async (req, res) => {
    try {
      const qrPoint = insertQrCodePointSchema.parse({
        ...req.body,
        module: req.body.module || 'clean'
      });
      // Generate unique code if not provided
      if (!qrPoint.code) {
        qrPoint.code = crypto.randomUUID();
      }
      const newPoint = await storage.createQrCodePoint(qrPoint);
      res.status(201).json(newPoint);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      res.status(500).json({ message: "Failed to create QR code point" });
    }
  });

  app.put("/api/qr-points/:id", async (req, res) => {
    try {
      const qrPoint = insertQrCodePointSchema.partial().parse(req.body);
      const updatedPoint = await storage.updateQrCodePoint(req.params.id, qrPoint);
      res.json(updatedPoint);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      res.status(500).json({ message: "Failed to update QR code point" });
    }
  });

  app.delete("/api/qr-points/:id", async (req, res) => {
    try {
      await storage.deleteQrCodePoint(req.params.id);
      res.json({ message: "QR code point deleted successfully" });
    } catch (error) {
      res.status(500).json({ message: "Failed to delete QR code point" });
    }
  });

  // Users - PROTEGIDO: Apenas admin e gestor_cliente podem gerenciar usuários
  app.get("/api/users", requireManageUsers, async (req, res) => {
    try {
      const users = await storage.getUsers();
      res.json(sanitizeUsers(users));
    } catch (error) {
      res.status(500).json({ message: "Failed to get users" });
    }
  });

  app.get("/api/companies/:companyId/users", requireManageUsers, async (req, res) => {
    try {
      const users = await storage.getUsersByCompany(req.params.companyId);
      res.json(sanitizeUsers(users));
    } catch (error) {
      res.status(500).json({ message: "Failed to get users" });
    }
  });

  app.get("/api/users/:id", requireAuth, async (req, res) => {
    try {
      const user = await storage.getUser(req.params.id);
      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }
      res.json(sanitizeUser(user));
    } catch (error) {
      res.status(500).json({ message: "Failed to get user" });
    }
  });

  app.post("/api/users", requireManageUsers, async (req, res) => {
    try {
      const { role: customRoleId, ...userData } = req.body;
      
      // Validar dados do usuário (sem o role que vem como customRoleId)
      const validatedData = insertUserSchema.omit({ role: true }).parse(userData);
      
      // VALIDAÇÃO DE MÓDULOS: Verificar se os módulos solicitados são compatíveis com o cliente
      if (validatedData.userType === 'customer_user' && validatedData.customerId) {
        const customer = await storage.getCustomer(validatedData.customerId);
        
        if (!customer) {
          return res.status(400).json({
            message: "Cliente não encontrado",
            details: "O cliente selecionado não existe no sistema."
          });
        }
        
        const customerModules = customer.modules || ['clean'];
        const requestedModules = validatedData.modules || ['clean'];
        
        // Verificar se todos os módulos solicitados estão disponíveis no cliente
        const invalidModules = requestedModules.filter(m => !customerModules.includes(m));
        
        if (invalidModules.length > 0) {
          return res.status(400).json({
            message: "Módulos incompatíveis",
            details: `Os módulos ${invalidModules.join(', ')} não estão disponíveis para o cliente "${customer.name}". Módulos disponíveis: ${customerModules.join(', ')}`
          });
        }
      }
      
      // Generate unique user ID
      const userId = `user-${validatedData.username}-${Date.now()}`;
      
      // Hash password if provided (for local auth users)
      if (validatedData.password && validatedData.authProvider === 'local') {
        validatedData.password = await bcrypt.hash(validatedData.password, 12);
      }
      
      // Criar usuário com role padrão "operador" (será sobrescrito pelas permissões do custom role)
      const newUser = await storage.createUser({
        ...validatedData,
        id: userId,
        role: 'operador', // Role padrão, as permissões virão do custom role
      } as any);

      // Se foi enviado um customRoleId, criar userRoleAssignment via storage
      if (customRoleId && customRoleId.startsWith('role-')) {
        await storage.createUserRoleAssignment({
          id: `ura-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
          userId: newUser.id,
          roleId: customRoleId,
          customerId: validatedData.customerId || null,
        });
      }
      
      res.status(201).json(sanitizeUser(newUser));
    } catch (error: any) {
      // Tratamento de erros do Zod (validação)
      if (error instanceof z.ZodError) {
        return res.status(400).json({ 
          message: "Dados inválidos",
          details: error.errors.map(e => `${e.path.join('.')}: ${e.message}`).join(', '),
          errors: error.errors 
        });
      }
      
      // Tratamento de erros do PostgreSQL
      if (error.code === '23505') {
        // Unique constraint violation
        if (error.constraint === 'users_email_unique') {
          return res.status(400).json({ 
            message: "Email já cadastrado",
            details: `O email "${error.detail?.match(/\(([^)]+)\)/)?.[1] || 'informado'}" já está sendo usado por outro usuário. Por favor, use um email diferente.`
          });
        }
        if (error.constraint === 'users_username_unique') {
          return res.status(400).json({ 
            message: "Nome de usuário já existe",
            details: `O nome de usuário "${error.detail?.match(/\(([^)]+)\)/)?.[1] || 'informado'}" já está em uso. Por favor, escolha outro nome de usuário.`
          });
        }
        // Outras violações de unique constraint
        return res.status(400).json({ 
          message: "Valor duplicado",
          details: "Um campo único já possui esse valor no sistema. Verifique os dados e tente novamente."
        });
      }
      
      if (error.code === '23503') {
        // Foreign key violation
        return res.status(400).json({ 
          message: "Referência inválida",
          details: "Um dos campos referencia um registro que não existe. Verifique cliente, empresa ou outros relacionamentos."
        });
      }
      
      if (error.code === '23502') {
        // Not null violation
        return res.status(400).json({ 
          message: "Campo obrigatório faltando",
          details: `O campo "${error.column || 'desconhecido'}" é obrigatório e não pode ser vazio.`
        });
      }
      
      // Erro genérico
      console.error("Error creating user:", error);
      res.status(500).json({ 
        message: "Erro ao criar usuário",
        details: process.env.NODE_ENV === 'development' ? error.message : "Ocorreu um erro inesperado. Tente novamente ou contate o suporte."
      });
    }
  });

  app.put("/api/users/:id", requireManageUsers, async (req, res) => {
    try {
      const user = insertUserSchema.partial().parse(req.body);
      
      // VALIDAÇÃO DE MÓDULOS: Verificar se os módulos solicitados são compatíveis com o cliente
      if (user.modules && user.customerId) {
        const existingUser = await storage.getUser(req.params.id);
        
        if (existingUser && existingUser.userType === 'customer_user') {
          const customer = await storage.getCustomer(user.customerId);
          
          if (!customer) {
            return res.status(400).json({
              message: "Cliente não encontrado",
              details: "O cliente selecionado não existe no sistema."
            });
          }
          
          const customerModules = customer.modules || ['clean'];
          const requestedModules = user.modules;
          
          // Verificar se todos os módulos solicitados estão disponíveis no cliente
          const invalidModules = requestedModules.filter(m => !customerModules.includes(m));
          
          if (invalidModules.length > 0) {
            return res.status(400).json({
              message: "Módulos incompatíveis",
              details: `Os módulos ${invalidModules.join(', ')} não estão disponíveis para o cliente "${customer.name}". Módulos disponíveis: ${customerModules.join(', ')}`
            });
          }
        }
      }
      
      const updatedUser = await storage.updateUser(req.params.id, user);
      res.json(sanitizeUser(updatedUser));
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      res.status(500).json({ message: "Failed to update user" });
    }
  });

  app.patch("/api/users/:id", requireManageUsers, async (req, res) => {
    try {
      const user = insertUserSchema.partial().parse(req.body);
      
      // VALIDAÇÃO DE MÓDULOS: Verificar se os módulos solicitados são compatíveis com o cliente
      if (user.modules && user.customerId) {
        const existingUser = await storage.getUser(req.params.id);
        
        if (existingUser && existingUser.userType === 'customer_user') {
          const customer = await storage.getCustomer(user.customerId);
          
          if (!customer) {
            return res.status(400).json({
              message: "Cliente não encontrado",
              details: "O cliente selecionado não existe no sistema."
            });
          }
          
          const customerModules = customer.modules || ['clean'];
          const requestedModules = user.modules;
          
          // Verificar se todos os módulos solicitados estão disponíveis no cliente
          const invalidModules = requestedModules.filter(m => !customerModules.includes(m));
          
          if (invalidModules.length > 0) {
            return res.status(400).json({
              message: "Módulos incompatíveis",
              details: `Os módulos ${invalidModules.join(', ')} não estão disponíveis para o cliente "${customer.name}". Módulos disponíveis: ${customerModules.join(', ')}`
            });
          }
        }
      }
      
      const updatedUser = await storage.updateUser(req.params.id, user);
      res.json(sanitizeUser(updatedUser));
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      res.status(500).json({ message: "Failed to update user" });
    }
  });

  app.delete("/api/users/:id", requireManageUsers, async (req, res) => {
    try {
      await storage.deleteUser(req.params.id);
      res.json({ message: "User deleted successfully" });
    } catch (error) {
      console.error("Error deleting user:", error);
      res.status(500).json({ message: "Failed to delete user" });
    }
  });

  // Services
  app.get("/api/customers/:customerId/services", async (req, res) => {
    try {
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const services = await storage.getServicesByCustomer(req.params.customerId, module);
      res.json(services);
    } catch (error) {
      res.status(500).json({ message: "Failed to get services" });
    }
  });

  app.get("/api/services/:id", async (req, res) => {
    try {
      const service = await storage.getService(req.params.id);
      if (!service) {
        return res.status(404).json({ message: "Service not found" });
      }
      res.json(service);
    } catch (error) {
      res.status(500).json({ message: "Failed to get service" });
    }
  });

  app.post("/api/services", async (req, res) => {
    try {
      const dataWithModule = {
        ...req.body,
        module: req.body.module || 'clean'
      };
      console.log("Creating service with data:", dataWithModule);
      const service = insertServiceSchema.parse(dataWithModule);
      console.log("Validated service:", service);
      const newService = await storage.createService(service);
      res.status(201).json(newService);
    } catch (error) {
      if (error instanceof z.ZodError) {
        console.error("Service validation error:", error.errors);
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error creating service:", error);
      res.status(500).json({ message: "Failed to create service" });
    }
  });

  app.put("/api/services/:id", async (req, res) => {
    try {
      const service = insertServiceSchema.partial().parse(req.body);
      const updatedService = await storage.updateService(req.params.id, service);
      res.json(updatedService);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      res.status(500).json({ message: "Failed to update service" });
    }
  });

  app.delete("/api/services/:id", async (req, res) => {
    try {
      await storage.deleteService(req.params.id);
      res.json({ message: "Service deleted successfully" });
    } catch (error) {
      res.status(500).json({ message: "Failed to delete service" });
    }
  });

  // Checklist Templates
  app.get("/api/companies/:companyId/checklist-templates", async (req, res) => {
    try {
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const templates = await storage.getChecklistTemplatesByCompany(req.params.companyId, module);
      res.json(templates);
    } catch (error) {
      console.error("Error getting checklist templates:", error);
      res.status(500).json({ message: "Failed to get checklist templates" });
    }
  });

  // Create checklist template
  app.post("/api/companies/:companyId/checklist-templates", async (req, res) => {
    try {
      const template = insertChecklistTemplateSchema.parse({
        ...req.body,
        companyId: req.params.companyId
      });
      const newTemplate = await storage.createChecklistTemplate(template);
      res.status(201).json(newTemplate);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error creating checklist template:", error);
      res.status(500).json({ message: "Failed to create checklist template" });
    }
  });

  // Update checklist template
  app.put("/api/companies/:companyId/checklist-templates/:id", async (req, res) => {
    try {
      const template = insertChecklistTemplateSchema.partial().parse(req.body);
      const updatedTemplate = await storage.updateChecklistTemplate(req.params.id, template);
      res.json(updatedTemplate);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error updating checklist template:", error);
      res.status(500).json({ message: "Failed to update checklist template" });
    }
  });

  // Delete checklist template
  app.delete("/api/companies/:companyId/checklist-templates/:id", async (req, res) => {
    try {
      await storage.deleteChecklistTemplate(req.params.id);
      res.json({ message: "Checklist template deleted successfully" });
    } catch (error) {
      console.error("Error deleting checklist template:", error);
      res.status(500).json({ message: "Failed to delete checklist template" });
    }
  });

  // Get checklist template for a specific service
  app.get("/api/services/:serviceId/checklist", async (req, res) => {
    try {
      const checklist = await storage.getChecklistTemplateByServiceId(req.params.serviceId);
      if (!checklist) {
        return res.status(404).json({ message: "No checklist found for this service" });
      }
      res.json(checklist);
    } catch (error) {
      console.error("Error getting checklist for service:", error);
      res.status(500).json({ message: "Failed to get service checklist" });
    }
  });

  // Services by Zone
  app.get("/api/customers/:customerId/zones/:zoneId/services", async (req, res) => {
    try {
      const services = await storage.getServicesByZone(req.params.customerId, req.params.zoneId);
      res.json(services);
    } catch (error) {
      res.status(500).json({ message: "Failed to get services for zone" });
    }
  });

  // Service Types
  app.get("/api/customers/:customerId/service-types", async (req, res) => {
    try {
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const serviceTypes = await storage.getServiceTypesByCustomer(req.params.customerId, module);
      res.json(serviceTypes);
    } catch (error) {
      res.status(500).json({ message: "Failed to get service types" });
    }
  });

  app.post("/api/customers/:customerId/service-types", async (req, res) => {
    try {
      // Buscar customer para obter companyId
      const customer = await storage.getCustomer(req.params.customerId);
      if (!customer) {
        return res.status(404).json({ message: "Customer not found" });
      }

      const companyId = customer.companyId;
      console.log("Creating service type with data:", req.body, "customerId:", req.params.customerId, "companyId:", companyId);
      
      // Generate code from name if not provided
      const code = req.body.code || req.body.name.toUpperCase().replace(/\s+/g, '_').replace(/[^A-Z0-9_]/g, '');
      
      const dataToValidate = {
        ...req.body,
        code,
        companyId,
        customerId: req.params.customerId,
        module: req.body.module || 'clean'
      };
      
      console.log("Data to validate:", dataToValidate);
      
      const serviceType = insertServiceTypeSchema.parse(dataToValidate);
      const newServiceType = await storage.createServiceType(serviceType);
      res.status(201).json(newServiceType);
    } catch (error) {
      if (error instanceof z.ZodError) {
        console.error("Validation error creating service type:", error.errors);
        return res.status(400).json({ message: "Dados inválidos", errors: error.errors });
      }
      console.error("Error creating service type:", error);
      res.status(500).json({ message: "Erro ao criar tipo de serviço" });
    }
  });

  app.delete("/api/customers/:customerId/service-types/:id", async (req, res) => {
    try {
      await storage.deleteServiceType(req.params.id);
      res.json({ message: "Service type deleted successfully" });
    } catch (error: any) {
      console.error("Error deleting service type:", error);
      
      // Verificar se é o erro de atividades concluídas (a mensagem já vem formatada com os números das OSs)
      if (error.message?.includes('OSs concluídas vinculadas')) {
        return res.status(400).json({ 
          message: error.message
        });
      }
      
      // Check if it's a foreign key constraint error
      if (error.code === '23503') {
        return res.status(400).json({ 
          message: "Não é possível excluir este tipo de serviço porque existem vínculos com outros registros." 
        });
      }
      
      res.status(500).json({ message: "Falha ao excluir serviço" });
    }
  });

  app.put("/api/service-types/:id", async (req, res) => {
    try {
      const serviceType = insertServiceTypeSchema.partial().parse(req.body);
      const updatedServiceType = await storage.updateServiceType(req.params.id, serviceType);
      res.json(updatedServiceType);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      res.status(500).json({ message: "Failed to update service type" });
    }
  });

  app.delete("/api/service-types/:id", async (req, res) => {
    try {
      await storage.deleteServiceType(req.params.id);
      res.json({ message: "Service type deleted successfully" });
    } catch (error) {
      res.status(500).json({ message: "Failed to delete service type" });
    }
  });

  // CATEGORIAS - TODAS AS ROTAS COMENTADAS (MANTER PARA REFERÊNCIA FUTURA)
  /* app.get("/api/customers/:customerId/service-categories", async (req, res) => {
    try {
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const serviceCategories = await storage.getServiceCategoriesByCustomer(req.params.customerId, module);
      res.json(serviceCategories);
    } catch (error) {
      res.status(500).json({ message: "Failed to get service categories" });
    }
  });

  app.delete("/api/customers/:customerId/service-categories/:id", async (req, res) => {
    try {
      await storage.deleteServiceCategory(req.params.id);
      res.json({ message: "Service category deleted successfully" });
    } catch (error) {
      console.error("Error deleting service category:", error);
      res.status(500).json({ message: "Failed to delete service category" });
    }
  });

  app.get("/api/service-types/:typeId/categories", async (req, res) => {
    try {
      const serviceCategories = await storage.getServiceCategoriesByType(req.params.typeId);
      res.json(serviceCategories);
    } catch (error) {
      res.status(500).json({ message: "Failed to get service categories by type" });
    }
  });

  app.post("/api/customers/:customerId/service-categories", async (req, res) => {
    try {
      // Generate code from name if not provided
      const code = req.body.code || req.body.name.toUpperCase().replace(/\s+/g, '_').replace(/[^A-Z0-9_]/g, '');
      
      const serviceCategory = insertServiceCategorySchema.parse({
        ...req.body,
        code,
        customerId: req.params.customerId
      });
      const newServiceCategory = await storage.createServiceCategory(serviceCategory);
      res.status(201).json(newServiceCategory);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      res.status(500).json({ message: "Failed to create service category" });
    }
  });

  app.put("/api/service-categories/:id", async (req, res) => {
    try {
      const serviceCategory = insertServiceCategorySchema.partial().parse(req.body);
      const updatedServiceCategory = await storage.updateServiceCategory(req.params.id, serviceCategory);
      res.json(updatedServiceCategory);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      res.status(500).json({ message: "Failed to update service category" });
    }
  });

  app.delete("/api/service-categories/:id", async (req, res) => {
    try {
      await storage.deleteServiceCategory(req.params.id);
      res.json({ message: "Service category deleted successfully" });
    } catch (error) {
      res.status(500).json({ message: "Failed to delete service category" });
    }
  }); */

  // Work Orders
  app.get("/api/companies/:companyId/work-orders", async (req, res) => {
    try {
      const { zoneId, assignedTo } = req.query;
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      let workOrders = await storage.getWorkOrdersByCompany(req.params.companyId, module);
      
      // Filter by zone if provided
      if (zoneId) {
        workOrders = workOrders.filter(wo => wo.zoneId === zoneId);
      }
      
      // Filter by assignedTo if provided (include unassigned work orders and paused ones)
      if (assignedTo) {
        workOrders = workOrders.filter(wo => 
          wo.assignedUserId === assignedTo || 
          wo.assignedUserId === null || 
          wo.status === 'pausada' // Operadores podem ver O.S. pausadas por qualquer colaborador
        );
      }
      
      res.json(workOrders);
    } catch (error) {
      res.status(500).json({ message: "Failed to get work orders" });
    }
  });

  app.get("/api/users/:userId/work-orders", async (req, res) => {
    try {
      const workOrders = await storage.getWorkOrdersByUser(req.params.userId);
      res.json(workOrders);
    } catch (error) {
      res.status(500).json({ message: "Failed to get work orders" });
    }
  });

  app.get("/api/work-orders/:id", async (req, res) => {
    try {
      const workOrder = await storage.getWorkOrder(req.params.id);
      if (!workOrder) {
        return res.status(404).json({ message: "Work order not found" });
      }
      res.json(workOrder);
    } catch (error) {
      res.status(500).json({ message: "Failed to get work order" });
    }
  });

  app.post("/api/work-orders", async (req, res) => {
    try {
      const dataWithModule = {
        ...req.body,
        module: req.body.module || 'clean'
      };
      
      const workOrder = insertWorkOrderSchema.parse(dataWithModule);
      const newWorkOrder = await storage.createWorkOrder(workOrder);
      
      // Send webhook notification if configured
      // TODO: Implement webhook sending logic
      
      res.status(201).json(newWorkOrder);
    } catch (error: any) {
      // Tratamento de erros do Zod (validação)
      if (error instanceof z.ZodError) {
        const fieldErrors = error.errors.map(e => {
          const field = e.path.join('.');
          const fieldNames: Record<string, string> = {
            'title': 'Título',
            'description': 'Descrição',
            'type': 'Tipo',
            'status': 'Status',
            'priority': 'Prioridade',
            'zoneId': 'Zona/Local',
            'serviceId': 'Serviço',
            'companyId': 'Empresa',
            'scheduledDate': 'Data agendada',
            'dueDate': 'Data de vencimento',
          };
          const friendlyField = fieldNames[field] || field;
          return `${friendlyField}: ${e.message}`;
        });
        
        return res.status(400).json({ 
          message: "Dados inválidos na ordem de serviço",
          details: fieldErrors.join('; '),
          errors: error.errors 
        });
      }
      
      // Tratamento de erros do PostgreSQL
      if (error.code === '23505') {
        return res.status(400).json({ 
          message: "Registro duplicado",
          details: "Já existe uma ordem de serviço com esses dados."
        });
      }
      
      if (error.code === '23503') {
        return res.status(400).json({ 
          message: "Referência inválida",
          details: "A zona, serviço ou usuário selecionado não existe. Por favor, verifique os dados e tente novamente."
        });
      }
      
      console.error('Erro ao criar ordem de serviço:', error);
      res.status(500).json({ 
        message: "Erro ao criar ordem de serviço",
        details: "Ocorreu um erro inesperado. Por favor, tente novamente."
      });
    }
  });

  app.put("/api/work-orders/:id", requireAuth, async (req, res) => {
    try {
      const workOrder = insertWorkOrderSchema.partial().parse(req.body);
      
      // Se está sendo cancelada, adicionar timestamp e usuário
      if (workOrder.status === 'cancelada') {
        workOrder.cancelledAt = new Date();
        workOrder.cancelledBy = req.user?.id;
      }
      
      // 🔥 ATUALIZADO: Adicionar colaborador ao array de responsáveis em QUALQUER alteração
      if (req.user?.id) {
        const currentWO = await storage.getWorkOrder(req.params.id);
        if (currentWO) {
          // Pegar array atual de responsáveis (ou inicializar vazio)
          const currentAssignedIds = currentWO.assignedUserIds || [];
          
          // Adicionar usuário atual se não estiver na lista (evitar duplicatas)
          if (!currentAssignedIds.includes(req.user.id)) {
            workOrder.assignedUserIds = [...currentAssignedIds, req.user.id];
            console.log(`[WO UPDATE] Adicionando colaborador ${req.user.id} ao array. Array atual:`, currentAssignedIds, '→ Novo array:', workOrder.assignedUserIds);
          }
          
          // Também atualizar assignedUserId para última pessoa que editou
          workOrder.assignedUserId = req.user.id;
        }
      }
      
      const updatedWorkOrder = await storage.updateWorkOrder(req.params.id, workOrder);
      
      // Send webhook notification if configured
      // TODO: Implement webhook sending logic
      
      res.json(updatedWorkOrder);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      res.status(500).json({ message: "Failed to update work order" });
    }
  });

  app.patch("/api/work-orders/:id", requireAuth, async (req, res) => {
    try {
      const workOrder = insertWorkOrderSchema.partial().parse(req.body);
      
      // Se está sendo cancelada, adicionar timestamp e usuário
      if (workOrder.status === 'cancelada') {
        workOrder.cancelledAt = new Date();
        workOrder.cancelledBy = req.user?.id;
      }
      
      // 🔥 ATUALIZADO: Adicionar colaborador ao array de responsáveis em QUALQUER alteração
      if (req.user?.id) {
        const currentWO = await storage.getWorkOrder(req.params.id);
        if (currentWO) {
          // Pegar array atual de responsáveis (ou inicializar vazio)
          const currentAssignedIds = currentWO.assignedUserIds || [];
          
          // Adicionar usuário atual se não estiver na lista (evitar duplicatas)
          if (!currentAssignedIds.includes(req.user.id)) {
            workOrder.assignedUserIds = [...currentAssignedIds, req.user.id];
            console.log(`[WO UPDATE] Adicionando colaborador ${req.user.id} ao array. Array atual:`, currentAssignedIds, '→ Novo array:', workOrder.assignedUserIds);
          }
          
          // Também atualizar assignedUserId para última pessoa que editou
          workOrder.assignedUserId = req.user.id;
        }
      }
      
      const updatedWorkOrder = await storage.updateWorkOrder(req.params.id, workOrder);
      
      // Send webhook notification if configured
      // TODO: Implement webhook sending logic
      
      res.json(updatedWorkOrder);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      res.status(500).json({ message: "Failed to update work order" });
    }
  });

  app.delete("/api/work-orders/:id", requireAdmin, async (req, res) => {
    try {
      await storage.deleteWorkOrder(req.params.id);
      res.json({ message: "Work order deleted successfully" });
    } catch (error) {
      res.status(500).json({ message: "Failed to delete work order" });
    }
  });

  // Clear all work orders (for testing/reset)
  app.delete("/api/work-orders/clear-all", requireAdmin, async (req, res) => {
    try {
      await storage.clearAllWorkOrders();
      res.json({ message: "All work orders cleared successfully" });
    } catch (error) {
      res.status(500).json({ message: "Failed to clear work orders" });
    }
  });

  // Work Order Comments
  app.get("/api/work-orders/:workOrderId/comments", async (req, res) => {
    try {
      const comments = await storage.getWorkOrderComments(req.params.workOrderId);
      res.json(comments);
    } catch (error) {
      res.status(500).json({ message: "Failed to get comments" });
    }
  });

  // Work Order Execution Time - Calcula tempo real de execução (pausas descontadas)
  app.get("/api/work-orders/:workOrderId/execution-time", async (req, res) => {
    try {
      const workOrder = await storage.getWorkOrder(req.params.workOrderId);
      if (!workOrder) {
        return res.status(404).json({ message: "Work order not found" });
      }

      if (!workOrder.startedAt) {
        return res.json({ 
          milliseconds: 0, 
          formatted: "Não iniciada",
          periods: []
        });
      }

      const comments = await storage.getWorkOrderComments(req.params.workOrderId);
      const executionPeriods: { start: Date; end: Date | null }[] = [];
      let currentPeriodStart: Date | null = new Date(workOrder.startedAt);

      // Processar comentários em ordem cronológica
      for (const comment of comments) {
        const text = comment.comment || "";
        const timestamp = new Date(comment.createdAt as Date);

        // Detectar PAUSA - finaliza período atual
        if ((text.includes("pausou a OS") || text.includes("pausou o OS")) && currentPeriodStart) {
          executionPeriods.push({
            start: currentPeriodStart,
            end: timestamp
          });
          currentPeriodStart = null;
        }

        // Detectar RETOMADA ou INÍCIO - inicia novo período
        if ((text.includes("iniciou a execução") || text.includes("retomou a execução")) && !currentPeriodStart) {
          currentPeriodStart = timestamp;
        }
      }

      // Se ainda está em execução
      if (currentPeriodStart && workOrder.status === 'em_execucao') {
        executionPeriods.push({
          start: currentPeriodStart,
          end: null // null indica "em execução agora"
        });
      }

      // Se foi concluída, finaliza o último período
      if (currentPeriodStart && workOrder.status === 'concluida' && workOrder.completedAt) {
        executionPeriods.push({
          start: currentPeriodStart,
          end: new Date(workOrder.completedAt)
        });
      }

      // Calcular tempo total
      let totalMs = 0;
      const now = new Date();
      
      for (const period of executionPeriods) {
        const endTime = period.end || now;
        const duration = endTime.getTime() - period.start.getTime();
        totalMs += duration;
      }

      // Formatar tempo
      const hours = Math.floor(totalMs / (1000 * 60 * 60));
      const minutes = Math.floor((totalMs % (1000 * 60 * 60)) / (1000 * 60));
      const seconds = Math.floor((totalMs % (1000 * 60)) / 1000);

      let formatted = "";
      if (hours > 0) {
        formatted = `${hours}h ${minutes}min`;
      } else if (minutes > 0) {
        formatted = `${minutes}min ${seconds}s`;
      } else {
        formatted = `${seconds}s`;
      }

      res.json({
        milliseconds: totalMs,
        formatted,
        periods: executionPeriods.map(p => ({
          start: p.start.toISOString(),
          end: p.end ? p.end.toISOString() : null,
          durationMs: p.end ? p.end.getTime() - p.start.getTime() : now.getTime() - p.start.getTime()
        }))
      });
    } catch (error) {
      console.error("Error calculating execution time:", error);
      res.status(500).json({ message: "Failed to calculate execution time" });
    }
  });

  app.post("/api/work-orders/:workOrderId/comments", async (req, res) => {
    try {
      const comment = {
        id: crypto.randomUUID(),
        workOrderId: req.params.workOrderId,
        userId: req.body.userId,
        comment: req.body.comment,
        attachments: req.body.attachments,
        isReopenRequest: req.body.isReopenRequest || false,
      };
      const newComment = await storage.createWorkOrderComment(comment);
      res.status(201).json(newComment);
    } catch (error) {
      res.status(500).json({ message: "Failed to create comment" });
    }
  });

  app.delete("/api/work-orders/:workOrderId/comments/:commentId", async (req, res) => {
    try {
      await storage.deleteWorkOrderComment(req.params.commentId);
      res.json({ message: "Comment deleted successfully" });
    } catch (error) {
      res.status(500).json({ message: "Failed to delete comment" });
    }
  });

  // Work Order Rating (Customer Feedback)
  app.post("/api/work-orders/:workOrderId/rating", async (req, res) => {
    try {
      const { rating, comment, userId } = req.body;
      
      if (!rating || rating < 1 || rating > 10) {
        return res.status(400).json({ message: "Rating must be between 1 and 10" });
      }
      
      const updatedWorkOrder = await storage.updateWorkOrder(req.params.workOrderId, {
        customerRating: rating,
        customerRatingComment: comment || null,
        ratedAt: new Date(),
        ratedBy: userId,
      });
      
      res.json(updatedWorkOrder);
    } catch (error) {
      console.error("Error rating work order:", error);
      res.status(500).json({ message: "Failed to rate work order" });
    }
  });

  // Work Order Reopen
  app.post("/api/work-orders/:workOrderId/reopen", async (req, res) => {
    try {
      const { userId, reason, attachments } = req.body;
      const reopenedWorkOrder = await storage.reopenWorkOrder(
        req.params.workOrderId,
        userId,
        reason,
        attachments
      );
      res.json(reopenedWorkOrder);
    } catch (error) {
      res.status(500).json({ message: "Failed to reopen work order" });
    }
  });

  // Dashboard stats
  app.get("/api/companies/:companyId/dashboard-stats", async (req, res) => {
    try {
      const stats = await storage.getDashboardStats(req.params.companyId);
      res.json(stats);
    } catch (error) {
      res.status(500).json({ message: "Failed to get dashboard stats" });
    }
  });

  // Dashboard stats with filters
  app.get("/api/companies/:companyId/dashboard-stats/:period/:siteId", async (req, res) => {
    try {
      const { companyId, period, siteId } = req.params;
      const stats = await storage.getDashboardStats(companyId, period, siteId === 'todos' ? undefined : siteId);
      res.json(stats);
    } catch (error) {
      res.status(500).json({ message: "Failed to get dashboard stats" });
    }
  });

  // Performance analytics
  app.get("/api/companies/:companyId/analytics", async (req, res) => {
    try {
      const period = req.query.period as string || '7d';
      const analytics = await storage.getPerformanceAnalytics(req.params.companyId, period);
      res.json(analytics);
    } catch (error) {
      res.status(500).json({ message: "Failed to get performance analytics" });
    }
  });

  // Reports metrics endpoint
  app.get("/api/companies/:companyId/reports/metrics", async (req, res) => {
    try {
      const { companyId } = req.params;
      const period = req.query.period as string || '30';
      const metrics = await storage.getReportsMetrics(companyId, period);
      res.json(metrics);
    } catch (error) {
      res.status(500).json({ message: "Failed to get reports metrics" });
    }
  });

  // Work orders status distribution
  app.get("/api/companies/:companyId/reports/work-orders-status", async (req, res) => {
    try {
      const { companyId } = req.params;
      const period = req.query.period as string || '30';
      const statusData = await storage.getWorkOrdersStatusDistribution(companyId, period);
      res.json(statusData);
    } catch (error) {
      res.status(500).json({ message: "Failed to get work orders status distribution" });
    }
  });

  // SLA performance breakdown
  app.get("/api/companies/:companyId/reports/sla-performance", async (req, res) => {
    try {
      const { companyId } = req.params;
      const period = req.query.period as string || '30';
      const slaData = await storage.getSLAPerformanceBreakdown(companyId, period);
      res.json(slaData);
    } catch (error) {
      res.status(500).json({ message: "Failed to get SLA performance breakdown" });
    }
  });

  // Performance analytics with filters
  app.get("/api/companies/:companyId/analytics/:period/:siteId", async (req, res) => {
    try {
      const { companyId, period, siteId } = req.params;
      const analytics = await storage.getPerformanceAnalytics(companyId, period, siteId === 'todos' ? undefined : siteId);
      res.json(analytics);
    } catch (error) {
      res.status(500).json({ message: "Failed to get performance analytics" });
    }
  });

  // QR Code scanning endpoints
  app.get("/api/qr-execution/:code", async (req, res) => {
    try {
      const point = await storage.getQrCodePointByCode(req.params.code);
      if (!point || point.type !== 'execucao') {
        return res.status(404).json({ message: "QR code not found or invalid type" });
      }
      
      // TODO: Check for scheduled activities at this time/location
      // TODO: Return appropriate work order or option to create corrective one
      
      res.json({ point, hasScheduledActivity: false });
    } catch (error) {
      res.status(500).json({ message: "Failed to process QR scan" });
    }
  });

  app.get("/api/qr-public/:code", async (req, res) => {
    try {
      const point = await storage.getQrCodePointByCode(req.params.code);
      if (!point || point.type !== 'atendimento') {
        return res.status(404).json({ message: "QR code not found or invalid type" });
      }
      
      res.json({ point });
    } catch (error) {
      res.status(500).json({ message: "Failed to process QR scan" });
    }
  });

  app.post("/api/qr-public/:code/service-request", async (req, res) => {
    try {
      const point = await storage.getQrCodePointByCode(req.params.code);
      if (!point || point.type !== 'atendimento') {
        return res.status(404).json({ message: "QR code not found or invalid type" });
      }

      const { description, photo, requesterName, requesterContact } = req.body;
      
      // Create IP hash for spam control
      const clientIp = req.ip || req.connection.remoteAddress || 'unknown';
      const ipHash = crypto.createHash('sha256').update(clientIp).digest('hex');
      
      // Check for recent requests from this IP for spam control
      const recentRequests = await storage.checkRecentPublicRequests(ipHash, point.id, 24);
      if (recentRequests >= 5) {
        return res.status(429).json({ 
          message: "Muitas solicitações. Tente novamente em algumas horas.",
          code: "TOO_MANY_REQUESTS" 
        });
      }
      
      // Get zone and company info
      if (!point.zoneId) {
        return res.status(400).json({ message: "QR code point has no zone associated" });
      }
      const zone = await storage.getZone(point.zoneId);
      if (!zone) {
        return res.status(404).json({ message: "Zone not found" });
      }

      const site = await storage.getSite(zone.siteId);
      if (!site) {
        return res.status(404).json({ message: "Site not found" });
      }

      // Create corrective work order
      const workOrder = await storage.createWorkOrder({
        companyId: site.companyId,
        zoneId: zone.id,
        qrCodePointId: point.id,
        requesterName,
        requesterContact,
        type: 'corretiva_publica',
        priority: 'media',
        title: `Solicitação de Atendimento - ${zone.name}`,
        description: description || 'Solicitação via QR Code público',
        origin: 'QR Atendimento',
        attachments: photo ? [photo] : undefined,
        scheduledDate: null,
        dueDate: null,
        scheduledStartAt: null,
        scheduledEndAt: null,
        startedAt: null,
        completedAt: null
      });

      // Log the public request for spam control
      await storage.createPublicRequestLog({
        id: crypto.randomUUID(),
        ipHash,
        qrCodePointId: point.id,
        userAgent: req.get('User-Agent') || 'unknown',
        requestData: { workOrderId: workOrder.id }
      });

      // TODO: Send webhook notification for WhatsApp integration
      
      res.status(201).json({ 
        message: "Solicitação criada com sucesso",
        workOrderNumber: workOrder.number 
      });
    } catch (error) {
      res.status(500).json({ message: "Failed to create service request" });
    }
  });

  // Bathroom counter endpoints
  app.post("/api/zones/:zoneId/bathroom-counter/increment", async (req, res) => {
    try {
      const counter = await storage.incrementBathroomCounter(req.params.zoneId);
      res.json(counter);
    } catch (error) {
      res.status(500).json({ message: "Failed to increment bathroom counter" });
    }
  });

  app.get("/api/zones/:zoneId/bathroom-counter", async (req, res) => {
    try {
      const counter = await storage.getBathroomCounterByZone(req.params.zoneId);
      if (!counter) {
        return res.status(404).json({ message: "Bathroom counter not found" });
      }
      res.json(counter);
    } catch (error) {
      res.status(500).json({ message: "Failed to get bathroom counter" });
    }
  });

  app.post("/api/bathroom-counters", async (req, res) => {
    try {
      const counter = insertBathroomCounterSchema.parse(req.body);
      const newCounter = await storage.createBathroomCounter(counter);
      res.status(201).json(newCounter);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      res.status(500).json({ message: "Failed to create bathroom counter" });
    }
  });

  // Dashboard Goals Configuration
  app.get("/api/companies/:companyId/dashboard-goals", async (req, res) => {
    try {
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const goals = await storage.getDashboardGoals(req.params.companyId, module);
      res.json(goals);
    } catch (error) {
      res.status(500).json({ message: "Failed to get dashboard goals" });
    }
  });

  app.post("/api/companies/:companyId/dashboard-goals", async (req, res) => {
    try {
      const goal = insertDashboardGoalSchema.parse({
        ...req.body,
        companyId: req.params.companyId,
        module: req.body.module || 'clean'
      });
      const newGoal = await storage.createDashboardGoal(goal);
      res.status(201).json(newGoal);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      res.status(500).json({ message: "Failed to create dashboard goal" });
    }
  });

  app.put("/api/dashboard-goals/:id", async (req, res) => {
    try {
      const goal = insertDashboardGoalSchema.partial().parse(req.body);
      const updatedGoal = await storage.updateDashboardGoal(req.params.id, goal);
      res.json(updatedGoal);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      res.status(500).json({ message: "Failed to update dashboard goal" });
    }
  });

  app.delete("/api/dashboard-goals/:id", async (req, res) => {
    try {
      await storage.deleteDashboardGoal(req.params.id);
      res.status(204).send();
    } catch (error) {
      res.status(500).json({ message: "Failed to delete dashboard goal" });
    }
  });

  // Customer dashboard goals (delegates to company goals)
  app.get("/api/customers/:customerId/dashboard-goals", async (req, res) => {
    try {
      const customer = await storage.getCustomer(req.params.customerId);
      if (!customer) {
        return res.status(404).json({ message: "Customer not found" });
      }
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const goals = await storage.getDashboardGoals(customer.companyId, module);
      res.json(goals);
    } catch (error) {
      res.status(500).json({ message: "Failed to get dashboard goals" });
    }
  });

  app.post("/api/customers/:customerId/dashboard-goals", async (req, res) => {
    try {
      console.log("Creating dashboard goal with data:", req.body, "customerId:", req.params.customerId);
      
      const customer = await storage.getCustomer(req.params.customerId);
      if (!customer) {
        return res.status(404).json({ message: "Customer not found" });
      }
      
      const dataToValidate = {
        ...req.body,
        companyId: customer.companyId,
        module: req.body.module || 'clean'
      };
      
      console.log("Dashboard goal data to validate:", dataToValidate);
      
      const goal = insertDashboardGoalSchema.parse(dataToValidate);
      const newGoal = await storage.createDashboardGoal(goal);
      res.status(201).json(newGoal);
    } catch (error) {
      if (error instanceof z.ZodError) {
        console.error("Validation error creating dashboard goal:", error.errors);
        return res.status(400).json({ message: "Dados inválidos", errors: error.errors });
      }
      console.error("Error creating dashboard goal:", error);
      res.status(500).json({ message: "Erro ao criar meta" });
    }
  });

  app.put("/api/customers/:customerId/dashboard-goals/:id", async (req, res) => {
    try {
      const goal = insertDashboardGoalSchema.partial().parse(req.body);
      const updatedGoal = await storage.updateDashboardGoal(req.params.id, goal);
      res.json(updatedGoal);
    } catch (error) {
      if (error instanceof z.ZodError) {
        console.error("Validation error updating dashboard goal:", error.errors);
        return res.status(400).json({ message: "Dados inválidos", errors: error.errors });
      }
      console.error("Error updating dashboard goal:", error);
      res.status(500).json({ message: "Erro ao atualizar meta" });
    }
  });

  app.delete("/api/customers/:customerId/dashboard-goals/:id", async (req, res) => {
    try {
      await storage.deleteDashboardGoal(req.params.id);
      res.json({ message: "Meta excluída com sucesso" });
    } catch (error) {
      console.error("Error deleting dashboard goal:", error);
      res.status(500).json({ message: "Erro ao excluir meta" });
    }
  });

  // Audit Logs routes - PROTEGIDO: Apenas admin pode acessar
  app.get("/api/companies/:companyId/audit-logs", requireAdmin, async (req, res) => {
    try {
      const { companyId } = req.params;
      const { limit } = req.query;
      const logs = await storage.getAuditLogsByCompany(companyId, limit ? parseInt(limit as string) : undefined);
      res.json(logs);
    } catch (error) {
      console.error("Error fetching audit logs:", error);
      res.status(500).json({ error: "Failed to fetch audit logs" });
    }
  });

  app.get("/api/audit-logs/:entityType/:entityId", requireAdmin, async (req, res) => {
    try {
      const { entityType, entityId } = req.params;
      const logs = await storage.getAuditLogsByEntity(entityType, entityId);
      res.json(logs);
    } catch (error) {
      console.error("Error fetching entity audit logs:", error);
      res.status(500).json({ error: "Failed to fetch entity audit logs" });
    }
  });

  // Heatmap for cleaning performance by zone
  app.get("/api/companies/:companyId/heatmap/:siteId", async (req, res) => {
    try {
      const { companyId, siteId } = req.params;
      const heatmapData = await storage.getCleaningHeatmapData(companyId, siteId);
      res.json(heatmapData);
    } catch (error) {
      console.error("Error fetching heatmap data:", error);
      res.status(500).json({ message: "Failed to get heatmap data" });
    }
  });

  // Customers endpoints
  app.get("/api/companies/:companyId/customers", async (req, res) => {
    try {
      const customers = await storage.getCustomersByCompany(req.params.companyId);
      res.json(customers);
    } catch (error) {
      console.error("Error fetching customers:", error);
      res.status(500).json({ message: "Failed to get customers" });
    }
  });

  app.get("/api/customers/:id", async (req, res) => {
    try {
      const customer = await storage.getCustomer(req.params.id);
      if (!customer) {
        return res.status(404).json({ message: "Customer not found" });
      }
      res.json(customer);
    } catch (error) {
      console.error("Error fetching customer:", error);
      res.status(500).json({ message: "Failed to get customer" });
    }
  });

  app.post("/api/companies/:companyId/customers", requireManageClients, async (req, res) => {
    try {
      // Generate subdomain from customer name if not provided
      let subdomain = req.body.subdomain;
      if (!subdomain && req.body.name) {
        subdomain = req.body.name
          .toLowerCase()
          .normalize('NFD')
          .replace(/[\u0300-\u036f]/g, '') // Remove accents
          .replace(/[^a-z0-9]+/g, '-') // Replace non-alphanumeric with hyphens
          .replace(/^-+|-+$/g, ''); // Remove leading/trailing hyphens
        
        // Check if subdomain already exists
        const existing = await db
          .select()
          .from(customers)
          .where(eq(customers.subdomain, subdomain))
          .limit(1);
        
        if (existing.length > 0) {
          // Append random suffix if exists
          subdomain = `${subdomain}-${Math.floor(Math.random() * 1000)}`;
        }
      }
      
      const customer = insertCustomerSchema.parse({
        ...req.body,
        companyId: req.params.companyId,
        subdomain
      });
      const newCustomer = await storage.createCustomer(customer);
      res.status(201).json(newCustomer);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error creating customer:", error);
      res.status(500).json({ message: "Failed to create customer" });
    }
  });

  app.put("/api/customers/:id", requireManageClients, async (req, res) => {
    try {
      const customer = insertCustomerSchema.partial().parse(req.body);
      const updatedCustomer = await storage.updateCustomer(req.params.id, customer);
      res.json(updatedCustomer);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error updating customer:", error);
      res.status(500).json({ message: "Failed to update customer" });
    }
  });

  app.delete("/api/customers/:id", requireManageClients, async (req, res) => {
    try {
      await storage.deleteCustomer(req.params.id);
      res.status(204).send();
    } catch (error) {
      console.error("Error deleting customer:", error);
      res.status(500).json({ message: "Failed to delete customer" });
    }
  });

  // Customer branding configuration
  app.put("/api/customers/:id/branding", requireManageClients, async (req, res) => {
    try {
      const { loginLogo, sidebarLogo, sidebarLogoCollapsed, homeLogo, favicon, moduleColors, subdomain } = req.body;
      
      const brandingUpdate: any = {};
      if (loginLogo !== undefined) brandingUpdate.loginLogo = loginLogo;
      if (sidebarLogo !== undefined) brandingUpdate.sidebarLogo = sidebarLogo;
      if (sidebarLogoCollapsed !== undefined) brandingUpdate.sidebarLogoCollapsed = sidebarLogoCollapsed;
      if (homeLogo !== undefined) brandingUpdate.homeLogo = homeLogo;
      if (favicon !== undefined) brandingUpdate.favicon = favicon;
      if (moduleColors !== undefined) brandingUpdate.moduleColors = moduleColors;
      
      // Normalize and validate subdomain if provided
      if (subdomain !== undefined) {
        // Reject empty strings
        if (subdomain === '') {
          return res.status(400).json({ message: 'Subdomínio não pode ser vazio' });
        }
        
        // Normalize subdomain: lowercase, remove accents, replace non-alphanumeric with hyphens
        const normalizedSubdomain = subdomain
          .toLowerCase()
          .normalize('NFD')
          .replace(/[\u0300-\u036f]/g, '')
          .replace(/[^a-z0-9]+/g, '-')
          .replace(/^-+|-+$/g, '');
        
        // Validate format
        if (!/^[a-z0-9-]+$/.test(normalizedSubdomain)) {
          return res.status(400).json({ message: 'Subdomínio inválido. Use apenas letras, números e hífens.' });
        }
        
        // Check uniqueness
        const existing = await db
          .select()
          .from(customers)
          .where(and(
            eq(customers.subdomain, normalizedSubdomain),
            ne(customers.id, req.params.id)
          ))
          .limit(1);
        
        if (existing.length > 0) {
          return res.status(400).json({ message: 'Subdomínio já está em uso' });
        }
        
        brandingUpdate.subdomain = normalizedSubdomain;
      }
      
      const updatedCustomer = await storage.updateCustomer(req.params.id, brandingUpdate);
      res.json(updatedCustomer);
    } catch (error) {
      console.error("Error updating customer branding:", error);
      res.status(500).json({ message: "Failed to update customer branding" });
    }
  });

  // Upload logo for customer branding
  app.post("/api/customers/:id/upload-logo", requireManageClients, async (req, res) => {
    try {
      const { logoType, imageData, fileName } = req.body;
      
      if (!logoType || !imageData || !fileName) {
        return res.status(400).json({ message: "logoType, imageData, and fileName are required" });
      }
      
      if (!['loginLogo', 'sidebarLogo', 'sidebarLogoCollapsed', 'homeLogo', 'favicon'].includes(logoType)) {
        return res.status(400).json({ message: "Invalid logoType. Must be one of: loginLogo, sidebarLogo, sidebarLogoCollapsed, homeLogo, favicon" });
      }
      
      // Import fs promises
      const fs = await import('fs/promises');
      const path = await import('path');
      
      // Create customer logos directory if it doesn't exist
      const customerLogosDir = path.join(process.cwd(), 'attached_assets', 'customer_logos');
      await fs.mkdir(customerLogosDir, { recursive: true });
      
      // Generate unique filename
      const ext = path.extname(fileName) || '.png';
      const uniqueFileName = `${req.params.id}_${logoType}_${Date.now()}${ext}`;
      const filePath = path.join(customerLogosDir, uniqueFileName);
      
      // Remove base64 prefix if present
      const base64Data = imageData.replace(/^data:image\/\w+;base64,/, '');
      
      // Write file
      await fs.writeFile(filePath, base64Data, 'base64');
      
      // Return relative path for storage
      const relativePath = `/attached_assets/customer_logos/${uniqueFileName}`;
      
      res.json({ 
        success: true, 
        path: relativePath,
        logoType 
      });
    } catch (error) {
      console.error("Error uploading customer logo:", error);
      res.status(500).json({ message: "Failed to upload logo" });
    }
  });

  // Public API - Get customer branding by subdomain (no auth required)
  app.get("/api/public/branding/:subdomain", async (req, res) => {
    try {
      const [customer] = await db
        .select({
          name: customers.name,
          subdomain: customers.subdomain,
          loginLogo: customers.loginLogo,
          sidebarLogo: customers.sidebarLogo,
          sidebarLogoCollapsed: customers.sidebarLogoCollapsed,
          homeLogo: customers.homeLogo,
          favicon: customers.favicon,
          moduleColors: customers.moduleColors
        })
        .from(customers)
        .where(eq(customers.subdomain, req.params.subdomain))
        .limit(1);
      
      if (!customer) {
        return res.status(404).json({ message: 'Cliente não encontrado' });
      }
      
      res.json(customer);
    } catch (error) {
      console.error('Error fetching branding:', error);
      res.status(500).json({ message: 'Erro ao buscar configurações' });
    }
  });

  // Public API - Get full customer data by subdomain (no auth required)
  app.get("/api/public/customer-by-subdomain/:subdomain", async (req, res) => {
    try {
      const [customer] = await db
        .select()
        .from(customers)
        .where(eq(customers.subdomain, req.params.subdomain))
        .limit(1);
      
      if (!customer) {
        return res.status(404).json({ message: 'Cliente não encontrado para este subdomínio' });
      }
      
      // Return complete branding data
      res.json({
        id: customer.id,
        name: customer.name,
        subdomain: customer.subdomain,
        loginLogo: customer.loginLogo,
        sidebarLogo: customer.sidebarLogo,
        sidebarLogoCollapsed: customer.sidebarLogoCollapsed,
        homeLogo: customer.homeLogo,
        favicon: customer.favicon,
        moduleColors: customer.moduleColors,
      });
    } catch (error) {
      console.error('Error fetching customer by subdomain:', error);
      res.status(500).json({ message: 'Erro ao buscar cliente' });
    }
  });

  // Authentication routes
  app.post("/api/auth/login", loginLimiter, async (req, res) => {
    try {
      const { username, password } = req.body;
      
      if (!username || !password) {
        return res.status(400).json({ message: "Username and password are required" });
      }

      // Find user by username OR email
      let user = await storage.getUserByUsername(username);
      if (!user) {
        user = await storage.getUserByEmail(username);
      }
      
      // Always hash even if user not found (prevent timing attacks)
      const dummyHash = '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqR.NvJ8Om';
      const hashToCompare = user?.password || dummyHash;
      const isValidPassword = await bcrypt.compare(password, hashToCompare);
      
      if (!user || !isValidPassword) {
        return res.status(401).json({ message: "Invalid credentials" });
      }

      // Check if user must use SSO
      if (user.authProvider !== 'local') {
        return res.status(400).json({ message: 'User must sign in with SSO' });
      }

      // Check if user is active
      if (!user.isActive) {
        return res.status(403).json({ message: 'Account is disabled' });
      }

      // Generate secure JWT token
      const token = jwt.sign(
        {
          userId: user.id,
          username: user.username,
          role: user.role,
          companyId: user.companyId,
          customerId: user.customerId
        },
        JWT_SECRET,
        { expiresIn: '24h' }
      );

      // Return user data without password
      res.json({
        user: sanitizeUser(user),
        token: token
      });
    } catch (error) {
      console.error("Login error:", error);
      res.status(500).json({ message: "Internal server error" });
    }
  });

  // Logout route
  app.post("/api/auth/logout", async (req, res) => {
    try {
      // In a real application, you might want to invalidate the token here
      // For now, we just return success since logout is handled client-side
      res.json({ message: "Logged out successfully" });
    } catch (error) {
      console.error("Logout error:", error);
      res.status(500).json({ message: "Internal server error" });
    }
  });

  // Get current authenticated user
  app.get("/api/auth/me", async (req, res) => {
    try {
      const authHeader = req.headers.authorization;
      if (!authHeader) {
        return res.status(404).json({ message: "Not authenticated" });
      }
      
      const token = authHeader.replace('Bearer ', '');
      
      // Try JWT first, fallback to old token format for backwards compatibility
      try {
        const decoded = jwt.verify(token, JWT_SECRET) as any;
        const user = await storage.getUser(decoded.userId);
        if (!user) {
          return res.status(404).json({ message: "User not found" });
        }
        return res.json({ user: sanitizeUser(user) });
      } catch (jwtError) {
        // Fallback: Parse old token format for backwards compatibility
        const parts = token.split('_');
        if (parts.length >= 2 && parts[0] === 'token') {
          const userId = parts[1];
          const user = await storage.getUser(userId);
          if (!user) {
            return res.status(404).json({ message: "User not found" });
          }
          return res.json({ user: sanitizeUser(user) });
        }
        return res.status(401).json({ message: "Invalid token" });
      }
    } catch (error) {
      console.error("Get current user error:", error);
      res.status(500).json({ message: "Internal server error" });
    }
  });

  // Get available modules for the authenticated user
  app.get("/api/auth/available-modules", async (req, res) => {
    try {
      const authHeader = req.headers.authorization;
      if (!authHeader) {
        return res.status(401).json({ message: "Not authenticated" });
      }
      
      const token = authHeader.replace('Bearer ', '');
      
      let user;
      try {
        const decoded = jwt.verify(token, JWT_SECRET) as any;
        user = await storage.getUser(decoded.userId);
      } catch (jwtError) {
        // Fallback for old token format
        const parts = token.split('_');
        if (parts.length >= 2 && parts[0] === 'token') {
          const userId = parts[1];
          user = await storage.getUser(userId);
        }
      }
      
      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }

      let availableModules: string[] = [];

      // Separate logic for OPUS users and customer users
      if (user.userType === 'customer_user') {
        // Customer users: get modules from their associated customer
        if (user.customerId) {
          const customer = await storage.getCustomer(user.customerId);
          if (customer) {
            availableModules = customer.modules || [];
          }
        }
      } else {
        // OPUS users: get modules from the user directly
        availableModules = user.modules || [];
      }
      
      res.json({ modules: availableModules });
    } catch (error) {
      console.error("Get available modules error:", error);
      res.status(500).json({ message: "Internal server error" });
    }
  });

  // Get user modules with default module (for mobile module restriction)
  // SECURED: Uses requireAuth middleware to ensure proper authentication
  app.get("/api/auth/user-modules", requireAuth, async (req, res) => {
    try {
      // User is already validated by requireAuth middleware
      const user = req.user;
      
      if (!user) {
        return res.status(401).json({ message: "Not authenticated" });
      }

      let modules: ('clean' | 'maintenance')[] = [];

      // 🔥 CORRIGIDO: SEMPRE pegar módulos do USUÁRIO, não do cliente
      // Isso garante que as permissões individuais sejam respeitadas
      const fullUser = await storage.getUser(user.id);
      if (fullUser) {
        modules = (fullUser.modules || ['clean']) as ('clean' | 'maintenance')[];
      }
      
      // SEGURANÇA: Garantir que sempre retorne pelo menos 1 módulo
      // Se modules estiver vazio, forçar 'clean' como fallback seguro
      if (modules.length === 0) {
        modules = ['clean'];
      }
      
      // Default to first available module
      const defaultModule = modules[0];
      
      res.json({ 
        modules,
        defaultModule 
      });
    } catch (error) {
      console.error("Get user modules error:", error);
      res.status(500).json({ message: "Internal server error" });
    }
  });

  // === ROLES MANAGEMENT ===
  
  // Listar todas as funções
  app.get("/api/roles", async (req, res) => {
    try {
      const roles = await storage.getCustomRoles();
      res.json(roles);
    } catch (error) {
      console.error("Error fetching roles:", error);
      res.status(500).json({ message: "Failed to fetch roles" });
    }
  });

  // Criar nova função
  app.post("/api/roles", async (req, res) => {
    try {
      const { permissions, ...roleData } = req.body;
      
      // Criar a função
      const role = await storage.createCustomRole(roleData);
      
      // Adicionar permissões
      if (permissions?.length) {
        await storage.setRolePermissions(role.id, permissions);
      }
      
      // Retornar função completa com permissões
      const fullRole = await storage.getCustomRoleById(role.id);
      res.status(201).json(fullRole);
    } catch (error) {
      console.error("Error creating role:", error);
      res.status(500).json({ message: "Failed to create role" });
    }
  });

  // Atualizar função
  app.patch("/api/roles/:id", async (req, res) => {
    try {
      const { permissions, ...roleData } = req.body;
      
      // Atualizar dados da função
      const role = await storage.updateCustomRole(req.params.id, roleData);
      
      // Atualizar permissões se fornecidas
      if (permissions) {
        await storage.setRolePermissions(req.params.id, permissions);
      }
      
      // Retornar função completa atualizada
      const fullRole = await storage.getCustomRoleById(req.params.id);
      res.json(fullRole);
    } catch (error) {
      console.error("Error updating role:", error);
      res.status(500).json({ message: "Failed to update role" });
    }
  });

  // Excluir função
  app.delete("/api/roles/:id", async (req, res) => {
    try {
      await storage.deleteCustomRole(req.params.id);
      res.status(204).end();
    } catch (error) {
      console.error("Error deleting role:", error);
      res.status(500).json({ message: "Failed to delete role" });
    }
  });

  // Buscar roles de um usuário específico
  app.get("/api/users/:userId/roles", async (req, res) => {
    try {
      const roles = await storage.getUserRoleAssignments(req.params.userId);
      res.json(roles);
    } catch (error) {
      console.error("Error fetching user roles:", error);
      res.status(500).json({ message: "Failed to fetch user roles" });
    }
  });

  // Atribuir role a um usuário (novo endpoint mais intuitivo)
  app.post("/api/users/:userId/roles", async (req, res) => {
    try {
      const assignmentData = {
        id: `ura-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
        userId: req.params.userId,
        roleId: req.body.roleId,
        customerId: req.body.customerId || null,
      };
      const assignment = await storage.createUserRoleAssignment(assignmentData);
      res.status(201).json(assignment);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error creating user role assignment:", error);
      res.status(500).json({ message: "Failed to create user role assignment" });
    }
  });

  // Atribuir role a um usuário (endpoint antigo mantido para compatibilidade)
  app.post("/api/user-role-assignments", async (req, res) => {
    try {
      const assignmentData = insertUserRoleAssignmentSchema.parse(req.body);
      const assignment = await storage.createUserRoleAssignment(assignmentData);
      res.status(201).json(assignment);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error creating user role assignment:", error);
      res.status(500).json({ message: "Failed to create user role assignment" });
    }
  });

  // Remover role de um usuário
  app.delete("/api/users/:userId/roles/:roleId", async (req, res) => {
    try {
      await storage.deleteUserRoleAssignment(req.params.userId, req.params.roleId);
      res.status(204).end();
    } catch (error) {
      console.error("Error deleting user role assignment:", error);
      res.status(500).json({ message: "Failed to delete user role assignment" });
    }
  });

  // === CLEANING ACTIVITIES MANAGEMENT ===
  
  // Get cleaning activities by company
  app.get("/api/companies/:companyId/cleaning-activities", async (req, res) => {
    try {
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const activities = await storage.getCleaningActivitiesByCompany(req.params.companyId, module);
      res.json(activities);
    } catch (error) {
      console.error("Error fetching cleaning activities:", error);
      res.status(500).json({ message: "Failed to get cleaning activities" });
    }
  });

  // Get single cleaning activity
  app.get("/api/cleaning-activities/:id", async (req, res) => {
    try {
      const activity = await storage.getCleaningActivity(req.params.id);
      if (!activity) {
        return res.status(404).json({ message: "Cleaning activity not found" });
      }
      res.json(activity);
    } catch (error) {
      console.error("Error fetching cleaning activity:", error);
      res.status(500).json({ message: "Failed to get cleaning activity" });
    }
  });

  // Create cleaning activity (SECURE - requires customerId in URL)
  app.post("/api/customers/:customerId/cleaning-activities", async (req, res) => {
    try {
      // Validate customer exists
      const customerSites = await storage.getSitesByCustomer(req.params.customerId);
      if (customerSites.length === 0) {
        return res.status(404).json({ message: "Customer not found" });
      }

      const companyId = customerSites[0].companyId;

      // Limpar campos que podem ter valores inválidos
      const cleanedData = { 
        ...req.body,
        customerId: req.params.customerId, // FORCE customerId from URL
        companyId, // Ensure companyId is set
        module: req.body.module || 'clean'
      };
      
      if (cleanedData.checklistTemplateId === "none" || cleanedData.checklistTemplateId === "") {
        cleanedData.checklistTemplateId = null;
      }
      
      // Converter strings vazias em null para campos de hora
      if (cleanedData.startTime === "") {
        cleanedData.startTime = null;
      }
      if (cleanedData.endTime === "") {
        cleanedData.endTime = null;
      }
      
      // Validar dados (schema omite o ID)
      const activityData = insertCleaningActivitySchema.parse(cleanedData);
      
      // Gerar ID único após validação
      const activityWithId = {
        ...activityData,
        id: `ca-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
      };
      
      const activity = await storage.createCleaningActivity(activityWithId as any);
      res.status(201).json(activity);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error creating cleaning activity:", error);
      res.status(500).json({ message: "Failed to create cleaning activity" });
    }
  });

  // Update cleaning activity
  app.put("/api/cleaning-activities/:id", async (req, res) => {
    try {
      const activityData = insertCleaningActivitySchema.partial().parse(req.body);
      const activity = await storage.updateCleaningActivity(req.params.id, activityData);
      res.json(activity);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error updating cleaning activity:", error);
      res.status(500).json({ message: "Failed to update cleaning activity" });
    }
  });

  // Delete cleaning activity
  app.delete("/api/cleaning-activities/:id", async (req, res) => {
    try {
      await storage.deleteCleaningActivity(req.params.id);
      res.json({ message: "Cleaning activity deleted successfully" });
    } catch (error) {
      console.error("Error deleting cleaning activity:", error);
      res.status(500).json({ message: "Failed to delete cleaning activity" });
    }
  });

  // === MAINTENANCE ACTIVITIES MANAGEMENT ===
  
  // Get maintenance activities by customer
  app.get("/api/customers/:customerId/maintenance-activities", async (req, res) => {
    try {
      const activities = await storage.getMaintenanceActivitiesByCustomer(req.params.customerId);
      res.json(activities);
    } catch (error) {
      console.error("Error fetching maintenance activities:", error);
      res.status(500).json({ message: "Failed to get maintenance activities" });
    }
  });

  // Get maintenance activities by company
  app.get("/api/companies/:companyId/maintenance-activities", async (req, res) => {
    try {
      const activities = await storage.getMaintenanceActivitiesByCompany(req.params.companyId);
      res.json(activities);
    } catch (error) {
      console.error("Error fetching maintenance activities:", error);
      res.status(500).json({ message: "Failed to get maintenance activities" });
    }
  });

  // Get single maintenance activity
  app.get("/api/maintenance-activities/:id", async (req, res) => {
    try {
      const activity = await storage.getMaintenanceActivity(req.params.id);
      if (!activity) {
        return res.status(404).json({ message: "Maintenance activity not found" });
      }
      res.json(activity);
    } catch (error) {
      console.error("Error fetching maintenance activity:", error);
      res.status(500).json({ message: "Failed to get maintenance activity" });
    }
  });

  // Create maintenance activity
  app.post("/api/maintenance-activities", async (req, res) => {
    try {
      console.log("[DEBUG] Request body:", JSON.stringify(req.body, null, 2));
      
      const cleanedData = { 
        ...req.body,
        module: 'maintenance',
        customerId: req.body.activeClientId || req.body.customerId // Map activeClientId to customerId
      };
      
      // Remove activeClientId if present (not part of schema)
      delete cleanedData.activeClientId;
      
      if (cleanedData.checklistTemplateId === "none" || cleanedData.checklistTemplateId === "") {
        cleanedData.checklistTemplateId = null;
      }
      
      if (cleanedData.assignedUserId === "none" || cleanedData.assignedUserId === "") {
        cleanedData.assignedUserId = null;
      }
      
      if (cleanedData.slaConfigId === "none" || cleanedData.slaConfigId === "") {
        cleanedData.slaConfigId = null;
      }
      
      if (cleanedData.startTime === "") {
        cleanedData.startTime = null;
      }
      if (cleanedData.endTime === "") {
        cleanedData.endTime = null;
      }
      
      console.log("[DEBUG] Cleaned data:", JSON.stringify(cleanedData, null, 2));
      
      const activityData = insertMaintenanceActivitySchema.parse(cleanedData);
      
      const activityWithId = {
        ...activityData,
        id: `ma-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
      };
      
      const activity = await storage.createMaintenanceActivity(activityWithId as any);
      
      // Generate work orders from start date until end of current month
      if (activity.isActive && activity.equipmentIds && activity.equipmentIds.length > 0 && activity.startDate) {
        const now = new Date();
        const startDate = new Date(activity.startDate + 'T00:00:00');
        const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59, 999);
        
        // Only generate if start date is in current month or past
        if (startDate <= endOfMonth) {
          try {
            await storage.generateMaintenanceWorkOrders(
              activity.companyId,
              startDate, // Use activity start date, not "now"
              endOfMonth
            );
            console.log(`[PLAN CREATED] Generated work orders from ${startDate.toISOString()} to ${endOfMonth.toISOString()} for activity ${activity.id}`);
          } catch (error) {
            console.error(`[PLAN CREATED] Failed to generate work orders:`, error);
            // Don't fail the request if work order generation fails
          }
        }
      }
      
      res.status(201).json(activity);
    } catch (error) {
      if (error instanceof z.ZodError) {
        console.error("[DEBUG] Zod validation errors:", JSON.stringify(error.errors, null, 2));
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error creating maintenance activity:", error);
      res.status(500).json({ message: "Failed to create maintenance activity" });
    }
  });

  // Update maintenance activity
  app.put("/api/maintenance-activities/:id", async (req, res) => {
    try {
      const activityData = insertMaintenanceActivitySchema.partial().parse(req.body);
      const activity = await storage.updateMaintenanceActivity(req.params.id, activityData);
      res.json(activity);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error updating maintenance activity:", error);
      res.status(500).json({ message: "Failed to update maintenance activity" });
    }
  });

  // Delete maintenance activity
  app.delete("/api/maintenance-activities/:id", async (req, res) => {
    try {
      await storage.deleteMaintenanceActivity(req.params.id);
      res.json({ message: "Maintenance activity deleted successfully" });
    } catch (error) {
      console.error("Error deleting maintenance activity:", error);
      res.status(500).json({ message: "Failed to delete maintenance activity" });
    }
  });

  // === SCHEDULER MANAGEMENT ===
  
  // Generate scheduled work orders from cleaning activities
  app.post("/api/scheduler/generate-work-orders", async (req, res) => {
    try {
      const { companyId, windowStart, windowEnd } = req.body;
      
      if (!companyId) {
        return res.status(400).json({ message: "Company ID is required" });
      }
      
      // Validar que windowStart e windowEnd foram fornecidos
      if (!windowStart || !windowEnd) {
        return res.status(400).json({ 
          message: "windowStart and windowEnd are required to prevent retroactive work order generation" 
        });
      }
      
      const startDate = new Date(windowStart);
      const endDate = new Date(windowEnd);
      
      // Validar que as datas são válidas
      if (isNaN(startDate.getTime()) || isNaN(endDate.getTime())) {
        return res.status(400).json({ message: "Invalid date format for windowStart or windowEnd" });
      }
      
      // Validar que windowEnd >= windowStart
      if (endDate < startDate) {
        return res.status(400).json({ message: "windowEnd must be greater than or equal to windowStart" });
      }
      
      console.log(`[SCHEDULER] Gerando OS para período: ${startDate.toISOString()} até ${endDate.toISOString()}`);
      
      const generatedOrders = await storage.generateScheduledWorkOrders(companyId, startDate, endDate);
      
      console.log(`[SCHEDULER] ✅ ${generatedOrders.length} OS geradas com sucesso`);
      
      res.json({
        message: `Generated ${generatedOrders.length} scheduled work orders`,
        generatedOrders: generatedOrders.length,
        workOrders: generatedOrders,
        period: {
          start: startDate,
          end: endDate
        }
      });
    } catch (error) {
      console.error("Error generating scheduled work orders:", error);
      res.status(500).json({ message: "Failed to generate scheduled work orders" });
    }
  });

  // Generate scheduled work orders from maintenance activities
  app.post("/api/scheduler/generate-maintenance-work-orders", async (req, res) => {
    try {
      const { companyId, windowStart, windowEnd } = req.body;
      
      if (!companyId) {
        return res.status(400).json({ message: "Company ID is required" });
      }
      
      // Default window: MÊS ATUAL (sistema regenera automaticamente no final de cada mês)
      const now = new Date();
      const startDate = windowStart ? new Date(windowStart) : new Date(now.getFullYear(), now.getMonth(), 1);
      // Gerar OSs apenas até o final do mês atual
      const endDate = windowEnd ? new Date(windowEnd) : new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59);
      
      console.log(`[SCHEDULER MAINTENANCE] Gerando OSs de manutenção para período: ${startDate.toISOString()} até ${endDate.toISOString()}`);
      
      const generatedOrders = await storage.generateMaintenanceWorkOrders(companyId, startDate, endDate);
      
      console.log(`[SCHEDULER MAINTENANCE] ✅ ${generatedOrders.length} OSs de manutenção geradas com sucesso`);
      
      res.json({
        message: `Generated ${generatedOrders.length} maintenance work orders`,
        generatedOrders: generatedOrders.length,
        workOrders: generatedOrders,
        period: {
          start: startDate,
          end: endDate
        }
      });
    } catch (error) {
      console.error("Error generating maintenance work orders:", error);
      res.status(500).json({ message: "Failed to generate maintenance work orders" });
    }
  });

  // Monthly regeneration of ALL work orders (cleaning + maintenance) - called automatically
  app.post("/api/scheduler/regenerate-monthly-maintenance", async (req, res) => {
    try {
      console.log(`[MONTHLY SCHEDULER] Iniciando regeneração mensal automática de OSs (LIMPEZA + MANUTENÇÃO)`);
      
      // Get all companies
      const allCompanies = await storage.getCompanies();
      
      let totalCleaningGenerated = 0;
      let totalMaintenanceGenerated = 0;
      
      for (const company of allCompanies) {
        try {
          // Calculate next month window
          const now = new Date();
          const nextMonth = new Date(now.getFullYear(), now.getMonth() + 1, 1);
          const startDate = new Date(nextMonth.getFullYear(), nextMonth.getMonth(), 1);
          const endDate = new Date(nextMonth.getFullYear(), nextMonth.getMonth() + 1, 0, 23, 59, 59);
          
          console.log(`[MONTHLY SCHEDULER] Gerando OSs para ${company.name} - período: ${startDate.toISOString()} até ${endDate.toISOString()}`);
          
          // Generate CLEANING work orders
          const cleaningOrders = await storage.generateScheduledWorkOrders(company.id, startDate, endDate);
          totalCleaningGenerated += cleaningOrders.length;
          console.log(`[MONTHLY SCHEDULER] ✅ ${cleaningOrders.length} OSs de limpeza geradas para ${company.name}`);
          
          // Generate MAINTENANCE work orders
          const maintenanceOrders = await storage.generateMaintenanceWorkOrders(company.id, startDate, endDate);
          totalMaintenanceGenerated += maintenanceOrders.length;
          console.log(`[MONTHLY SCHEDULER] ✅ ${maintenanceOrders.length} OSs de manutenção geradas para ${company.name}`);
          
        } catch (companyError) {
          console.error(`[MONTHLY SCHEDULER] Erro ao gerar OSs para ${company.name}:`, companyError);
        }
      }
      
      const totalGenerated = totalCleaningGenerated + totalMaintenanceGenerated;
      console.log(`[MONTHLY SCHEDULER] ✅ Total: ${totalCleaningGenerated} OSs de limpeza + ${totalMaintenanceGenerated} OSs de manutenção = ${totalGenerated} OSs geradas para próximo mês`);
      
      res.json({
        message: `Monthly regeneration completed`,
        totalGenerated,
        cleaningGenerated: totalCleaningGenerated,
        maintenanceGenerated: totalMaintenanceGenerated,
        companiesProcessed: allCompanies.length
      });
    } catch (error) {
      console.error("Error in monthly regeneration:", error);
      res.status(500).json({ message: "Failed to regenerate monthly work orders" });
    }
  });

  // === SYSTEM USERS MANAGEMENT ===
  
  // Listar usuários do sistema OPUS (type: opus_user)
  app.get("/api/system-users", async (req, res) => {
    try {
      const users = await storage.getOpusUsers();
      
      // Para cada usuário, buscar seus roles customizados, clientes permitidos e remover senha
      const usersWithRoles = await Promise.all(
        users.map(async (user) => {
          const roleAssignments = await storage.getUserRoleAssignments(user.id);
          const allowedCustomers = await storage.getCustomersByUser(user.id);
          const sanitized = sanitizeUser(user);
          return {
            ...sanitized,
            customRoles: roleAssignments,
            allowedCustomers: allowedCustomers
          };
        })
      );
      
      res.json(usersWithRoles);
    } catch (error) {
      console.error("Error fetching system users:", error);
      res.status(500).json({ message: "Failed to fetch system users" });
    }
  });

  // Criar novo usuário do sistema OPUS
  app.post("/api/system-users", async (req, res) => {
    try {
      const userData = insertUserSchema.parse(req.body);
      
      // Hash password if provided
      let hashedPassword = userData.password;
      if (userData.password && (!userData.authProvider || userData.authProvider === 'local')) {
        hashedPassword = await bcrypt.hash(userData.password, 12);
      }
      
      // Gerar ID único para o usuário
      const userId = `user-${nanoid()}`;
      
      const userDataToInsert = {
        id: userId,
        username: userData.username,
        email: userData.email,
        password: hashedPassword || '',
        name: userData.name,
        role: userData.role,
        userType: 'opus_user' as const,
        companyId: 'company-opus-default',
        customerId: null,
        authProvider: userData.authProvider || 'local',
        msTenantId: userData.msTenantId || null,
        modules: userData.modules || ['clean'],
        isActive: userData.isActive ?? true,
      };
      
      const user = await storage.createUser(userDataToInsert);
      res.status(201).json(user);
    } catch (error: any) {
      console.error("Error creating system user:", error);
      
      // Check for duplicate username
      if (error?.code === '23505' && error?.constraint === 'users_username_unique') {
        return res.status(400).json({ 
          message: `Username já está em uso. Por favor, escolha outro username.` 
        });
      }
      
      res.status(500).json({ message: "Failed to create system user" });
    }
  });

  // Atualizar usuário do sistema
  app.patch("/api/system-users/:id", async (req, res) => {
    try {
      const userData = insertUserSchema.partial().parse(req.body);
      const user = await storage.updateUser(req.params.id, userData);
      res.json(sanitizeUser(user));
    } catch (error) {
      console.error("Error updating system user:", error);
      res.status(500).json({ message: "Failed to update system user" });
    }
  });

  // Alterar status (ativo/inativo) de usuário do sistema
  app.patch("/api/system-users/:id/status", async (req, res) => {
    try {
      const { isActive } = req.body;
      const user = await storage.updateUser(req.params.id, { isActive });
      res.json(user);
    } catch (error) {
      console.error("Error updating system user status:", error);
      res.status(500).json({ message: "Failed to update system user status" });
    }
  });

  // === USER ALLOWED CUSTOMERS ===

  // Buscar clientes permitidos para um usuário
  app.get("/api/system-users/:userId/allowed-customers", async (req, res) => {
    try {
      const customers = await storage.getCustomersByUser(req.params.userId);
      res.json(customers);
    } catch (error) {
      console.error("Error fetching user allowed customers:", error);
      res.status(500).json({ message: "Failed to fetch allowed customers" });
    }
  });

  // Definir clientes permitidos para um usuário (substitui lista completa)
  app.put("/api/system-users/:userId/allowed-customers", async (req, res) => {
    try {
      const { customerIds } = req.body;
      
      if (!Array.isArray(customerIds)) {
        return res.status(400).json({ message: "customerIds must be an array" });
      }

      await storage.setUserAllowedCustomers(req.params.userId, customerIds);
      
      // Retornar lista atualizada de clientes
      const customers = await storage.getCustomersByUser(req.params.userId);
      res.json(customers);
    } catch (error) {
      console.error("Error updating user allowed customers:", error);
      res.status(500).json({ message: "Failed to update allowed customers" });
    }
  });

  // === USER SITE ASSIGNMENTS ===
  
  // Get sites assigned to a user
  app.get("/api/users/:userId/site-assignments", async (req, res) => {
    try {
      const assignments = await storage.getUserSiteAssignments(req.params.userId);
      res.json(assignments);
    } catch (error) {
      console.error("Error fetching user site assignments:", error);
      res.status(500).json({ message: "Failed to fetch user site assignments" });
    }
  });

  // Get users assigned to a site
  app.get("/api/sites/:siteId/users", async (req, res) => {
    try {
      const users = await storage.getUsersBySite(req.params.siteId);
      res.json(sanitizeUsers(users));
    } catch (error) {
      console.error("Error fetching site users:", error);
      res.status(500).json({ message: "Failed to fetch site users" });
    }
  });

  // Assign user to site
  app.post("/api/user-site-assignments", async (req, res) => {
    try {
      const assignment = insertUserSiteAssignmentSchema.parse(req.body);
      const newAssignment = await storage.createUserSiteAssignment(assignment);
      res.status(201).json(newAssignment);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error creating user site assignment:", error);
      res.status(500).json({ message: "Failed to create user site assignment" });
    }
  });

  // Remove user from site
  app.delete("/api/users/:userId/sites/:siteId", async (req, res) => {
    try {
      await storage.deleteUserSiteAssignment(req.params.userId, req.params.siteId);
      res.json({ message: "User site assignment removed successfully" });
    } catch (error) {
      console.error("Error removing user site assignment:", error);
      res.status(500).json({ message: "Failed to remove user site assignment" });
    }
  });

  // === PUBLIC REQUEST LOGS (Spam Control) ===
  
  // Check recent public requests for spam control
  app.get("/api/public-requests/check/:ipHash/:qrCodePointId", async (req, res) => {
    try {
      const { ipHash, qrCodePointId } = req.params;
      const hoursWindow = parseInt(req.query.hours as string) || 24;
      const count = await storage.checkRecentPublicRequests(ipHash, qrCodePointId, hoursWindow);
      res.json({ count, allowed: count < 5 }); // Max 5 requests per 24h
    } catch (error) {
      console.error("Error checking public requests:", error);
      res.status(500).json({ message: "Failed to check public requests" });
    }
  });

  // === SITE SHIFTS ===
  
  // Get shifts for a site
  app.get("/api/sites/:siteId/shifts", async (req, res) => {
    try {
      const shifts = await storage.getSiteShifts(req.params.siteId);
      res.json(shifts);
    } catch (error) {
      console.error("Error fetching site shifts:", error);
      res.status(500).json({ message: "Failed to fetch site shifts" });
    }
  });

  // Create new shift
  app.post("/api/site-shifts", async (req, res) => {
    try {
      const shift = insertSiteShiftSchema.parse(req.body);
      const newShift = await storage.createSiteShift(shift);
      res.status(201).json(newShift);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error creating site shift:", error);
      res.status(500).json({ message: "Failed to create site shift" });
    }
  });

  // Update shift
  app.put("/api/site-shifts/:id", async (req, res) => {
    try {
      const shift = insertSiteShiftSchema.parse(req.body);
      const updatedShift = await storage.updateSiteShift(req.params.id, shift);
      res.json(updatedShift);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error updating site shift:", error);
      res.status(500).json({ message: "Failed to update site shift" });
    }
  });

  // Delete shift
  app.delete("/api/site-shifts/:id", async (req, res) => {
    try {
      await storage.deleteSiteShift(req.params.id);
      res.json({ message: "Site shift deleted successfully" });
    } catch (error) {
      console.error("Error deleting site shift:", error);
      res.status(500).json({ message: "Failed to delete site shift" });
    }
  });

  // === BATHROOM COUNTER LOGS ===
  
  // Get bathroom counter audit logs for a zone
  app.get("/api/zones/:zoneId/bathroom-counter-logs", async (req, res) => {
    try {
      const limit = parseInt(req.query.limit as string) || 50;
      const logs = await storage.getBathroomCounterLogs(req.params.zoneId, limit);
      res.json(logs);
    } catch (error) {
      console.error("Error fetching bathroom counter logs:", error);
      res.status(500).json({ message: "Failed to fetch bathroom counter logs" });
    }
  });

  // === COMPANY COUNTERS ===
  
  // Get counter for a company and key
  app.get("/api/companies/:companyId/counters/:key", async (req, res) => {
    try {
      const counter = await storage.getCompanyCounter(req.params.companyId, req.params.key);
      if (!counter) {
        return res.status(404).json({ message: "Counter not found" });
      }
      res.json(counter);
    } catch (error) {
      console.error("Error fetching company counter:", error);
      res.status(500).json({ message: "Failed to fetch company counter" });
    }
  });

  // Create counter
  app.post("/api/company-counters", async (req, res) => {
    try {
      const counter = insertCompanyCounterSchema.parse(req.body);
      const newCounter = await storage.createCompanyCounter(counter);
      res.status(201).json(newCounter);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error creating company counter:", error);
      res.status(500).json({ message: "Failed to create company counter" });
    }
  });

  // ============================================================================
  // MAINTENANCE MODULE - Equipment Routes
  // ============================================================================

  // Get equipment by customer
  app.get("/api/customers/:customerId/equipment", async (req, res) => {
    try {
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const equipment = await storage.getEquipmentByCustomer(req.params.customerId, module);
      res.json(equipment);
    } catch (error) {
      console.error("Error fetching equipment:", error);
      res.status(500).json({ message: "Failed to fetch equipment" });
    }
  });

  // Get equipment by site
  app.get("/api/sites/:siteId/equipment", async (req, res) => {
    try {
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const equipment = await storage.getEquipmentBySite(req.params.siteId, module);
      res.json(equipment);
    } catch (error) {
      console.error("Error fetching equipment:", error);
      res.status(500).json({ message: "Failed to fetch equipment" });
    }
  });

  // Get equipment by zone
  app.get("/api/zones/:zoneId/equipment", async (req, res) => {
    try {
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const equipment = await storage.getEquipmentByZone(req.params.zoneId, module);
      res.json(equipment);
    } catch (error) {
      console.error("Error fetching equipment:", error);
      res.status(500).json({ message: "Failed to fetch equipment" });
    }
  });

  // Get equipment by multiple zones (query parameter)
  app.get("/api/equipment", async (req, res) => {
    try {
      const zoneIdsParam = req.query.zoneIds as string;
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      
      if (!zoneIdsParam) {
        return res.status(400).json({ message: "zoneIds query parameter is required" });
      }
      
      const zoneIds = zoneIdsParam.split(',').filter(id => id.trim());
      
      if (zoneIds.length === 0) {
        return res.json([]);
      }
      
      // Fetch equipment for all zones and merge
      const equipmentPromises = zoneIds.map(zoneId => 
        storage.getEquipmentByZone(zoneId.trim(), module)
      );
      
      const equipmentArrays = await Promise.all(equipmentPromises);
      const allEquipment = equipmentArrays.flat();
      
      // Remove duplicates by ID
      const uniqueEquipment = Array.from(
        new Map(allEquipment.map(eq => [eq.id, eq])).values()
      );
      
      res.json(uniqueEquipment);
    } catch (error) {
      console.error("Error fetching equipment by zones:", error);
      res.status(500).json({ message: "Failed to fetch equipment" });
    }
  });

  // Get single equipment
  app.get("/api/equipment/:id", async (req, res) => {
    try {
      const equipment = await storage.getEquipment(req.params.id);
      if (!equipment) {
        return res.status(404).json({ message: "Equipment not found" });
      }
      res.json(equipment);
    } catch (error) {
      console.error("Error fetching equipment:", error);
      res.status(500).json({ message: "Failed to fetch equipment" });
    }
  });

  // Create equipment
  app.post("/api/equipment", async (req, res) => {
    try {
      console.log("Creating equipment with data:", req.body);
      const equipment = insertEquipmentSchema.parse(req.body);
      console.log("Validated equipment:", equipment);
      const newEquipment = await storage.createEquipment(equipment);
      res.status(201).json(newEquipment);
    } catch (error) {
      if (error instanceof z.ZodError) {
        console.error("Equipment validation error:", JSON.stringify(error.errors, null, 2));
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      // Check for unique constraint violation on serial number
      if (error instanceof Error && error.message.includes('equipment_serial_number_unique')) {
        return res.status(400).json({ message: "Este número de série já está em uso. Por favor, utilize um número de série único." });
      }
      console.error("Error creating equipment:", error);
      res.status(500).json({ message: "Failed to create equipment" });
    }
  });

  // Update equipment
  app.put("/api/equipment/:id", async (req, res) => {
    try {
      const equipment = insertEquipmentSchema.partial().parse(req.body);
      const updatedEquipment = await storage.updateEquipment(req.params.id, equipment);
      res.json(updatedEquipment);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      // Check for unique constraint violation on serial number
      if (error instanceof Error && error.message.includes('equipment_serial_number_unique')) {
        return res.status(400).json({ message: "Este número de série já está em uso. Por favor, utilize um número de série único." });
      }
      console.error("Error updating equipment:", error);
      res.status(500).json({ message: "Failed to update equipment" });
    }
  });

  // Delete equipment
  app.delete("/api/equipment/:id", async (req, res) => {
    try {
      await storage.deleteEquipment(req.params.id);
      res.status(204).send();
    } catch (error) {
      console.error("Error deleting equipment:", error);
      res.status(500).json({ message: "Failed to delete equipment" });
    }
  });

  // Get equipment work order history
  app.get("/api/equipment/:equipmentId/work-orders", async (req, res) => {
    try {
      const workOrders = await storage.getWorkOrdersByEquipment(req.params.equipmentId);
      res.json(workOrders);
    } catch (error) {
      console.error("Error fetching equipment work order history:", error);
      res.status(500).json({ message: "Failed to fetch equipment work order history" });
    }
  });

  // ============================================================================
  // MAINTENANCE MODULE - Maintenance Checklist Templates Routes
  // ============================================================================

  // Get checklist templates by customer
  app.get("/api/customers/:customerId/maintenance-checklist-templates", async (req, res) => {
    try {
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const templates = await storage.getMaintenanceChecklistTemplatesByCustomer(req.params.customerId, module);
      res.json(templates);
    } catch (error) {
      console.error("Error fetching maintenance checklist templates:", error);
      res.status(500).json({ message: "Failed to fetch maintenance checklist templates" });
    }
  });

  // Get checklist templates by equipment type
  app.get("/api/customers/:customerId/maintenance-checklist-templates/equipment-type/:equipmentType", async (req, res) => {
    try {
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const templates = await storage.getMaintenanceChecklistTemplatesByEquipmentType(
        req.params.customerId, 
        req.params.equipmentType,
        module
      );
      res.json(templates);
    } catch (error) {
      console.error("Error fetching maintenance checklist templates:", error);
      res.status(500).json({ message: "Failed to fetch maintenance checklist templates" });
    }
  });

  // Get checklist templates by equipment
  app.get("/api/equipment/:equipmentId/maintenance-checklist-templates", async (req, res) => {
    try {
      const templates = await storage.getMaintenanceChecklistTemplatesByEquipment(req.params.equipmentId);
      res.json(templates);
    } catch (error) {
      console.error("Error fetching maintenance checklist templates:", error);
      res.status(500).json({ message: "Failed to fetch maintenance checklist templates" });
    }
  });

  // Get single checklist template
  app.get("/api/maintenance-checklist-templates/:id", async (req, res) => {
    try {
      const template = await storage.getMaintenanceChecklistTemplate(req.params.id);
      if (!template) {
        return res.status(404).json({ message: "Maintenance checklist template not found" });
      }
      res.json(template);
    } catch (error) {
      console.error("Error fetching maintenance checklist template:", error);
      res.status(500).json({ message: "Failed to fetch maintenance checklist template" });
    }
  });

  // Create checklist template
  app.post("/api/maintenance-checklist-templates", async (req, res) => {
    try {
      const template = insertMaintenanceChecklistTemplateSchema.parse(req.body);
      const newTemplate = await storage.createMaintenanceChecklistTemplate(template);
      res.status(201).json(newTemplate);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error creating maintenance checklist template:", error);
      res.status(500).json({ message: "Failed to create maintenance checklist template" });
    }
  });

  // Update checklist template
  app.put("/api/maintenance-checklist-templates/:id", async (req, res) => {
    try {
      const template = insertMaintenanceChecklistTemplateSchema.partial().parse(req.body);
      const updatedTemplate = await storage.updateMaintenanceChecklistTemplate(req.params.id, template);
      res.json(updatedTemplate);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error updating maintenance checklist template:", error);
      res.status(500).json({ message: "Failed to update maintenance checklist template" });
    }
  });

  // Delete checklist template
  app.delete("/api/maintenance-checklist-templates/:id", async (req, res) => {
    try {
      await storage.deleteMaintenanceChecklistTemplate(req.params.id);
      res.status(204).send();
    } catch (error) {
      console.error("Error deleting maintenance checklist template:", error);
      res.status(500).json({ message: "Failed to delete maintenance checklist template" });
    }
  });

  // ============================================================================
  // MAINTENANCE MODULE - Maintenance Checklist Executions Routes
  // ============================================================================

  // Get executions by equipment
  app.get("/api/equipment/:equipmentId/maintenance-checklist-executions", async (req, res) => {
    try {
      const executions = await storage.getMaintenanceChecklistExecutionsByEquipment(req.params.equipmentId);
      res.json(executions);
    } catch (error) {
      console.error("Error fetching maintenance checklist executions:", error);
      res.status(500).json({ message: "Failed to fetch maintenance checklist executions" });
    }
  });

  // Get executions by work order
  app.get("/api/work-orders/:workOrderId/maintenance-checklist-executions", async (req, res) => {
    try {
      const executions = await storage.getMaintenanceChecklistExecutionsByWorkOrder(req.params.workOrderId);
      res.json(executions);
    } catch (error) {
      console.error("Error fetching maintenance checklist executions:", error);
      res.status(500).json({ message: "Failed to fetch maintenance checklist executions" });
    }
  });

  // Get single execution
  app.get("/api/maintenance-checklist-executions/:id", async (req, res) => {
    try {
      const execution = await storage.getMaintenanceChecklistExecution(req.params.id);
      if (!execution) {
        return res.status(404).json({ message: "Maintenance checklist execution not found" });
      }
      res.json(execution);
    } catch (error) {
      console.error("Error fetching maintenance checklist execution:", error);
      res.status(500).json({ message: "Failed to fetch maintenance checklist execution" });
    }
  });

  // Create execution
  app.post("/api/maintenance-checklist-executions", async (req, res) => {
    try {
      const execution = insertMaintenanceChecklistExecutionSchema.parse(req.body);
      const newExecution = await storage.createMaintenanceChecklistExecution(execution);
      res.status(201).json(newExecution);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error creating maintenance checklist execution:", error);
      res.status(500).json({ message: "Failed to create maintenance checklist execution" });
    }
  });

  // Update execution
  app.put("/api/maintenance-checklist-executions/:id", async (req, res) => {
    try {
      const execution = insertMaintenanceChecklistExecutionSchema.partial().parse(req.body);
      const updatedExecution = await storage.updateMaintenanceChecklistExecution(req.params.id, execution);
      res.json(updatedExecution);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error updating maintenance checklist execution:", error);
      res.status(500).json({ message: "Failed to update maintenance checklist execution" });
    }
  });

  // Delete execution
  app.delete("/api/maintenance-checklist-executions/:id", async (req, res) => {
    try {
      await storage.deleteMaintenanceChecklistExecution(req.params.id);
      res.status(204).send();
    } catch (error) {
      console.error("Error deleting maintenance checklist execution:", error);
      res.status(500).json({ message: "Failed to delete maintenance checklist execution" });
    }
  });

  // ============================================================================
  // MAINTENANCE MODULE - Maintenance Plans Routes
  // ============================================================================

  // Get plans by customer
  app.get("/api/customers/:customerId/maintenance-plans", async (req, res) => {
    try {
      const module = req.query.module as 'clean' | 'maintenance' | undefined;
      const plans = await storage.getMaintenancePlansByCustomer(req.params.customerId, module);
      res.json(plans);
    } catch (error) {
      console.error("Error fetching maintenance plans:", error);
      res.status(500).json({ message: "Failed to fetch maintenance plans" });
    }
  });

  // Get single plan
  app.get("/api/maintenance-plans/:id", async (req, res) => {
    try {
      const plan = await storage.getMaintenancePlan(req.params.id);
      if (!plan) {
        return res.status(404).json({ message: "Maintenance plan not found" });
      }
      res.json(plan);
    } catch (error) {
      console.error("Error fetching maintenance plan:", error);
      res.status(500).json({ message: "Failed to fetch maintenance plan" });
    }
  });

  // Create plan
  app.post("/api/maintenance-plans", async (req, res) => {
    try {
      const plan = insertMaintenancePlanSchema.parse(req.body);
      const newPlan = await storage.createMaintenancePlan(plan);
      res.status(201).json(newPlan);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error creating maintenance plan:", error);
      res.status(500).json({ message: "Failed to create maintenance plan" });
    }
  });

  // Update plan
  app.put("/api/maintenance-plans/:id", async (req, res) => {
    try {
      const plan = insertMaintenancePlanSchema.partial().parse(req.body);
      const updatedPlan = await storage.updateMaintenancePlan(req.params.id, plan);
      res.json(updatedPlan);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error updating maintenance plan:", error);
      res.status(500).json({ message: "Failed to update maintenance plan" });
    }
  });

  // Delete plan
  app.delete("/api/maintenance-plans/:id", async (req, res) => {
    try {
      await storage.deleteMaintenancePlan(req.params.id);
      res.status(204).send();
    } catch (error) {
      console.error("Error deleting maintenance plan:", error);
      res.status(500).json({ message: "Failed to delete maintenance plan" });
    }
  });

  // ============================================================================
  // MAINTENANCE MODULE - Maintenance Plan Equipment Routes
  // ============================================================================

  // Get plan equipments by plan
  app.get("/api/maintenance-plans/:planId/equipments", async (req, res) => {
    try {
      const planEquipments = await storage.getMaintenancePlanEquipmentsByPlan(req.params.planId);
      res.json(planEquipments);
    } catch (error) {
      console.error("Error fetching maintenance plan equipments:", error);
      res.status(500).json({ message: "Failed to fetch maintenance plan equipments" });
    }
  });

  // Get plan equipments by equipment
  app.get("/api/equipment/:equipmentId/maintenance-plans", async (req, res) => {
    try {
      const planEquipments = await storage.getMaintenancePlanEquipmentsByEquipment(req.params.equipmentId);
      res.json(planEquipments);
    } catch (error) {
      console.error("Error fetching maintenance plan equipments:", error);
      res.status(500).json({ message: "Failed to fetch maintenance plan equipments" });
    }
  });

  // Get single plan equipment
  app.get("/api/maintenance-plan-equipments/:id", async (req, res) => {
    try {
      const planEquipment = await storage.getMaintenancePlanEquipment(req.params.id);
      if (!planEquipment) {
        return res.status(404).json({ message: "Maintenance plan equipment not found" });
      }
      res.json(planEquipment);
    } catch (error) {
      console.error("Error fetching maintenance plan equipment:", error);
      res.status(500).json({ message: "Failed to fetch maintenance plan equipment" });
    }
  });

  // Create plan equipment
  app.post("/api/maintenance-plan-equipments", async (req, res) => {
    try {
      const planEquipment = insertMaintenancePlanEquipmentSchema.parse(req.body);
      const newPlanEquipment = await storage.createMaintenancePlanEquipment(planEquipment);
      res.status(201).json(newPlanEquipment);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error creating maintenance plan equipment:", error);
      res.status(500).json({ message: "Failed to create maintenance plan equipment" });
    }
  });

  // Update plan equipment
  app.put("/api/maintenance-plan-equipments/:id", async (req, res) => {
    try {
      const planEquipment = insertMaintenancePlanEquipmentSchema.partial().parse(req.body);
      const updatedPlanEquipment = await storage.updateMaintenancePlanEquipment(req.params.id, planEquipment);
      res.json(updatedPlanEquipment);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error updating maintenance plan equipment:", error);
      res.status(500).json({ message: "Failed to update maintenance plan equipment" });
    }
  });

  // Delete plan equipment
  app.delete("/api/maintenance-plan-equipments/:id", async (req, res) => {
    try {
      await storage.deleteMaintenancePlanEquipment(req.params.id);
      res.status(204).send();
    } catch (error) {
      console.error("Error deleting maintenance plan equipment:", error);
      res.status(500).json({ message: "Failed to delete maintenance plan equipment" });
    }
  });

  // ============================================================================
  // AI INTEGRATIONS (OPUS Users Only)
  // ============================================================================

  // Get all AI integrations for a company
  app.get("/api/ai-integrations", requireAuth, requireOpusUser, async (req, res) => {
    try {
      if (!req.user?.companyId) {
        return res.status(400).json({ message: "Company ID not found" });
      }
      const integrations = await storage.getAiIntegrations(req.user.companyId);
      res.json(integrations);
    } catch (error) {
      console.error("Error fetching AI integrations:", error);
      res.status(500).json({ message: "Failed to fetch AI integrations" });
    }
  });

  // Get single AI integration
  app.get("/api/ai-integrations/:id", requireAuth, requireOpusUser, async (req, res) => {
    try {
      const integration = await storage.getAiIntegration(req.params.id);
      if (!integration) {
        return res.status(404).json({ message: "AI integration not found" });
      }
      res.json(integration);
    } catch (error) {
      console.error("Error fetching AI integration:", error);
      res.status(500).json({ message: "Failed to fetch AI integration" });
    }
  });

  // Get default AI integration
  app.get("/api/ai-integrations/default/:companyId", requireAuth, requireOpusUser, async (req, res) => {
    try {
      const integration = await storage.getDefaultAiIntegration(req.params.companyId);
      if (!integration) {
        return res.status(404).json({ message: "No default AI integration found" });
      }
      res.json(integration);
    } catch (error) {
      console.error("Error fetching default AI integration:", error);
      res.status(500).json({ message: "Failed to fetch default AI integration" });
    }
  });

  // Create AI integration
  app.post("/api/ai-integrations", requireAuth, requireOpusUser, async (req, res) => {
    try {
      if (!req.user?.companyId) {
        return res.status(400).json({ message: "Company ID not found" });
      }
      if (!req.user?.id) {
        return res.status(400).json({ message: "User ID not found" });
      }
      const integration = insertAiIntegrationSchema.parse({
        ...req.body,
        companyId: req.user.companyId,
        createdBy: req.user.id
      });
      const newIntegration = await storage.createAiIntegration(integration);
      res.status(201).json(newIntegration);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error creating AI integration:", error);
      res.status(500).json({ message: "Failed to create AI integration" });
    }
  });

  // Update AI integration
  app.put("/api/ai-integrations/:id", requireAuth, requireOpusUser, async (req, res) => {
    try {
      const integration = insertAiIntegrationSchema.partial().parse(req.body);
      const updatedIntegration = await storage.updateAiIntegration(req.params.id, integration);
      res.json(updatedIntegration);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ message: "Invalid data", errors: error.errors });
      }
      console.error("Error updating AI integration:", error);
      res.status(500).json({ message: "Failed to update AI integration" });
    }
  });

  // Delete AI integration
  app.delete("/api/ai-integrations/:id", requireAuth, requireOpusUser, async (req, res) => {
    try {
      await storage.deleteAiIntegration(req.params.id);
      res.status(204).send();
    } catch (error) {
      console.error("Error deleting AI integration:", error);
      res.status(500).json({ message: "Failed to delete AI integration" });
    }
  });

  // Test AI integration connection
  app.post("/api/ai-integrations/:id/test", requireAuth, requireOpusUser, async (req, res) => {
    try {
      const result = await storage.testAiIntegration(req.params.id);
      res.json(result);
    } catch (error) {
      console.error("Error testing AI integration:", error);
      res.status(500).json({ message: "Failed to test AI integration" });
    }
  });

  // ===== CHAT ENDPOINTS =====

  // Get active conversation and messages
  app.get("/api/chat/conversation", requireAuth, async (req, res) => {
    try {
      if (!req.user?.id) {
        return res.status(401).json({ message: "User not authenticated" });
      }

      const { customerId, module } = req.query;
      
      const conversation = await storage.getActiveConversation(
        req.user.id,
        customerId as string,
        module as 'clean' | 'maintenance'
      );
      
      if (!conversation) {
        return res.json(serializeForAI({ conversation: null, messages: [] }));
      }

      const messages = await storage.getConversationMessages(conversation.id);
      res.json(serializeForAI({ conversation, messages }));
    } catch (error) {
      console.error("Error fetching conversation:", error);
      res.status(500).json({ message: "Failed to fetch conversation" });
    }
  });

  // Send message
  app.post("/api/chat/message", requireAuth, async (req, res) => {
    try {
      if (!req.user?.id || !req.user?.companyId) {
        return res.status(401).json({ message: "User not authenticated" });
      }

      const { message, module, customerId } = req.body;

      if (!message || typeof message !== 'string') {
        return res.status(400).json({ message: "Message is required" });
      }

      if (!module || !['clean', 'maintenance'].includes(module)) {
        return res.status(400).json({ message: "Valid module is required" });
      }

      // Use customerId from request body (for OPUS users) or from user object (for customer users)
      const effectiveCustomerId = customerId || req.user.customerId || null;

      if (!effectiveCustomerId) {
        return res.status(400).json({ message: "Customer ID is required" });
      }

      const result = await storage.processUserMessage(
        req.user.id,
        req.user.companyId,
        effectiveCustomerId,
        module,
        message
      );

      res.json(serializeForAI(result));
    } catch (error) {
      console.error("Error processing message:", error);
      res.status(500).json({ message: "Failed to process message" });
    }
  });

  // ===== TV MODE DASHBOARD ENDPOINTS =====

  // Get TV Mode statistics (work orders and leaderboard)
  app.get("/api/tv-mode/stats", requireAuth, async (req, res) => {
    try {
      const { customerId, module } = req.query;

      console.log("[TV MODE] Request received with params:", { customerId, module });

      if (!customerId || !module) {
        return res.status(400).json({ message: "customerId and module are required" });
      }

      const stats = await storage.getTvModeStats(
        customerId as string,
        module as 'clean' | 'maintenance'
      );

      console.log("[TV MODE] Stats fetched:", JSON.stringify(stats, null, 2));

      res.json(stats);
    } catch (error) {
      console.error("[TV MODE] Error fetching TV mode stats:", error);
      res.status(500).json({ message: "Failed to fetch TV mode statistics" });
    }
  });

  // ===== OFFLINE SYNC ENDPOINTS =====

  // Batch sync endpoint - receives offline data from mobile app
  app.post("/api/sync/batch", requireAuth, async (req, res) => {
    try {
      if (!req.user?.id || !req.user?.customerId) {
        return res.status(401).json({ message: "User not authenticated or missing customer" });
      }

      console.log("[SYNC] Batch sync request received from user:", req.user.id, "customer:", req.user.customerId);
      
      // Validate request body
      const validatedData = syncBatchRequestSchema.parse(req.body);
      
      // SECURITY: Validate that all data belongs to user's customer
      const userCustomerId = req.user.customerId;
      
      // Check all work orders belong to user's customer
      if (validatedData.workOrders) {
        const invalidWOs = validatedData.workOrders.filter(wo => wo.customerId !== userCustomerId);
        if (invalidWOs.length > 0) {
          console.warn("[SYNC] Security violation: User attempted to sync work orders for different customer");
          return res.status(403).json({ 
            message: "Forbidden: Cannot sync data for different customer",
            details: `${invalidWOs.length} work orders rejected`
          });
        }
      }

      // Check all checklist executions belong to user's customer (via work order)
      if (validatedData.checklistExecutions) {
        for (const exec of validatedData.checklistExecutions) {
          if (exec.workOrderId) {
            const wo = await storage.getWorkOrder(exec.workOrderId);
            if (wo && wo.customerId !== userCustomerId) {
              console.warn("[SYNC] Security violation: User attempted to sync checklist for different customer");
              return res.status(403).json({ 
                message: "Forbidden: Cannot sync data for different customer"
              });
            }
          }
        }
      }

      // Check all attachments belong to user's customer (via work order)
      if (validatedData.attachments) {
        for (const att of validatedData.attachments) {
          if (att.workOrderId) {
            const wo = await storage.getWorkOrder(att.workOrderId);
            if (wo && wo.customerId !== userCustomerId) {
              console.warn("[SYNC] Security violation: User attempted to sync attachment for different customer");
              return res.status(403).json({ 
                message: "Forbidden: Cannot sync data for different customer"
              });
            }
          }
        }
      }
      
      // Log sync stats
      const stats = {
        workOrders: validatedData.workOrders?.length || 0,
        checklistExecutions: validatedData.checklistExecutions?.length || 0,
        attachments: validatedData.attachments?.length || 0,
      };
      console.log("[SYNC] Processing batch:", stats);

      // Execute sync
      const result = await storage.syncBatch(validatedData);

      console.log("[SYNC] Batch sync completed:", {
        success: result.success,
        workOrders: result.workOrders.length,
        checklistExecutions: result.checklistExecutions.length,
        attachments: result.attachments.length,
      });

      res.json(result);
    } catch (error) {
      console.error("[SYNC] Batch sync error:", error);
      
      if (error instanceof z.ZodError) {
        return res.status(400).json({ 
          message: "Invalid sync data", 
          errors: error.errors 
        });
      }
      
      res.status(500).json({ 
        message: "Failed to sync batch",
        error: error instanceof Error ? error.message : "Unknown error"
      });
    }
  });

  const httpServer = createServer(app);
  return httpServer;
}
