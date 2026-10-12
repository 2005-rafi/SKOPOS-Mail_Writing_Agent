/**
 * SKOPOS Centralized API Client
 * Wraps fetch calls with timeouts, request IDs, error mapping, and network handling.
 */

class ApiClient {
  static async request(endpointKey, options = {}) {
    const url = AppConfig.buildUrl(endpointKey);
    const timeoutMs = options.timeoutMs || 30000;

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

    const headers = {
      "Content-Type": "application/json",
      ...(options.headers || {}),
    };

    try {
      const response = await fetch(url, {
        method: options.method || "GET",
        headers,
        body: options.body ? JSON.stringify(options.body) : undefined,
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      const data = await response.json().catch(() => null);

      if (!response.ok) {
        // Parse structured backend error response
        const errorCode = data?.error?.code || "UNKNOWN_ERROR";
        const errorMessage = data?.error?.message || response.statusText || "Request failed.";
        const requestId = data?.error?.requestId || response.headers.get("X-Request-ID") || "none";

        throw {
          status: response.status,
          code: errorCode,
          message: errorMessage,
          requestId,
        };
      }

      return data;
    } catch (err) {
      clearTimeout(timeoutId);

      if (err.name === "AbortError") {
        throw {
          status: 408,
          code: "TIMEOUT",
          message: "Request timed out. The AI provider took too long to respond.",
          requestId: "none",
        };
      }

      // If already a normalized error object
      if (err.code) {
        throw err;
      }

      // Network disconnect or server down
      throw {
        status: 0,
        code: "NETWORK_ERROR",
        message: "Unable to reach SKOPOS backend. Check your local server connection.",
        requestId: "none",
      };
    }
  }

  static async getHealth() {
    return this.request("HEALTH");
  }

  static async getConfig() {
    return this.request("CONFIG");
  }

  static async generate(payload) {
    return this.request("GENERATE", {
      method: "POST",
      body: payload,
    });
  }

  static async rewrite(payload) {
    return this.request("REWRITE", {
      method: "POST",
      body: payload,
    });
  }

  static async refine(payload) {
    return this.request("REFINE", {
      method: "POST",
      body: payload,
    });
  }

  static async getProviderUsage(provider, apiKey) {
    return this.request("USAGE", {
      method: "POST",
      body: { provider, apiKey },
    });
  }

  static async getProviderModels(provider, apiKey) {
    return this.request("MODELS", {
      method: "POST",
      body: { provider, apiKey: apiKey || null },
    });
  }
}
