import { createRoot } from "react-dom/client";
import { QueryClientProvider } from "@tanstack/react-query";
import { queryClient } from "./lib/queryClient";
import { BrandingProvider } from "@/contexts/BrandingContext";
import App from "./App";
import "./index.css";

createRoot(document.getElementById("root")!).render(
  <QueryClientProvider client={queryClient}>
    <BrandingProvider>
      <App />
    </BrandingProvider>
  </QueryClientProvider>
);
