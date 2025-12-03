/**
 * Adaptive Subdomain and Query Parameter Detection Utility
 * 
 * Suporta múltiplas formas de identificar o cliente:
 * 1. Query params: ?customerId=xxx ou ?cliente=slug
 * 2. Subdomínio: tecnofibra.acelera.com
 * 
 * O branding é carregado em MEMÓRIA baseado no cliente identificado.
 */

export interface SubdomainDetectionResult {
  subdomain: string | null;
  customerId: string | null;
  clienteSlug: string | null;
  fullHostname: string;
  source: 'query_param_id' | 'query_param_slug' | 'subdomain' | 'none';
}

/**
 * Detecta cliente via query params ou subdomínio
 * 
 * Prioridade:
 * 1. ?customerId=uuid → Busca cliente por ID
 * 2. ?cliente=slug → Busca cliente por slug/subdomain
 * 3. Subdomínio do hostname → Busca cliente por subdomain
 * 
 * Os dados são carregados em MEMÓRIA (React state), não localStorage
 */
export function detectSubdomain(): SubdomainDetectionResult {
  const fullHostname = window.location.hostname;
  const urlParams = new URLSearchParams(window.location.search);
  
  // 1. Verificar query param ?customerId=uuid
  const customerId = urlParams.get('customerId');
  if (customerId && customerId.trim()) {
    console.log('[SUBDOMAIN] 🔍 Query param customerId detectado:', customerId);
    return {
      subdomain: null,
      customerId: customerId.trim(),
      clienteSlug: null,
      fullHostname,
      source: 'query_param_id'
    };
  }
  
  // 2. Verificar query param ?cliente=slug
  const clienteSlug = urlParams.get('cliente');
  if (clienteSlug && clienteSlug.trim()) {
    const normalized = clienteSlug.toLowerCase().trim();
    console.log('[SUBDOMAIN] 🔍 Query param cliente detectado:', normalized);
    return {
      subdomain: normalized,
      customerId: null,
      clienteSlug: normalized,
      fullHostname,
      source: 'query_param_slug'
    };
  }
  
  // 3. Detectar subdomínio do hostname
  // Handle special cases
  if (fullHostname === 'localhost' || fullHostname === '127.0.0.1') {
    return {
      subdomain: null,
      customerId: null,
      clienteSlug: null,
      fullHostname,
      source: 'none'
    };
  }
  
  // Extract subdomain adaptively from hostname
  const parts = fullHostname.split('.');
  
  if (parts.length >= 2) {
    const subdomain = parts[0].toLowerCase();
    
    // Filter out common non-subdomain prefixes
    if (subdomain === 'www') {
      return {
        subdomain: null,
        customerId: null,
        clienteSlug: null,
        fullHostname,
        source: 'none'
      };
    }
    
    // For 2-part domains, check if it's a known development pattern
    if (parts.length === 2) {
      const secondPart = parts[1].toLowerCase();
      if (['localhost', 'vercel', 'app', 'dev', 'ngrok'].some(pattern => secondPart.includes(pattern))) {
        console.log('[SUBDOMAIN] 🌐 Subdomínio detectado do hostname:', subdomain);
        return {
          subdomain,
          customerId: null,
          clienteSlug: null,
          fullHostname,
          source: 'subdomain'
        };
      }
      return {
        subdomain: null,
        customerId: null,
        clienteSlug: null,
        fullHostname,
        source: 'none'
      };
    }
    
    // For 3+ part domains, first part is the subdomain
    console.log('[SUBDOMAIN] 🌐 Subdomínio detectado do hostname:', subdomain);
    return {
      subdomain,
      customerId: null,
      clienteSlug: null,
      fullHostname,
      source: 'subdomain'
    };
  }
  
  // No client identifier found
  return {
    subdomain: null,
    customerId: null,
    clienteSlug: null,
    fullHostname,
    source: 'none'
  };
}

/**
 * Validates if a subdomain/slug string is valid
 * - Allows 2-63 characters
 * - Only lowercase letters, numbers, and hyphens
 * - Cannot start or end with hyphen
 */
export function isValidSubdomain(subdomain: string | null): boolean {
  if (!subdomain) return false;
  const subdomainRegex = /^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$/;
  return subdomainRegex.test(subdomain);
}

/**
 * Validates if a string is a valid UUID
 */
export function isValidUUID(id: string | null): boolean {
  if (!id) return false;
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  return uuidRegex.test(id);
}
