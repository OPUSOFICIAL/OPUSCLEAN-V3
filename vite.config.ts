import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";
// import runtimeErrorOverlay from "@replit/vite-plugin-runtime-error-modal";

export default defineConfig({
  plugins: [
    react({ fastRefresh: false }),
    // runtimeErrorOverlay(), // Temporariamente desabilitado
    // Cartographer desabilitado para Replit para evitar HMR issues
  ],
  resolve: {
    alias: {
      "@": path.resolve(import.meta.dirname, "client", "src"),
      "@shared": path.resolve(import.meta.dirname, "shared"),
      "@assets": path.resolve(import.meta.dirname, "attached_assets"),
    },
  },
  root: path.resolve(import.meta.dirname, "client"),
  build: {
    outDir: path.resolve(import.meta.dirname, "dist/public"),
    emptyOutDir: true,
  },
  server: {
    middlewareMode: true,
    host: "0.0.0.0",
    port: 5000,
    strictPort: false,
    hmr: {
      protocol: "wss",
      host: typeof window !== "undefined" ? window.location.hostname : "localhost",
      port: 443,
    },
    fs: {
      strict: true,
      deny: ["**/.*"],
    },
  },
});
