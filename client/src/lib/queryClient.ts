import { QueryClient, QueryFunction } from "@tanstack/react-query";

async function throwIfResNotOk(res: Response) {
  if (!res.ok) {
    const text = (await res.text()) || res.statusText;
    
    // Tentar fazer parse do JSON para extrair message e details
    try {
      const errorData = JSON.parse(text);
      const error: any = new Error(errorData.message || text);
      error.message = errorData.message || text;
      error.details = errorData.details || null;
      error.errors = errorData.errors || null;
      throw error;
    } catch (parseError) {
      // Se não for JSON válido, jogar o texto direto
      throw new Error(text);
    }
  }
}

export async function apiRequest(
  method: string,
  url: string,
  data?: unknown | undefined,
): Promise<Response> {
  // Get token from localStorage
  const token = localStorage.getItem("opus_clean_token");
  
  const headers: Record<string, string> = data ? { "Content-Type": "application/json" } : {};
  if (token) {
    headers["Authorization"] = `Bearer ${token}`;
  }
  
  const res = await fetch(url, {
    method,
    headers,
    body: data ? JSON.stringify(data) : undefined,
    credentials: "include",
  });

  await throwIfResNotOk(res);
  return res;
}

type UnauthorizedBehavior = "returnNull" | "throw";
export const getQueryFn: <T>(options: {
  on401: UnauthorizedBehavior;
}) => QueryFunction<T> =
  ({ on401: unauthorizedBehavior }) =>
  async ({ queryKey }) => {
    // Get token from localStorage
    const token = localStorage.getItem("opus_clean_token");
    
    const headers: Record<string, string> = {};
    if (token) {
      headers["Authorization"] = `Bearer ${token}`;
    }
    
    // Process queryKey to handle objects as query parameters
    let url = "";
    const queryParams: Record<string, string> = {};
    
    for (const part of queryKey) {
      if (typeof part === "object" && part !== null) {
        // Extract query parameters from object
        Object.assign(queryParams, part);
      } else {
        // Build URL path
        url += (url ? "/" : "") + part;
      }
    }
    
    // Append query parameters if any
    if (Object.keys(queryParams).length > 0) {
      const params = new URLSearchParams(queryParams);
      url += "?" + params.toString();
    }
    
    const res = await fetch(url, {
      headers,
      credentials: "include",
    });

    if (unauthorizedBehavior === "returnNull" && res.status === 401) {
      return null;
    }

    await throwIfResNotOk(res);
    return await res.json();
  };

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      queryFn: getQueryFn({ on401: "throw" }),
      refetchInterval: false,
      refetchOnWindowFocus: false,
      refetchOnMount: true,
      refetchOnReconnect: true,
      staleTime: 0,
      retry: false,
    },
    mutations: {
      retry: false,
    },
  },
});
