import 'dotenv/config';
import express, { type Request, Response, NextFunction } from "express";
import { registerRoutes } from "./routes";
import { setupVite, serveStatic, log } from "./vite";
import helmet from "helmet";
import cors from "cors";

const app = express();

// Trust proxy for rate limiting and IP detection (required for Replit/VM deployment)
app.set('trust proxy', 1);

app.use(helmet({
  contentSecurityPolicy: false,
  crossOriginEmbedderPolicy: false,
}));

app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? [process.env.REPLIT_DOMAIN || 'https://*.replit.dev'] 
    : true,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: false, limit: '50mb' }));

app.use((req, res, next) => {
  const start = Date.now();
  const path = req.path;
  let capturedJsonResponse: Record<string, any> | undefined = undefined;

  const originalResJson = res.json;
  res.json = function (bodyJson, ...args) {
    capturedJsonResponse = bodyJson;
    return originalResJson.apply(res, [bodyJson, ...args]);
  };

  res.on("finish", () => {
    const duration = Date.now() - start;
    if (path.startsWith("/api")) {
      let logLine = `${req.method} ${path} ${res.statusCode} in ${duration}ms`;
      if (capturedJsonResponse) {
        logLine += ` :: ${JSON.stringify(capturedJsonResponse)}`;
      }

      if (logLine.length > 80) {
        logLine = logLine.slice(0, 79) + "…";
      }

      log(logLine);
    }
  });

  next();
});

(async () => {
  const server = await registerRoutes(app);

  app.use((err: any, _req: Request, res: Response, _next: NextFunction) => {
    const status = err.status || err.statusCode || 500;
    const message = err.message || "Internal Server Error";

    res.status(status).json({ message });
    throw err;
  });

  // importantly only setup vite in development and after
  // setting up all the other routes so the catch-all route
  // doesn't interfere with the other routes
  if (app.get("env") === "development") {
    await setupVite(app, server);
  } else {
    serveStatic(app);
  }

  // ALWAYS serve the app on the port specified in the environment variable PORT
  // Other ports are firewalled. Default to 5000 if not specified.
  // this serves both the API and the client.
  // It is the only port that is not firewalled.
  const port = parseInt(process.env.PORT || '5000', 10);
  server.listen({
    port,
    host: "0.0.0.0",
    reusePort: true,
  }, () => {
    log(`serving on port ${port}`);
    
    // Schedule monthly maintenance work order generation
    scheduleMonthlyMaintenance();
  });
})();

// Monthly maintenance scheduler - runs on the last day of each month at 23:00
function scheduleMonthlyMaintenance() {
  function checkAndRun() {
    const now = new Date();
    const tomorrow = new Date(now);
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    // Check if tomorrow is a new month (meaning today is last day of month)
    const isLastDayOfMonth = tomorrow.getMonth() !== now.getMonth();
    
    // Run at 23:00 on the last day of month
    if (isLastDayOfMonth && now.getHours() === 23 && now.getMinutes() === 0) {
      log('[MONTHLY SCHEDULER] Executando geração automática de OSs para próximo mês');
      
      fetch(`http://localhost:${parseInt(process.env.PORT || '5000', 10)}/api/scheduler/regenerate-monthly-maintenance`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      })
        .then(res => res.json())
        .then(data => {
          log(`[MONTHLY SCHEDULER] ✅ Geração concluída: ${data.totalGenerated} OSs criadas`);
        })
        .catch(error => {
          console.error('[MONTHLY SCHEDULER] ❌ Erro na geração automática:', error);
        });
    }
  }
  
  // Check every hour
  setInterval(checkAndRun, 60 * 60 * 1000);
  log('[MONTHLY SCHEDULER] Agendamento mensal ativado - roda todo último dia do mês às 23:00');
}
