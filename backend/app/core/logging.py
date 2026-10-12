"""Sanitized, structured logging that redacts API keys and sensitive tokens.

Never logs full prompts, secrets, or raw authorization tokens.
"""

import logging
import re
import sys
from typing import Any

# Regex patterns matching API keys and tokens for redaction
REDACTION_PATTERNS = [
    re.compile(r"gsk_[a-zA-Z0-9]{16,}", re.IGNORECASE),           # Groq API keys
    re.compile(r"AIza[0-9A-Za-z_-]{20,}", re.IGNORECASE),          # Google Gemini API keys
    re.compile(r"Bearer\s+[a-zA-Z0-9_.~+/=-]{10,}", re.IGNORECASE), # Bearer tokens
    re.compile(r'"apiKey"\s*:\s*"[^"]+"', re.IGNORECASE),         # JSON apiKey fields
    re.compile(r'"api_key"\s*:\s*"[^"]+"', re.IGNORECASE),        # JSON api_key fields
]


def redact_sensitive_data(message: str) -> str:
    """Scrub known secret and token patterns from a log string."""
    redacted = message
    for pattern in REDACTION_PATTERNS:
        redacted = pattern.sub("[REDACTED_CREDENTIAL]", redacted)
    return redacted


class RedactingFormatter(logging.Formatter):
    """Custom formatter intercepting log records and redacting secrets."""

    def format(self, record: logging.LogRecord) -> str:
        original = super().format(record)
        return redact_sensitive_data(original)


def setup_logger(name: str = "skopos", level: str = "INFO") -> logging.Logger:
    """Configure and return an application logger."""
    logger = logging.getLogger(name)
    logger.setLevel(getattr(logging, level.upper(), logging.INFO))

    if not logger.handlers:
        handler = logging.StreamHandler(sys.stdout)
        handler.setLevel(getattr(logging, level.upper(), logging.INFO))
        formatter = RedactingFormatter(
            fmt="%(asctime)s [%(levelname)s] [%(name)s] %(message)s",
            datefmt="%Y-%m-%d %H:%M:%S",
        )
        handler.setFormatter(formatter)
        logger.addHandler(handler)

    logger.propagate = False
    return logger


# Default logger instance
logger = setup_logger()
