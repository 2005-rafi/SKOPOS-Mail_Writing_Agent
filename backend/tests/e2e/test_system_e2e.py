"""Comprehensive End-to-End Playwright Browser Tests for SKOPOS.

Verifies the entire system:
1. Backend API (FastAPI)
2. Frontend HTML MVP Interface
3. Generation, Refinement, Rewrite, Local History, and Viewport Responsiveness
"""

import http.server
import socketserver
import threading
import time
from pathlib import Path
import httpx
import pytest
from playwright.sync_api import sync_playwright
import uvicorn
from app.main import app

BACKEND_PORT = 8000
FRONTEND_PORT = 3000
FRONTEND_DIR = Path(__file__).resolve().parent.parent.parent.parent / "frontend" / "html-mvp"


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    """Static file handler with quiet logging."""
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(FRONTEND_DIR), **kwargs)

    def log_message(self, format, *args):
        pass  # Suppress standard logging during tests


@pytest.fixture(scope="module")
def run_servers():
    """Start backend and frontend HTTP servers in background threads."""
    # 1. Start Backend Server
    config = uvicorn.Config(app, host="127.0.0.1", port=BACKEND_PORT, log_level="warning")
    backend_server = uvicorn.Server(config)
    backend_thread = threading.Thread(target=backend_server.run, daemon=True)
    backend_thread.start()

    # 2. Start Frontend Static Server
    frontend_httpd = socketserver.TCPServer(("127.0.0.1", FRONTEND_PORT), QuietHandler)
    frontend_thread = threading.Thread(target=frontend_httpd.serve_forever, daemon=True)
    frontend_thread.start()

    # 3. Wait for both servers to be responsive
    backend_ready = False
    frontend_ready = False
    for _ in range(30):
        try:
            if not backend_ready:
                res = httpx.get(f"http://127.0.0.1:{BACKEND_PORT}/api/v1/health", timeout=1.0)
                if res.status_code == 200:
                    backend_ready = True
            if not frontend_ready:
                res = httpx.get(f"http://127.0.0.1:{FRONTEND_PORT}/index.html", timeout=1.0)
                if res.status_code == 200:
                    frontend_ready = True
            if backend_ready and frontend_ready:
                break
        except Exception:
            pass
        time.sleep(0.3)

    assert backend_ready, "Backend server failed to start within timeout"
    assert frontend_ready, "Frontend server failed to start within timeout"

    yield

    # Teardown
    backend_server.should_exit = True
    frontend_httpd.shutdown()
    frontend_httpd.server_close()


def test_full_system_e2e(run_servers):
    """Execute end-to-end user workflows using Playwright headless browser."""
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(
            viewport={"width": 1280, "height": 800},
            permissions=["clipboard-read", "clipboard-write"],
        )
        page = context.new_page()

        # Step 1: Navigate to HTML MVP Frontend
        page.goto(f"http://127.0.0.1:{FRONTEND_PORT}/index.html")
        page.wait_for_load_state("networkidle")

        # Step 2: Verify Branding & Connection Status
        assert "SKOPOS — Controlled AI Writing Agent" in page.title()
        page.wait_for_selector("#backendStatusText")
        # Give connection check a brief moment
        page.wait_for_function("document.getElementById('backendStatusText').textContent === 'Backend Connected'")
        assert page.text_content("#backendStatusText") == "Backend Connected"

        # Step 3: Select Mock Provider for Offline Deterministic Test
        page.select_option("#providerSelect", "mock")

        # Step 4: Test Generate Flow
        test_scenario = "Supplier has not delivered the ordered raw materials for one month despite purchase order #402. Request urgent delivery by Friday."
        page.fill("#scenarioInput", test_scenario)

        # Select tone and style
        page.select_option("#toneSelect", "professional")
        page.select_option("#styleSelect", "concise")

        # Click Generate
        page.click("#generateBtn")

        # Wait for output card to appear
        page.wait_for_selector("#outputContainer", state="visible", timeout=10000)

        # Verify output fields rendered
        subject_text = page.text_content("#docSubject")
        body_text = page.text_content("#docBody")
        assert len(subject_text) > 0, "Subject was not generated"
        assert len(body_text) > 0, "Body was not generated"
        # Assert no literal <br> or HTML artifacts leaked into visible text
        assert "<br>" not in body_text, "Literal <br> found in body"
        assert "<br/>" not in body_text, "Literal <br/> found in body"
        assert "<BR>" not in body_text, "Literal <BR> found in body"
        # Verify rendered markdown paragraph elements exist
        assert page.locator("#docBody p.md-para").count() > 0, "Markdown paragraphs not rendered"
        assert "MOCK" in page.text_content("#metaProviderBadge")
        assert "Validated" in page.text_content("#metaValidationBadge")

        # Step 5: Test Copy Actions
        page.click("#copyAllBtn")
        page.wait_for_selector(".toast:has-text('Copied all to clipboard!')", timeout=5000)

        # Step 6: Test Conversational Refinement Flow
        page.wait_for_selector("#refinementBox", state="visible")
        page.fill("#refineInstructionInput", "Make the deadline strictly 5 PM this Friday.")
        page.click("#refineBtn")

        # Verify refinement completes and toast displays
        page.wait_for_selector(".toast:has-text('Refined successfully!')", timeout=10000)
        assert len(page.text_content("#docBody")) > 0

        # Step 7: Test Rewrite Tab Flow
        page.click("button[data-tab='rewrite']")
        page.wait_for_selector("#tab-rewrite", state="visible")

        page.fill("#rewriteContentInput", "need the raw materials asap. why delayed for one month? send now.")
        page.fill("#rewriteInstructionInput", "Make it polite yet firm.")
        page.click("#rewriteBtn")

        # Verify output rendered
        page.wait_for_selector(".toast:has-text('Rewritten successfully!')", timeout=10000)
        assert len(page.text_content("#docBody")) > 0

        # Step 8: Test Local Offline History
        page.click("button[data-tab='history']")
        page.wait_for_selector("#tab-history", state="visible")
        page.wait_for_selector(".history-item", timeout=5000)

        history_items = page.query_selector_all(".history-item")
        assert len(history_items) >= 2, f"Expected at least 2 history items, got {len(history_items)}"

        # Test search filter in history
        page.fill("#historySearchInput", "Delayed")
        time.sleep(0.3)
        filtered_items = page.query_selector_all(".history-item")
        assert len(filtered_items) >= 1

        # Click an item to reload it
        filtered_items[0].click()
        page.wait_for_selector(".toast:has-text('Loaded historical document')", timeout=5000)

        # Step 9: Test Responsive Mobile Viewport
        page.set_viewport_size({"width": 375, "height": 667})
        time.sleep(0.3)
        # Verify navigation tabs and main grid are visible without horizontal scroll
        assert page.is_visible(".top-navbar")
        assert page.is_visible(".nav-tabs")

        browser.close()
