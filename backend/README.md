# SKOPOS Backend

Stateless, production-ready FastAPI backend for the SKOPOS AI Writing Engine.

## Architectural Highlights
- **Stateless Operation**: Never persists user prompts, generated documents, or API keys to a server-side database.
- **Controlled Generation Pipeline**: Prompt Construction $\rightarrow$ LLM Generation $\rightarrow$ Deterministic Validation $\rightarrow$ Semantic Validation $\rightarrow$ Single-pass Repair $\rightarrow$ Final Structured Output.
- **Provider Abstraction**: Extensible `LLMProvider` interface with support for Groq Cloud, Google Gemini, and a deterministic `MockLLMProvider`.
- **Render Free-Tier Optimization**: Ultra-lightweight footprint, strict timeouts, in-memory sliding-window rate limiting, and zero background worker overhead.
- **Standardized Error Contracts**: Uniform `{ success: false, error: { code, message, requestId } }` responses.

## Setup & Local Development

### 1. Initialize Virtual Environment
Per project rules, dependencies must be managed inside a virtual environment:
```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
uv pip install -r requirements.txt
```

### 2. Configure Environment Variables
Copy `.env.example` to `.env`:
```powershell
cp .env.example .env
```

### 3. Run Development Server
```powershell
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
Interactive API documentation will be available at:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Running Automated Tests
```powershell
pytest -v --tb=short tests/
```

## API Endpoints
All routes are prefixed with `/api/v1`:
- `GET  /api/v1/health` — Service health check & uptime probe
- `GET  /api/v1/config` — Public capabilities and supported providers/models
- `POST /api/v1/generate` — Generate email or letter from scenario
- `POST /api/v1/rewrite` — Polish rough drafts according to preferences
- `POST /api/v1/refine` — Conversational modification of previous draft
- `POST /api/v1/provider/usage` — Check provider-reported quota/usage
