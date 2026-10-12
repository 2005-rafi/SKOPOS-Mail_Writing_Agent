# SKOPOS — Controlled AI Writing Agent

> **Root Etymology:** Greek *skopos* (aim, designated target, goal). Aligns with goal-oriented prompting where the AI focuses entirely on the user's intent without requiring repeated preference configuration.

SKOPOS is a production-grade, goal-oriented email and letter writing agent. Users configure writing preferences once (tone, language, structure, style, max length) and subsequently provide only the scenario or problem intent.

---

## Architecture Overview

```text
Skopos/
├── backend/                  # Stateless Python FastAPI backend (Render.com ready)
│   ├── app/
│   │   ├── api/v1/           # API routes (health, config, generate, rewrite, refine, usage)
│   │   ├── agent/            # PromptBuilder, Validator, RepairEngine, Orchestrator
│   │   ├── core/             # Config, security, errors, logging, rate limiting, constants
│   │   ├── middleware/       # Request ID, error handler, auth
│   │   ├── providers/        # LLMProvider abstraction (Groq, Gemini, Mock)
│   │   ├── schemas/          # Pydantic request/response models
│   │   ├── services/         # Domain services
│   │   └── utils/            # Text & latency utilities
│   ├── tests/                # Automated pytest suite (29 tests)
│   ├── requirements.txt
│   ├── Dockerfile
│   └── render.yaml           # Deployment blueprint for Render.com
├── frontend-flutter/         # Cross-platform Flutter mobile client (Offline-First)
│   ├── lib/
│   │   ├── app/              # Router, dependency injection container
│   │   ├── core/             # Design tokens, themes, storage, HTTP client
│   │   ├── features/         # Compose, Rewrite, History, Settings
│   │   └── shared/           # Reusable minimalist widgets & brand logo
│   └── test/                 # Automated Flutter test suite (30 tests)
├── frontend/
│   └── html-mvp/             # Lightweight HTML/CSS/JS test client
├── scripts/                  # Safe start.bat & stop.bat server lifecycle management
├── .gitignore
└── README.md
```

---

## Core Engineering Principles

1. **Stateless Backend**: The server does NOT persist user API keys, documents, prompts, or personal history.
2. **User-Owned Credentials**: Groq and Gemini API keys are supplied per-request from client-side storage.
3. **Controlled Generation Pipeline**: Prompt Construction $\rightarrow$ Generation $\rightarrow$ Deterministic Validation $\rightarrow$ Semantic Validation $\rightarrow$ Max 1 Repair Attempt $\rightarrow$ Structured Output.
4. **Decoupled Architecture**: `frontend/html-mvp` serves as the testbed for backend stabilization. It can be independently replaced by the Flutter mobile client without changing backend contracts.
5. **No Magic Numbers**: All configuration, endpoints, error codes, limits, and styling tokens are managed in central registries.

---

### 1. Start Both Servers (One-Click)
Run the automated Windows batch starter:
```cmd
scripts\start.bat
```
This opens dedicated terminal windows for:
- **Backend API**: `http://localhost:8000` (FastAPI / Uvicorn with auto-reload)
- **Frontend Client**: `http://localhost:3000` (HTML MVP Web Interface)

### 2. Stop Project Servers Safely
To stop **only** the SKOPOS project servers without touching any other system or background processes:
```cmd
scripts\stop.bat
```

### 3. Run Test Suite
```powershell
cd backend
pytest -v --tb=short tests/
```
