/**
 * SKOPOS Frontend Configuration
 * Centralized API endpoints, storage keys, and system constants.
 * Never scatter raw URL paths across UI components.
 */

const AppConfig = {
  // Base API configuration
  DEFAULT_API_BASE_URL: "http://localhost:8000/api/v1",

  // Endpoints registry
  ENDPOINTS: {
    HEALTH: "/health",
    CONFIG: "/config",
    GENERATE: "/generate",
    REWRITE: "/rewrite",
    REFINE: "/refine",
    USAGE: "/provider/usage",
    MODELS: "/provider/models",
  },

  // LocalStorage keys
  STORAGE_KEYS: {
    API_BASE_URL: "skopos_api_base_url",
    GROQ_API_KEY: "skopos_groq_key",
    GEMINI_API_KEY: "skopos_gemini_key",
    SAVED_SETTINGS: "skopos_user_settings",
    LOCAL_HISTORY: "skopos_local_history",
    ACTIVE_PROVIDER: "skopos_active_provider",
  },

  // Default generation settings
  DEFAULT_SETTINGS: {
    tone: "professional",
    style: "concise",
    language: "English",
    contentType: "email",
    subjectEnabled: true,
    salutationEnabled: true,
    closingEnabled: true,
    maxWords: 100,
    temperature: 0.7,
  },

  // Available models registry
  DEFAULT_MODELS: {
    groq: [
      { id: "llama-3.1-8b-instant", label: "Llama 3.1 8B Instant (Ultra-fast, Recommended)" },
      { id: "llama-3.3-70b-versatile", label: "Llama 3.3 70B Versatile" },
      { id: "llama3-70b-8192", label: "Llama 3 70B" },
      { id: "llama3-8b-8192", label: "Llama 3 8B" },
      { id: "mixtral-8x7b-32768", label: "Mixtral 8x7B" },
      { id: "gemma2-9b-it", label: "Gemma 2 9B" },
    ],
    gemini: [
      { id: "gemini-1.5-flash", label: "Gemini 1.5 Flash (Fast, Recommended)" },
      { id: "gemini-2.0-flash", label: "Gemini 2.0 Flash" },
      { id: "gemini-1.5-pro", label: "Gemini 1.5 Pro" },
    ],
    mock: [
      { id: "mock-model-v1", label: "Deterministic Mock V1 (Offline)" },
    ],
  },

  // Get active API base URL from storage or fallback to default
  getApiBaseUrl() {
    return localStorage.getItem(this.STORAGE_KEYS.API_BASE_URL) || this.DEFAULT_API_BASE_URL;
  },

  // Build full endpoint URL
  buildUrl(endpointKey) {
    const base = this.getApiBaseUrl().replace(/\/+$/, "");
    const path = this.ENDPOINTS[endpointKey] || "";
    return `${base}${path}`;
  },
};
