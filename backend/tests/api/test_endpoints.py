"""API integration tests for all /api/v1 endpoints and error scenarios."""

from starlette.testclient import TestClient


def test_health_endpoint(client: TestClient):
    # Test v1 health GET
    res = client.get("/api/v1/health")
    assert res.status_code == 200
    data = res.json()
    assert data["success"] is True
    assert data["status"] == "healthy"
    assert data["service"] == "SKOPOS"
    assert "X-Request-ID" in res.headers
    assert res.headers.get("Cache-Control") == "public, max-age=60, stale-while-revalidate=30"
    assert res.headers.get("X-Server-Status") == "active"

    # Test v1 health HEAD (used for lightweight ping by cold-start monitors)
    head_res = client.head("/api/v1/health")
    assert head_res.status_code == 200
    assert head_res.headers.get("X-Server-Status") == "active"

    # Test root /health probe (used by Render platform default probes)
    root_res = client.get("/health")
    assert root_res.status_code == 200
    assert root_res.json()["status"] == "healthy"
    assert root_res.headers.get("X-Server-Status") == "active"



def test_config_endpoint(client: TestClient):
    res = client.get("/api/v1/config")
    assert res.status_code == 200
    data = res.json()
    assert data["success"] is True
    assert "groq" in data["supportedProviders"]
    assert "gemini" in data["supportedProviders"]
    assert "mock" in data["supportedProviders"]
    assert "email" in data["supportedContentTypes"]
    assert data["defaultMaxWords"] == 100


def test_generate_endpoint_success(client: TestClient):
    payload = {
        "scenario": "Supplier has not delivered the ordered raw materials for one month.",
        "contentType": "email",
        "settings": {
            "tone": "professional",
            "style": "concise",
            "language": "English",
            "maxWords": 100,
        },
        "provider": "mock",
        "apiKey": "mock_api_key",
    }
    res = client.post("/api/v1/generate", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert data["success"] is True
    assert data["id"].startswith("gen_")
    assert data["provider"] == "mock"
    assert data["output"]["body"] != ""
    assert data["validation"]["passed"] is True
    assert "X-Request-ID" in res.headers


def test_generate_endpoint_validation_error(client: TestClient):
    # Empty scenario violates min_length=5
    payload = {
        "scenario": "Hi",
        "provider": "mock",
        "apiKey": "mock_api_key",
    }
    res = client.post("/api/v1/generate", json=payload)
    assert res.status_code == 422
    data = res.json()
    assert data["success"] is False
    assert data["error"]["code"] == "VALIDATION_FAILED"
    assert "requestId" in data["error"]


def test_generate_unsupported_provider(client: TestClient):
    payload = {
        "scenario": "Valid scenario description text.",
        "provider": "nonexistent_provider",
        "apiKey": "mock_api_key",
    }
    res = client.post("/api/v1/generate", json=payload)
    assert res.status_code == 422  # Pydantic enum validation catches unknown provider


def test_rewrite_endpoint_success(client: TestClient):
    payload = {
        "existingContent": "need the supplies soon, you didn't send them last month. please send.",
        "instruction": "Make it much more formal and firm.",
        "provider": "mock",
        "apiKey": "mock_api_key",
    }
    res = client.post("/api/v1/rewrite", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert data["success"] is True
    assert data["id"].startswith("rew_")
    assert data["output"]["body"] != ""


def test_refine_endpoint_success(client: TestClient):
    payload = {
        "previousOutput": {
            "subject": "Supply Status",
            "salutation": "Dear Sir,",
            "body": "Please deliver the materials.",
            "closing": "Thanks",
        },
        "instruction": "Set a firm deadline for this Friday at 5 PM.",
        "provider": "mock",
        "apiKey": "mock_api_key",
    }
    res = client.post("/api/v1/refine", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert data["success"] is True
    assert data["id"].startswith("ref_")
    assert data["output"]["body"] != ""


def test_provider_usage_endpoint(client: TestClient):
    payload = {
        "provider": "mock",
        "apiKey": "mock_api_key",
    }
    res = client.post("/api/v1/provider/usage", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert data["success"] is True
    assert data["supported"] is True
    assert "mockCallsExecuted" in data["reportedQuota"]


def test_provider_models_endpoint(client: TestClient):
    # Test Groq models (fallback / free tier list without live key)
    res_groq = client.post("/api/v1/provider/models", json={"provider": "groq"})
    assert res_groq.status_code == 200
    data_groq = res_groq.json()
    assert data_groq["success"] is True
    assert data_groq["provider"] == "groq"
    assert len(data_groq["models"]) > 0
    assert any(m["isFreeTierRecommended"] for m in data_groq["models"])

    # Test Gemini models
    res_gemini = client.post("/api/v1/provider/models", json={"provider": "gemini"})
    assert res_gemini.status_code == 200
    data_gemini = res_gemini.json()
    assert data_gemini["success"] is True
    assert any(m["id"] == "gemini-1.5-flash" for m in data_gemini["models"])

    # Test Mock models
    res_mock = client.post("/api/v1/provider/models", json={"provider": "mock"})
    assert res_mock.status_code == 200
    data_mock = res_mock.json()
    assert data_mock["models"][0]["id"] == "mock-model-v1"



def test_rate_limiting_enforced(client: TestClient):
    payload = {
        "scenario": "Testing rate limit threshold enforcement.",
        "provider": "mock",
        "apiKey": "mock_api_key",
    }

    # Execute 20 requests (configured limit is 20/min)
    for _ in range(20):
        res = client.post("/api/v1/generate", json=payload)
        assert res.status_code == 200

    # 21st request must trigger 429 Rate Limit Exceeded
    rate_limited_res = client.post("/api/v1/generate", json=payload)
    assert rate_limited_res.status_code == 429
    data = rate_limited_res.json()
    assert data["success"] is False
    assert data["error"]["code"] == "RATE_LIMIT_EXCEEDED"
