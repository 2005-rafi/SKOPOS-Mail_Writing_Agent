"""Centralized system constants, limits, and enumeration values.

No magic numbers or scattered strings should exist in route handlers or services.
"""

from enum import StrEnum
from typing import Final

# API Versioning & Routing
API_PREFIX: Final[str] = "/api/v1"
API_VERSION: Final[str] = "v1"

# Content & Output Constraints
DEFAULT_MAX_WORDS: Final[int] = 100
ABSOLUTE_MAX_WORDS: Final[int] = 500
MAX_SCENARIO_LENGTH: Final[int] = 2000
MAX_PREVIOUS_OUTPUT_LENGTH: Final[int] = 4000
MAX_REFINEMENT_LENGTH: Final[int] = 1000
MAX_REPAIR_ATTEMPTS: Final[int] = 1
DEFAULT_TEMPERATURE: Final[float] = 0.7

# Supported Content Types
class ContentType(StrEnum):
    EMAIL = "email"
    LETTER = "letter"
    SHORT_MESSAGE = "short_message"
    ANNOUNCEMENT = "announcement"

# Supported Tones
class ToneType(StrEnum):
    PROFESSIONAL = "professional"
    FORMAL = "formal"
    FRIENDLY = "friendly"
    DIRECT = "direct"
    PERSUASIVE = "persuasive"
    ACADEMIC = "academic"
    SYMPATHETIC = "sympathetic"
    POLITE = "polite"
    APOLOGETIC = "apologetic"
    CUSTOM = "custom"
    OTHER = "other"

# Supported Styles
class StyleType(StrEnum):
    CONCISE = "concise"
    DETAILED = "detailed"
    EXECUTIVE = "executive"
    DIPLOMATIC = "diplomatic"
    FORMAL = "formal"
    CASUAL = "casual"
    CUSTOM = "custom"
    OTHER = "other"


# Supported Providers
class ProviderType(StrEnum):
    GROQ = "groq"
    GEMINI = "gemini"
    MOCK = "mock"

# Default Model Identifiers
DEFAULT_MODELS: Final[dict[ProviderType, str]] = {
    ProviderType.GROQ: "llama-3.1-8b-instant",
    ProviderType.GEMINI: "gemini-1.5-flash",
    ProviderType.MOCK: "mock-model-v1",
}

AVAILABLE_MODELS: Final[dict[ProviderType, list[str]]] = {
    ProviderType.GROQ: [
        "llama-3.1-8b-instant",
        "llama-3.3-70b-versatile",
        "llama3-70b-8192",
        "llama3-8b-8192",
        "mixtral-8x7b-32768",
        "gemma2-9b-it",
    ],
    ProviderType.GEMINI: [
        "gemini-1.5-flash",
        "gemini-2.0-flash",
        "gemini-1.5-pro",
        "gemini-2.5-flash",
    ],
    ProviderType.MOCK: [
        "mock-model-v1",
    ],
}

# Supported Languages
SUPPORTED_LANGUAGES: Final[list[str]] = [
    "English",
    "Spanish",
    "French",
    "German",
    "Hindi",
    "Japanese",
    "Arabic",
    "Portuguese",
    "Chinese",
]

# Standard Error Codes defined by PRD Section 31
class ErrorCode(StrEnum):
    INVALID_REQUEST = "INVALID_REQUEST"
    VALIDATION_FAILED = "VALIDATION_FAILED"
    AUTH_REQUIRED = "AUTH_REQUIRED"
    AUTH_INVALID = "AUTH_INVALID"
    FORBIDDEN = "FORBIDDEN"
    NOT_FOUND = "NOT_FOUND"
    RATE_LIMIT_EXCEEDED = "RATE_LIMIT_EXCEEDED"
    PAYLOAD_TOO_LARGE = "PAYLOAD_TOO_LARGE"
    PROVIDER_NOT_SUPPORTED = "PROVIDER_NOT_SUPPORTED"
    PROVIDER_AUTH_FAILED = "PROVIDER_AUTH_FAILED"
    PROVIDER_RATE_LIMITED = "PROVIDER_RATE_LIMITED"
    PROVIDER_TIMEOUT = "PROVIDER_TIMEOUT"
    PROVIDER_UNAVAILABLE = "PROVIDER_UNAVAILABLE"
    LLM_GENERATION_FAILED = "LLM_GENERATION_FAILED"
    LLM_VALIDATION_FAILED = "LLM_VALIDATION_FAILED"
    LLM_REPAIR_FAILED = "LLM_REPAIR_FAILED"
    INTERNAL_ERROR = "INTERNAL_ERROR"
    SERVICE_UNAVAILABLE = "SERVICE_UNAVAILABLE"
