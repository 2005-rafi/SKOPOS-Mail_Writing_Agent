/**
 * SKOPOS Application Controller
 * Handles UI interactions, tab switching, generation orchestration, and local history.
 */

document.addEventListener("DOMContentLoaded", () => {
  App.init();
});

const App = {
  activeTab: "write",
  currentOutput: null,
  currentType: "email",

  init() {
    this.bindElements();
    this.loadSettings();
    this.bindEvents();
    this.renderHistory();
    this.checkBackendHealth();
  },

  bindElements() {
    // Navigation Tabs
    this.tabBtns = document.querySelectorAll(".tab-btn");
    this.tabPanes = document.querySelectorAll(".tab-pane");

    // Status Pill
    this.backendStatusPill = document.getElementById("backendStatusPill");
    this.backendStatusText = document.getElementById("backendStatusText");

    // Write Form
    this.scenarioInput = document.getElementById("scenarioInput");
    this.providerSelect = document.getElementById("providerSelect");
    this.modelSelect = document.getElementById("modelSelect");
    this.modelRefreshBtn = document.getElementById("modelRefreshBtn");
    this.contentTypeSelect = document.getElementById("contentTypeSelect");
    this.toneSelect = document.getElementById("toneSelect");
    this.styleSelect = document.getElementById("styleSelect");
    this.languageSelect = document.getElementById("languageSelect");
    this.maxWordsSlider = document.getElementById("maxWordsSlider");
    this.maxWordsVal = document.getElementById("maxWordsVal");
    this.subjectCheck = document.getElementById("subjectCheck");
    this.salutationCheck = document.getElementById("salutationCheck");
    this.closingCheck = document.getElementById("closingCheck");
    this.generateBtn = document.getElementById("generateBtn");

    // Rewrite Form
    this.rewriteContentInput = document.getElementById("rewriteContentInput");
    this.rewriteInstructionInput = document.getElementById("rewriteInstructionInput");
    this.rewriteBtn = document.getElementById("rewriteBtn");

    // Output & Viewer
    this.outputContainer = document.getElementById("outputContainer");
    this.emptyState = document.getElementById("emptyState");
    this.docSubjectWrapper = document.getElementById("docSubjectWrapper");
    this.docSubject = document.getElementById("docSubject");
    this.docSalutation = document.getElementById("docSalutation");
    this.docBody = document.getElementById("docBody");
    this.docClosing = document.getElementById("docClosing");
    this.metaProviderBadge = document.getElementById("metaProviderBadge");
    this.metaWordCountBadge = document.getElementById("metaWordCountBadge");
    this.metaValidationBadge = document.getElementById("metaValidationBadge");

    // Refinement Controls
    this.refinementBox = document.getElementById("refinementBox");
    this.refineInstructionInput = document.getElementById("refineInstructionInput");
    this.refineBtn = document.getElementById("refineBtn");

    // Copy Buttons
    this.copyAllBtn = document.getElementById("copyAllBtn");
    this.copySubjectBtn = document.getElementById("copySubjectBtn");
    this.copyBodyBtn = document.getElementById("copyBodyBtn");

    // History Elements
    this.historyList = document.getElementById("historyList");
    this.historySearchInput = document.getElementById("historySearchInput");
    this.clearHistoryBtn = document.getElementById("clearHistoryBtn");

    // Settings Elements
    this.groqKeyInput = document.getElementById("groqKeyInput");
    this.geminiKeyInput = document.getElementById("geminiKeyInput");
    this.apiBaseUrlInput = document.getElementById("apiBaseUrlInput");
    this.saveSettingsBtn = document.getElementById("saveSettingsBtn");
  },

  bindEvents() {
    // Tab Switching
    this.tabBtns.forEach((btn) => {
      btn.addEventListener("click", () => {
        const targetTab = btn.getAttribute("data-tab");
        this.switchTab(targetTab);
      });
    });

    // Max Words Slider Sync
    this.maxWordsSlider.addEventListener("input", (e) => {
      this.maxWordsVal.textContent = `${e.target.value} words`;
    });

    // Provider & Model Selectors
    if (this.providerSelect) {
      this.providerSelect.addEventListener("change", (e) => {
        StorageManager.setActiveProvider(e.target.value);
        this.fetchDynamicModels(e.target.value);
      });
    }
    if (this.modelSelect) {
      this.modelSelect.addEventListener("change", (e) => {
        StorageManager.setSelectedModel(this.providerSelect.value, e.target.value);
      });
    }
    if (this.modelRefreshBtn) {
      this.modelRefreshBtn.addEventListener("click", () => {
        this.fetchDynamicModels(this.providerSelect.value, true);
      });
    }

    // Form Submissions
    this.generateBtn.addEventListener("click", () => this.handleGenerate());
    this.rewriteBtn.addEventListener("click", () => this.handleRewrite());
    this.refineBtn.addEventListener("click", () => this.handleRefine());

    // Copy Handlers
    this.copyAllBtn.addEventListener("click", () => this.copyToClipboard("all"));
    if (this.copySubjectBtn) {
      this.copySubjectBtn.addEventListener("click", () => this.copyToClipboard("subject"));
    }
    this.copyBodyBtn.addEventListener("click", () => this.copyToClipboard("body"));

    // History Search & Clear
    this.historySearchInput.addEventListener("input", (e) => this.filterHistory(e.target.value));
    this.clearHistoryBtn.addEventListener("click", () => {
      if (confirm("Are you sure you want to clear your local history?")) {
        StorageManager.clearHistory();
        this.renderHistory();
        this.showToast("Local history cleared.");
      }
    });

    // Save Settings
    this.saveSettingsBtn.addEventListener("click", () => this.saveSettingsHandler());
  },

  switchTab(tabName) {
    this.activeTab = tabName;
    this.tabBtns.forEach((btn) => {
      btn.classList.toggle("active", btn.getAttribute("data-tab") === tabName);
    });
    this.tabPanes.forEach((pane) => {
      pane.style.display = pane.id === `tab-${tabName}` ? "block" : "none";
    });

    if (tabName === "history") {
      this.renderHistory();
    }
  },

  loadSettings() {
    const settings = StorageManager.getSettings();
    this.toneSelect.value = settings.tone;
    this.styleSelect.value = settings.style;
    this.languageSelect.value = settings.language;
    this.contentTypeSelect.value = settings.contentType;
    this.maxWordsSlider.value = settings.maxWords;
    this.maxWordsVal.textContent = `${settings.maxWords} words`;
    this.subjectCheck.checked = settings.subjectEnabled;
    this.salutationCheck.checked = settings.salutationEnabled;
    this.closingCheck.checked = settings.closingEnabled;

    const activeProvider = StorageManager.getActiveProvider();
    this.providerSelect.value = activeProvider;
    this.fetchDynamicModels(activeProvider);

    // Load Settings Tab Fields
    this.groqKeyInput.value = StorageManager.getApiKey("groq");
    this.geminiKeyInput.value = StorageManager.getApiKey("gemini");
    this.apiBaseUrlInput.value = AppConfig.getApiBaseUrl();
  },

  async fetchDynamicModels(provider, showToastFeedback = false) {
    if (!this.modelSelect) return;
    const apiKey = StorageManager.getApiKey(provider);

    try {
      if (this.modelRefreshBtn) {
        this.modelRefreshBtn.textContent = "⏳...";
      }

      const res = await ApiClient.getProviderModels(provider, apiKey);
      if (res && res.success && res.models && res.models.length > 0) {
        this.modelSelect.innerHTML = "";
        const savedModel = StorageManager.getSelectedModel(provider);

        res.models.forEach((m, idx) => {
          const opt = document.createElement("option");
          opt.value = m.id;
          opt.textContent = m.label;
          if (savedModel ? m.id === savedModel : (m.id === res.defaultModel || idx === 0)) {
            opt.selected = true;
          }
          this.modelSelect.appendChild(opt);
        });

        StorageManager.setSelectedModel(provider, this.modelSelect.value);

        if (showToastFeedback) {
          const modeStr = res.isLive ? "Live from API Key" : "Default Free Tier";
          this.showToast(`Models synchronized (${modeStr}): ${res.models.length} available.`);
        }
        return;
      }
    } catch (e) {
      console.warn("Failed to query dynamic models from backend:", e);
    } finally {
      if (this.modelRefreshBtn) {
        this.modelRefreshBtn.textContent = "🔄 Live Sync";
      }
    }

    // Static fallback
    this.updateModelOptions(provider);
  },

  updateModelOptions(provider) {
    if (!this.modelSelect) return;
    const models = AppConfig.DEFAULT_MODELS[provider] || [];
    this.modelSelect.innerHTML = "";
    const savedModel = StorageManager.getSelectedModel(provider);

    models.forEach((m, idx) => {
      const opt = document.createElement("option");
      opt.value = m.id;
      opt.textContent = m.label;
      if (savedModel ? m.id === savedModel : idx === 0) {
        opt.selected = true;
      }
      this.modelSelect.appendChild(opt);
    });
  },

  getFormSettings() {
    return {
      tone: this.toneSelect.value,
      style: this.styleSelect.value,
      language: this.languageSelect.value,
      contentType: this.contentTypeSelect.value,
      maxWords: parseInt(this.maxWordsSlider.value, 10),
      subjectEnabled: this.subjectCheck.checked,
      salutationEnabled: this.salutationCheck.checked,
      closingEnabled: this.closingCheck.checked,
      temperature: 0.7,
    };
  },

  async checkBackendHealth() {
    try {
      const res = await ApiClient.getHealth();
      if (res && res.status === "healthy") {
        this.backendStatusText.textContent = "Backend Connected";
        this.backendStatusPill.style.borderColor = "var(--color-success)";

        // Synchronize available models from live backend configuration
        try {
          const config = await ApiClient.getConfig();
          if (config && config.modelsByProvider) {
            Object.entries(config.modelsByProvider).forEach(([prov, modelList]) => {
              AppConfig.DEFAULT_MODELS[prov] = modelList.map((m) => ({
                id: m,
                label: m,
              }));
            });
            this.updateModelOptions(this.providerSelect.value);
          }
        } catch (_) {}
      }
    } catch (e) {
      this.backendStatusText.textContent = "Offline / Disconnected";
      this.backendStatusPill.style.borderColor = "var(--color-error)";
    }
  },

  async handleGenerate() {
    const scenario = (this.scenarioInput.value || "").trim();
    if (!scenario || scenario.length < 5) {
      this.showToast("Please enter a scenario description (at least 5 characters).", "error");
      return;
    }

    const provider = this.providerSelect.value;
    const model = this.modelSelect ? this.modelSelect.value : undefined;
    const apiKey = StorageManager.getApiKey(provider);

    if (provider !== "mock" && !apiKey) {
      this.showToast(`Please enter your ${provider.toUpperCase()} API key in Settings.`, "error");
      this.switchTab("settings");
      return;
    }

    const settings = this.getFormSettings();
    StorageManager.saveSettings(settings);
    StorageManager.setActiveProvider(provider);
    if (model) {
      StorageManager.setSelectedModel(provider, model);
    }

    this.setLoading(this.generateBtn, true, "Writing...");

    try {
      const response = await ApiClient.generate({
        scenario,
        contentType: settings.contentType,
        settings,
        provider,
        model,
        apiKey,
      });

      this.displayOutput(response);
      StorageManager.addHistoryItem(response);
      this.showToast("Generated successfully!");
    } catch (err) {
      this.showErrorBanner(err);
    } finally {
      this.setLoading(this.generateBtn, false, "Generate Communication");
    }
  },

  async handleRewrite() {
    const existingContent = (this.rewriteContentInput.value || "").trim();
    if (!existingContent || existingContent.length < 5) {
      this.showToast("Please provide content to rewrite (at least 5 characters).", "error");
      return;
    }

    const provider = this.providerSelect.value;
    const model = this.modelSelect ? this.modelSelect.value : undefined;
    const apiKey = StorageManager.getApiKey(provider);

    if (provider !== "mock" && !apiKey) {
      this.showToast(`Please enter your ${provider.toUpperCase()} API key in Settings.`, "error");
      this.switchTab("settings");
      return;
    }

    const settings = this.getFormSettings();
    const instruction = (this.rewriteInstructionInput.value || "").trim() || null;

    this.setLoading(this.rewriteBtn, true, "Rewriting...");

    try {
      const response = await ApiClient.rewrite({
        existingContent,
        instruction,
        contentType: settings.contentType,
        settings,
        provider,
        model,
        apiKey,
      });

      this.displayOutput(response);
      StorageManager.addHistoryItem(response);
      this.showToast("Rewritten successfully!");
    } catch (err) {
      this.showErrorBanner(err);
    } finally {
      this.setLoading(this.rewriteBtn, false, "Rewrite Draft");
    }
  },

  async handleRefine() {
    if (!this.currentOutput) {
      this.showToast("No active communication to refine.", "error");
      return;
    }

    const instruction = (this.refineInstructionInput.value || "").trim();
    if (!instruction || instruction.length < 2) {
      this.showToast("Please enter a refinement instruction.", "error");
      return;
    }

    const provider = this.providerSelect.value;
    const model = this.modelSelect ? this.modelSelect.value : undefined;
    const apiKey = StorageManager.getApiKey(provider);

    if (provider !== "mock" && !apiKey) {
      this.showToast(`Please enter your ${provider.toUpperCase()} API key in Settings.`, "error");
      return;
    }

    const settings = this.getFormSettings();
    this.setLoading(this.refineBtn, true, "Refining...");

    try {
      const response = await ApiClient.refine({
        previousOutput: this.currentOutput,
        instruction,
        contentType: settings.contentType,
        settings,
        provider,
        model,
        apiKey,
      });

      this.displayOutput(response);
      StorageManager.addHistoryItem(response);
      this.refineInstructionInput.value = "";
      this.showToast("Refined successfully!");
    } catch (err) {
      this.showErrorBanner(err);
    } finally {
      this.setLoading(this.refineBtn, false, "Refine");
    }
  },

  displayOutput(result) {
    this.currentOutput = result.output;
    this.currentType = result.type || "email";

    this.emptyState.style.display = "none";
    this.outputContainer.style.display = "flex";

    // Populate Fields with Rich Markdown & Component Rendering
    if (result.output.subject) {
      this.docSubjectWrapper.style.display = "flex";
      this.docSubject.textContent = MarkdownRenderer.toPlainText(result.output.subject);
    } else {
      this.docSubjectWrapper.style.display = "none";
    }

    if (result.output.salutation) {
      this.docSalutation.style.display = "block";
      this.docSalutation.innerHTML = MarkdownRenderer.render(result.output.salutation);
    } else {
      this.docSalutation.style.display = "none";
    }

    this.docBody.innerHTML = MarkdownRenderer.render(result.output.body || "");

    if (result.output.closing) {
      this.docClosing.style.display = "block";
      this.docClosing.innerHTML = MarkdownRenderer.render(result.output.closing);
    } else {
      this.docClosing.style.display = "none";
    }

    // Metadata Badges
    this.metaProviderBadge.textContent = `${(result.provider || "").toUpperCase()} • ${result.model || ""}`;
    this.metaWordCountBadge.textContent = `${result.wordCount || 0} words`;

    if (result.validation?.repaired) {
      this.metaValidationBadge.className = "badge badge-warning";
      this.metaValidationBadge.textContent = "Repaired (1 Pass)";
    } else {
      this.metaValidationBadge.className = "badge badge-success";
      this.metaValidationBadge.textContent = "Validated";
    }

    // Show Refinement Box
    this.refinementBox.style.display = "block";
  },

  saveSettingsHandler() {
    StorageManager.setApiKey("groq", this.groqKeyInput.value);
    StorageManager.setApiKey("gemini", this.geminiKeyInput.value);

    const customUrl = (this.apiBaseUrlInput.value || "").trim();
    if (customUrl) {
      localStorage.setItem(AppConfig.STORAGE_KEYS.API_BASE_URL, customUrl);
    }

    this.showToast("Credentials and settings saved locally.");
    this.checkBackendHealth();
    this.fetchDynamicModels(this.providerSelect.value, true);
  },

  renderHistory(items = null) {
    const history = items || StorageManager.getHistory();
    this.historyList.innerHTML = "";

    if (!history || history.length === 0) {
      this.historyList.innerHTML = `
        <div class="empty-state">
          <p>No writing history found locally.</p>
        </div>
      `;
      return;
    }

    history.forEach((item) => {
      const card = document.createElement("div");
      card.className = "history-item";

      const dateStr = item.createdAt ? new Date(item.createdAt).toLocaleString() : "Recent";
      const subject = item.output?.subject || "(No Subject)";
      const bodySnippet = item.output?.body || "";

      card.innerHTML = `
        <div class="history-header">
          <span>${(item.provider || "ai").toUpperCase()} • ${(item.type || "email").toUpperCase()}</span>
          <span>${dateStr}</span>
        </div>
        <div class="history-title">${this.escapeHtml(subject)}</div>
        <div class="history-snippet">${this.escapeHtml(bodySnippet)}</div>
      `;

      card.addEventListener("click", () => {
        this.displayOutput(item);
        this.switchTab("write");
        this.showToast("Loaded historical document.");
      });

      this.historyList.appendChild(card);
    });
  },

  filterHistory(query) {
    const q = (query || "").toLowerCase().trim();
    if (!q) {
      this.renderHistory();
      return;
    }

    const all = StorageManager.getHistory();
    const filtered = all.filter((item) => {
      const subj = (item.output?.subject || "").toLowerCase();
      const body = (item.output?.body || "").toLowerCase();
      const prov = (item.provider || "").toLowerCase();
      return subj.includes(q) || body.includes(q) || prov.includes(q);
    });

    this.renderHistory(filtered);
  },

  copyToClipboard(target) {
    if (!this.currentOutput) return;

    let textToCopy = "";
    if (target === "subject") {
      textToCopy = MarkdownRenderer.toPlainText(this.currentOutput.subject || "");
    } else if (target === "body") {
      textToCopy = MarkdownRenderer.toPlainText(this.currentOutput.body || "");
    } else if (target === "all") {
      const parts = [];
      if (this.currentOutput.subject) {
        parts.push(`Subject: ${MarkdownRenderer.toPlainText(this.currentOutput.subject)}\n`);
      }
      if (this.currentOutput.salutation) {
        parts.push(`${MarkdownRenderer.toPlainText(this.currentOutput.salutation)}\n`);
      }
      if (this.currentOutput.body) {
        parts.push(`${MarkdownRenderer.toPlainText(this.currentOutput.body)}\n`);
      }
      if (this.currentOutput.closing) {
        parts.push(`${MarkdownRenderer.toPlainText(this.currentOutput.closing)}`);
      }
      textToCopy = parts.join("\n").trim();
    }

    navigator.clipboard.writeText(textToCopy).then(() => {
      this.showToast(`Copied ${target} to clipboard!`);
    }).catch(() => {
      this.showToast("Failed to copy to clipboard.", "error");
    });
  },

  setLoading(btn, isLoading, text) {
    btn.disabled = isLoading;
    if (isLoading) {
      btn.innerHTML = `<span class="spinner"></span> ${text}`;
    } else {
      btn.innerHTML = text;
    }
  },

  showErrorBanner(err) {
    const msg = err.message || "An unexpected error occurred.";
    const ref = err.requestId && err.requestId !== "none" ? ` (Ref: ${err.requestId})` : "";
    this.showToast(`${msg}${ref}`, "error");
  },

  showToast(message, type = "success") {
    let container = document.querySelector(".toast-container");
    if (!container) {
      container = document.createElement("div");
      container.className = "toast-container";
      document.body.appendChild(container);
    }

    const toast = document.createElement("div");
    toast.className = "toast";
    if (type === "error") {
      toast.style.borderColor = "rgba(239, 68, 68, 0.4)";
      toast.style.background = "#1e1520";
    }

    toast.textContent = message;
    container.appendChild(toast);

    setTimeout(() => {
      toast.remove();
    }, 4000);
  },

  escapeHtml(str) {
    if (!str) return "";
    return str
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;");
  },
};
