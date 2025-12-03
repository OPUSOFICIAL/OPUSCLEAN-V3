/**
 * Adaptive Subdomain Detection Utility
 * 
 * Extracts subdomain from any URL hostname dynamically - works with:
 * - Replit dev: tecnofibra.janeway.replit.dev
 * - Production VM: tecnofibra.acelera.com
 * - Any custom domain: tecnofibra.customdomain.com
 * 
 * IMPORTANTE: NÃO usa query params - branding é carregado do activeClient em memória
 */

export interface SubdomainDetectionResult {
  subdomain: string | null;
  fullHostname: string;
  isTestMode: boolean;
}

/**
 * Detects subdomain adaptively from current URL
 * - Extracts first part of hostname (before first dot)
 * - Returns null if no subdomain detected (e.g., root domain)
 * - Handles 2-label domains like localhost and custom TLDs
 * 
 * NOTA: Para usuários logados, o branding é carregado do activeClient (não do subdomain)
 */
export function detectSubdomain(): SubdomainDetectionResult {
  const fullHostname = window.location.hostname;
  
  // Handle special cases
  if (fullHostname === 'localhost' || fullHostname === '127.0.0.1') {
    return {
      subdomain: null,
      fullHostname,
      isTestMode: false
    };
  }
  
  // Extract subdomain adaptively from hostname
  // Examples:
  // tecnofibra.localhost -> ["tecnofibra", "localhost"] (2 parts)
  // tecnofibra.janeway.replit.dev -> ["tecnofibra", "janeway", "replit", "dev"] (4 parts)
  // tecnofibras.acelera.com -> ["tecnofibra", "acelera", "com"] (3 parts)
  // tecnofibra.co.uk -> ["tecnofibra", "co", "uk"] (3 parts)
  const parts = fullHostname.split('.');
  
  // If hostname has more than 1 part, first part might be the subdomain
  if (parts.length >= 2) {
    const subdomain = parts[0].toLowerCase();
    
    // Filter out common non-subdomain prefixes
    if (subdomain === 'www') {
      return {
        subdomain: null,
        fullHostname,
        isTestMode: false
      };
    }
    
    // For 2-part domains, check if it's a known development pattern
    // tenant.localhost, tenant.vercel.app, etc.
    if (parts.length === 2) {
      const secondPart = parts[1].toLowerCase();
      // If second part is a known dev/platform domain, first part is subdomain
      if (['localhost', 'vercel', 'app', 'dev', 'ngrok'].some(pattern => secondPart.includes(pattern))) {
        return {
          subdomain,
          fullHostname,
          isTestMode: false
        };
      }
      // Otherwise, it's likely a root domain (e.g., example.com)
      return {
        subdomain: null,
        fullHostname,
        isTestMode: false
      };
    }
    
    // For 3+ part domains, first part is the subdomain
    return {
      subdomain,
      fullHostname,
      isTestMode: false
    };
  }
  
  // No subdomain detected
  return {
    subdomain: null,
    fullHostname,
    isTestMode: false
  };
}

/**
 * Validates if a subdomain string is valid
 * - Allows 2-63 characters (to support 2-letter tenants)
 * - Only lowercase letters, numbers, and hyphens
 * - Cannot start or end with hyphen
 */
export function isValidSubdomain(subdomain: string | null): boolean {
  if (!subdomain) return false;
  
  // Subdomain validation rules (relaxed to allow 2-char subdomains)
  const subdomainRegex = /^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$/;
  return subdomainRegex.test(subdomain);
}
