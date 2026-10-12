"""Pytest configuration, fixtures, and mock providers."""

import pytest
from starlette.testclient import TestClient
from app.core.rate_limit import rate_limiter
from app.main import create_app
from app.providers.mock import MockLLMProvider
from app.providers.registry import provider_registry


@pytest.fixture(autouse=True)
def reset_rate_limiter():
    """Reset rate limiter counts before each test run."""
    rate_limiter.clear()
    yield
    rate_limiter.clear()


@pytest.fixture
def mock_provider() -> MockLLMProvider:
    """Fixture providing the active MockLLMProvider instance."""
    provider = MockLLMProvider()
    provider_registry.register(provider)
    return provider


@pytest.fixture
def client(mock_provider) -> TestClient:
    """TestClient fixture with MockLLMProvider registered."""
    app = create_app()
    return TestClient(app)
