/**
 * SKOPOS Offline-First Local Storage Manager
 * Safely persists API keys, preferences, and generation history on client device.
 * Never leaks data to backend databases.
 */

const StorageManager = {
  // Provider API Keys
  getApiKey(provider) {
    if (provider === "groq") {
      return localStorage.getItem(AppConfig.STORAGE_KEYS.GROQ_API_KEY) || "";
    }
    if (provider === "gemini") {
      return localStorage.getItem(AppConfig.STORAGE_KEYS.GEMINI_API_KEY) || "";
    }
    if (provider === "mock") {
      return "mock_test_key";
    }
    return "";
  },

  setApiKey(provider, key) {
    if (provider === "groq") {
      localStorage.setItem(AppConfig.STORAGE_KEYS.GROQ_API_KEY, (key || "").trim());
    } else if (provider === "gemini") {
      localStorage.setItem(AppConfig.STORAGE_KEYS.GEMINI_API_KEY, (key || "").trim());
    }
  },

  // Writing Settings
  getSettings() {
    try {
      const raw = localStorage.getItem(AppConfig.STORAGE_KEYS.SAVED_SETTINGS);
      if (raw) {
        return { ...AppConfig.DEFAULT_SETTINGS, ...JSON.parse(raw) };
      }
    } catch (e) {
      console.warn("Error parsing saved settings:", e);
    }
    return { ...AppConfig.DEFAULT_SETTINGS };
  },

  saveSettings(settings) {
    try {
      localStorage.setItem(AppConfig.STORAGE_KEYS.SAVED_SETTINGS, JSON.stringify(settings));
    } catch (e) {
      console.error("Error saving settings to localStorage:", e);
    }
  },

  // Active Provider
  getActiveProvider() {
    return localStorage.getItem(AppConfig.STORAGE_KEYS.ACTIVE_PROVIDER) || "groq";
  },

  setActiveProvider(provider) {
    localStorage.setItem(AppConfig.STORAGE_KEYS.ACTIVE_PROVIDER, provider);
  },

  // Selected Models per Provider
  getSelectedModel(provider) {
    return localStorage.getItem(`skopos_model_${provider}`) || "";
  },

  setSelectedModel(provider, model) {
    if (provider && model) {
      localStorage.setItem(`skopos_model_${provider}`, model);
    }
  },

  // Offline Generation History
  getHistory() {
    try {
      const raw = localStorage.getItem(AppConfig.STORAGE_KEYS.LOCAL_HISTORY);
      if (raw) {
        return JSON.parse(raw);
      }
    } catch (e) {
      console.warn("Error parsing local history:", e);
    }
    return [];
  },

  addHistoryItem(item) {
    const list = this.getHistory();
    // Prepend latest item
    const updated = [item, ...list.slice(0, 99)]; // Keep up to 100 items locally
    try {
      localStorage.setItem(AppConfig.STORAGE_KEYS.LOCAL_HISTORY, JSON.stringify(updated));
    } catch (e) {
      console.error("Failed to persist history item locally:", e);
    }
    return updated;
  },

  deleteHistoryItem(id) {
    const list = this.getHistory();
    const updated = list.filter((i) => i.id !== id);
    localStorage.setItem(AppConfig.STORAGE_KEYS.LOCAL_HISTORY, JSON.stringify(updated));
    return updated;
  },

  clearHistory() {
    localStorage.removeItem(AppConfig.STORAGE_KEYS.LOCAL_HISTORY);
  },
};
