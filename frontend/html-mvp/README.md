# SKOPOS HTML MVP Client

## Overview
The HTML MVP client is a lightweight, responsive, accessible web interface for end-to-end testing and validation of the SKOPOS backend API.

## Features
- **Goal-Oriented Writing**: Input a scenario and receive fully structured communication (`subject`, `salutation`, `body`, `closing`).
- **Rewrite Mode**: Polish existing rough drafts according to tone, language, and length settings.
- **Conversational Refinement**: Targeted iterative modifications on the generated draft without full regeneration.
- **Provider Switching**: Seamless toggle between Groq Cloud (Llama 3.3), Google Gemini (Gemini 2.5 Flash), and Mock Engine.
- **Client-Side Key Protection**: API keys are stored in browser `localStorage` and sent per-request; never persisted on the backend.
- **Offline History**: Generated documents are preserved locally for offline reading and instant search.

## Running the MVP
1. Ensure the Python backend is running:
   ```bash
   cd ../../backend
   uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```
2. Open `index.html` directly in your browser or serve it via any static web server:
   ```bash
   # Using Python's built-in HTTP server:
   python -m http.server 3000
   ```
3. Open `http://localhost:3000` in your web browser.

## Removal Notice
Per PRD Section 53, this directory is self-contained. When transitioning to the production Flutter client, this folder can be safely removed or kept for automated web testing without impacting backend contracts.
