"""Central configuration loaded from environment variables and .env file.

Never hardcode secrets, endpoints, or environment flags in application code.
"""

from functools import lru_cache
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application runtime settings."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    # Application
    APP_NAME: str = "SKOPOS"
    ENVIRONMENT: str = "development"
    API_VERSION: str = "v1"
    LOG_LEVEL: str = "INFO"
    HOST: str = "0.0.0.0"
    PORT: int = 8000

    # Limits & Timeouts
    REQUEST_TIMEOUT_SECONDS: int = 30
    DEFAULT_MAX_WORDS: int = 100
    ABSOLUTE_MAX_WORDS: int = 500
    MAX_SCENARIO_LENGTH: int = 2000
    MAX_PREVIOUS_OUTPUT_LENGTH: int = 4000
    MAX_REFINEMENT_LENGTH: int = 1000
    MAX_REPAIR_ATTEMPTS: int = 1

    # Rate Limiting (per minute)
    RATE_LIMIT_GENERATE_PER_MINUTE: int = 20
    RATE_LIMIT_REWRITE_PER_MINUTE: int = 20
    RATE_LIMIT_REFINE_PER_MINUTE: int = 20
    RATE_LIMIT_USAGE_PER_MINUTE: int = 30
    RATE_LIMIT_HEALTH_PER_MINUTE: int = 120
    RATE_LIMIT_CONFIG_PER_MINUTE: int = 120

    # CORS
    CORS_ORIGINS: list[str] = Field(
        default_factory=lambda: [
            "http://localhost:3000",
            "http://localhost:5173",
            "http://localhost:8000",
            "http://localhost:8080",
            "http://127.0.0.1:5500",
            "http://127.0.0.1:8000",
            "*",
        ]
    )

    # Authentication & Security
    DEV_GUEST_MODE: bool = True
    FIREBASE_PROJECT_ID: str = ""
    FIREBASE_CREDENTIALS_PATH: str = ""


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Return cached singleton instance of runtime settings."""
    return Settings()
