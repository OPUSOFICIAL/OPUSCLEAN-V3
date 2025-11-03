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
  type User
} from "@shared/schema";
import { z } from "zod";
import crypto from "crypto";
import {
  requireAuth,
  requireAdmin,
  requireManageClients,
  requireManageUsers,
  requireManageWorkOrders,
  requireViewReports,
  requireOwnCustomer
} from "./middleware/auth";
import { sanitizeUser, sanitizeUsers } from "./utils/security";

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
      const sites = await storage.getSitesByCompany(req.params.companyId);
      res.json(sites);
    } catch (error) {
      res.status(500).json({ message: "Failed to get sites" });
    }
  });

  // Get sites by customer
  app.get("/api/customers/:customerId/sites", async (req, res) => {
    try {
      const sites = await storage.getSitesByCustomer(req.params.customerId);
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
      const site = insertSiteSchema.parse(req.body);
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
      const zones = await storage.getZonesByCompany(req.params.companyId);
      res.json(zones);
    } catch (error) {
      res.status(500).json({ message: "Failed to get zones" });
    }
  });

  // QR Code Points by Company
  app.get("/api/companies/:companyId/qr-points", async (req, res) => {
    try {
      const qrPoints = await storage.getQrCodePointsByCompany(req.params.companyId);
      res.json(qrPoints);
    } catch (error) {
      res.status(500).json({ message: "Failed to get QR code points" });
    }
  });

  // QR Points by Customer (filtrado por cliente)
  app.get("/api/customers/:customerId/qr-points", async (req, res) => {
    try {
      const qrPoints = await storage.getQrCodePointsByCustomer(req.params.customerId);
      res.json(qrPoints);
    } catch (error) {
      res.status(500).json({ message: "Failed to get customer QR code points" });
    }
  });

  // Zones by Customer (filtrado por cliente)
  app.get("/api/customers/:customerId/zones", async (req, res) => {
    try {
      const zones = await storage.getZonesByCustomer(req.params.customerId);
      res.json(zones);
    } catch (error) {
      res.status(500).json({ message: "Failed to get customer zones" });
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
      
      // Para cada usuário, buscar seus roles customizados e remover senha
      const usersWithRoles = await Promise.all(
        users.map(async (user) => {
          const roleAssignments = await storage.getUserRoleAssignments(user.id);
          const sanitized = sanitizeUser(user);
          return {
            ...sanitized,
            customRoles: roleAssignments
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
      const templates = await storage.getChecklistTemplatesByCustomer(req.params.customerId);
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
      const checklistData = { ...req.body, companyId };
      
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
      
      // Verify the template belongs to this customer's company
      const existingTemplate = await storage.getChecklistTemplate(req.params.id);
      if (!existingTemplate || existingTemplate.companyId !== companyId) {
        return res.status(403).json({ message: "Checklist template not found or access denied" });
      }

      const checklistData = { ...req.body, companyId };
      const template = await storage.updateChecklistTemplate(req.params.id, checklistData);
      res.json(template);
    } catch (error) {
      res.status(500).json({ message: "Failed to update customer checklist template" });
    }
  });

  app.delete("/api/customers/:customerId/checklist-templates/:id", async (req, res) => {
    try {
      // Validate that the customer exists and get their company
      const customerSites = await storage.getSitesByCustomer(req.params.customerId);
      if (customerSites.length === 0) {
        return res.status(404).json({ message: "Customer not found" });
      }

      const companyId = customerSites[0].companyId;
      
      // Verify the template belongs to this customer's company
      const existingTemplate = await storage.getChecklistTemplate(req.params.id);
      if (!existingTemplate || existingTemplate.companyId !== companyId) {
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
      const { zoneId, assignedTo, status, serviceId } = req.query;
      
      // Filter by zone if provided
      if (zoneId) {
        workOrders = workOrders.filter(wo => wo.zoneId === zoneId);
      }
      
      // Filter by assignedTo if provided (include unassigned work orders too)
      if (assignedTo) {
        workOrders = workOrders.filter(wo => wo.assignedUserId === assignedTo || wo.assignedUserId === null);
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

  // Work Orders by Customer - Delete (filtrado por cliente)
  app.delete("/api/customers/:customerId/work-orders/:id", async (req, res) => {
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
      const analytics = await storage.getAnalyticsByCustomer(req.params.customerId, period, "todos");
      res.json(analytics);
    } catch (error) {
      res.status(500).json({ message: "Failed to get customer metrics" });
    }
  });

  app.get("/api/customers/:customerId/reports/work-orders-status", async (req, res) => {
    try {
      const period = req.query.period as string || "30";
      const analytics = await storage.getAnalyticsByCustomer(req.params.customerId, period, "todos");
      res.json(analytics?.workOrdersStatus || []);
    } catch (error) {
      res.status(500).json({ message: "Failed to get customer work orders status" });
    }
  });

  app.get("/api/customers/:customerId/reports/sla-performance", async (req, res) => {
    try {
      const period = req.query.period as string || "30";
      const analytics = await storage.getAnalyticsByCustomer(req.params.customerId, period, "todos");
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
      const generalReport = await storage.getGeneralReport(customerId, period);
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
      const slaAnalysis = await storage.getSLAAnalysis(customerId, period);
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
      const operatorPerformance = await storage.getOperatorPerformance(customerId, period);
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
      const locationAnalysis = await storage.getLocationAnalysis(customerId, period);
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
      const temporalAnalysis = await storage.getTemporalAnalysis(customerId, period);
      res.json(temporalAnalysis);
    } catch (error) {
      res.status(500).json({ message: "Failed to get temporal analysis" });
    }
  });

  app.get("/api/sites/:siteId/zones", async (req, res) => {
    try {
      const zones = await storage.getZonesBySite(req.params.siteId);
      res.json(zones);
    } catch (error) {
      res.status(500).json({ message: "Failed to get zones" });
    }
  });

  // Get zones by multiple sites
  app.get("/api/zones", async (req, res) => {
    try {
      const { siteIds } = req.query;
      if (!siteIds) {
        return res.status(400).json({ message: "siteIds parameter is required" });
      }
      
      const siteIdArray = typeof siteIds === 'string' ? siteIds.split(',') : [];
      const allZones = [];
      
      for (const siteId of siteIdArray) {
        const zones = await storage.getZonesBySite(siteId.trim());
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
      const zone = insertZoneSchema.parse(req.body);
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

  // QR Code Resolution - Returns all context in one call
  app.get("/api/qr-scan/resolve", async (req, res) => {
    try {
      const code = req.query.code as string;
      
      if (!code) {
        return res.status(400).json({ message: "QR code parameter is required" });
      }

      const resolved = await storage.resolveQrCode(code);
      
      if (!resolved) {
        return res.status(404).json({ message: "QR code not found or inactive" });
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

  // QR Code Resolution - NEW correct endpoint format
  app.get("/api/qrs/:code/resolve", async (req, res) => {
    try {
      const code = req.params.code;
      
      if (!code) {
        return res.status(400).json({ message: "QR code parameter is required" });
      }

      const resolved = await storage.resolveQrCode(code);
      
      if (!resolved) {
        return res.status(404).json({ message: "QR code not found or inactive" });
      }

      res.json(resolved);
    } catch (error) {
      console.error("Error resolving QR code:", error);
      res.status(500).json({ message: "Failed to resolve QR code" });
    }
  });

  app.post("/api/qr-points", async (req, res) => {
    try {
      const qrPoint = insertQrCodePointSchema.parse(req.body);
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
      const templates = await storage.getChecklistTemplatesByCompany(req.params.companyId);
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
      console.log("Creating service type with data:", req.body, "customerId:", req.params.customerId);
      
      // Generate code from name if not provided
      const code = req.body.code || req.body.name.toUpperCase().replace(/\s+/g, '_').replace(/[^A-Z0-9_]/g, '');
      
      const dataToValidate = {
        ...req.body,
        code,
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
      
      // Check if it's a foreign key constraint error
      if (error.code === '23503' && error.constraint?.includes('service_categories')) {
        return res.status(400).json({ 
          message: "Não é possível excluir este tipo de serviço porque existem categorias vinculadas a ele. Exclua primeiro as categorias relacionadas." 
        });
      }
      
      res.status(500).json({ message: "Failed to delete service type" });
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

  // Service Categories
  app.get("/api/customers/:customerId/service-categories", async (req, res) => {
    try {
      const serviceCategories = await storage.getServiceCategoriesByCustomer(req.params.customerId);
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
  });

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
      
      // Filter by assignedTo if provided (include unassigned work orders too)
      if (assignedTo) {
        workOrders = workOrders.filter(wo => wo.assignedUserId === assignedTo || wo.assignedUserId === null);
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

  app.put("/api/work-orders/:id", async (req, res) => {
    try {
      const workOrder = insertWorkOrderSchema.partial().parse(req.body);
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

  app.patch("/api/work-orders/:id", async (req, res) => {
    try {
      const workOrder = insertWorkOrderSchema.partial().parse(req.body);
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

  app.delete("/api/work-orders/:id", async (req, res) => {
    try {
      await storage.deleteWorkOrder(req.params.id);
      res.json({ message: "Work order deleted successfully" });
    } catch (error) {
      res.status(500).json({ message: "Failed to delete work order" });
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
        dueDate: null
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
      const customer = insertCustomerSchema.parse({
        ...req.body,
        companyId: req.params.companyId
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

  // Create cleaning activity
  app.post("/api/cleaning-activities", async (req, res) => {
    try {
      // Limpar campos que podem ter valores inválidos
      const cleanedData = { 
        ...req.body,
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

  // === SCHEDULER MANAGEMENT ===
  
  // Generate scheduled work orders from cleaning activities
  app.post("/api/scheduler/generate-work-orders", async (req, res) => {
    try {
      const { companyId, windowStart, windowEnd } = req.body;
      
      if (!companyId) {
        return res.status(400).json({ message: "Company ID is required" });
      }
      
      // Default window: APENAS MÊS CORRENTE (1 mês)
      // Isso evita criar milhões de OS, gerando apenas o necessário
      const now = new Date();
      const startDate = windowStart ? new Date(windowStart) : new Date(now.getFullYear(), now.getMonth(), 1);
      // Fim = último dia do mês corrente
      const endDate = windowEnd ? new Date(windowEnd) : new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59);
      
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

  // === SYSTEM USERS MANAGEMENT ===
  
  // Listar usuários do sistema OPUS (type: opus_user)
  app.get("/api/system-users", async (req, res) => {
    try {
      const users = await storage.getOpusUsers();
      
      // Para cada usuário, buscar seus roles customizados e remover senha
      const usersWithRoles = await Promise.all(
        users.map(async (user) => {
          const roleAssignments = await storage.getUserRoleAssignments(user.id);
          const sanitized = sanitizeUser(user);
          return {
            ...sanitized,
            customRoles: roleAssignments
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
      
      // NÃO enviar o campo ID - deixar o DEFAULT do banco gerar
      const userDataToInsert: any = {
        username: userData.username,
        email: userData.email,
        password: hashedPassword || '',
        name: userData.name,
        role: userData.role,
        userType: 'opus_user',
        companyId: 'company-opus-default',
        customerId: null,
        phone: userData.phone || null,
        authProvider: userData.authProvider || 'local',
        msUserId: userData.msUserId || null,
        msTenantId: userData.msTenantId || null,
        isActive: userData.isActive ?? true,
      };
      
      const user = await storage.createUser(userDataToInsert);
      res.status(201).json(user);
    } catch (error: any) {
      console.error("Error creating system user:", error);
      
      // Check for duplicate username
      if (error?.code === '23505' && error?.constraint === 'users_username_unique') {
        return res.status(400).json({ 
          message: `Username '${userData.username}' já está em uso. Por favor, escolha outro username.` 
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

  const httpServer = createServer(app);
  return httpServer;
}
