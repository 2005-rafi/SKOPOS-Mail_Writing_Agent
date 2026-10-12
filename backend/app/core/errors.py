"""Custom application exceptions with standardized error code mappings.

All application exceptions inherit from SkoposException.
"""

from typing import Any
from fastapi import status
from app.core.constants import ErrorCode


class SkoposException(Exception):
    """Base exception for all domain and operational errors in SKOPOS."""

    def __init__(
        self,
        code: ErrorCode,
        message: str,
        status_code: int = status.HTTP_500_INTERNAL_SERVER_ERROR,
        details: dict[str, Any] | None = None,
    ) -> None:
        super().__init__(message)
        self.code = code
        self.message = message
        self.status_code = status_code
        self.details = details or {}


class InvalidRequestException(SkoposException):
    def __init__(self, message: str, details: dict[str, Any] | None = None) -> None:
        super().__init__(
            code=ErrorCode.INVALID_REQUEST,
            message=message,
            status_code=status.HTTP_400_BAD_REQUEST,
            details=details,
        )


class ValidationException(SkoposException):
    def __init__(self, message: str, details: dict[str, Any] | None = None) -> None:
        super().__init__(
            code=ErrorCode.VALIDATION_FAILED,
            message=message,
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            details=details,
        )


class AuthRequiredException(SkoposException):
    def __init__(self, message: str = "Authentication credentials were not provided.") -> None:
        super().__init__(
            code=ErrorCode.AUTH_REQUIRED,
            message=message,
            status_code=status.HTTP_401_UNAUTHORIZED,
        )


class AuthInvalidException(SkoposException):
    def __init__(self, message: str = "The provided authentication token is invalid or expired.") -> None:
        super().__init__(
            code=ErrorCode.AUTH_INVALID,
            message=message,
            status_code=status.HTTP_401_UNAUTHORIZED,
        )


class RateLimitExceededException(SkoposException):
    def __init__(self, message: str = "Rate limit exceeded. Please wait a moment before trying again.") -> None:
        super().__init__(
            code=ErrorCode.RATE_LIMIT_EXCEEDED,
            message=message,
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
        )


class PayloadTooLargeException(SkoposException):
    def __init__(self, message: str = "Request payload exceeds allowed size limits.") -> None:
        super().__init__(
            code=ErrorCode.PAYLOAD_TOO_LARGE,
            message=message,
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
        )


class ProviderNotSupportedException(SkoposException):
    def __init__(self, provider: str) -> None:
        super().__init__(
            code=ErrorCode.PROVIDER_NOT_SUPPORTED,
            message=f"LLM provider '{provider}' is not supported.",
            status_code=status.HTTP_400_BAD_REQUEST,
            details={"provider": provider},
        )


class ProviderAuthException(SkoposException):
    def __init__(self, message: str = "The API key was rejected by the selected provider.") -> None:
        super().__init__(
            code=ErrorCode.PROVIDER_AUTH_FAILED,
            message=message,
            status_code=status.HTTP_401_UNAUTHORIZED,
        )


class ProviderRateLimitException(SkoposException):
    def __init__(self, message: str = "The selected provider rate limit has been reached.") -> None:
        super().__init__(
            code=ErrorCode.PROVIDER_RATE_LIMITED,
            message=message,
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
        )


class ProviderTimeoutException(SkoposException):
    def __init__(self, message: str = "The request to the AI provider timed out.") -> None:
        super().__init__(
            code=ErrorCode.PROVIDER_TIMEOUT,
            message=message,
            status_code=status.HTTP_504_GATEWAY_TIMEOUT,
        )


class ProviderUnavailableException(SkoposException):
    def __init__(self, message: str = "The selected AI provider is currently unreachable or unavailable.") -> None:
        super().__init__(
            code=ErrorCode.PROVIDER_UNAVAILABLE,
            message=message,
            status_code=status.HTTP_502_BAD_GATEWAY,
        )


class LLMGenerationException(SkoposException):
    def __init__(self, message: str, details: dict[str, Any] | None = None) -> None:
        super().__init__(
            code=ErrorCode.LLM_GENERATION_FAILED,
            message=message,
            status_code=status.HTTP_502_BAD_GATEWAY,
            details=details,
        )


class LLMValidationException(SkoposException):
    def __init__(self, message: str, details: dict[str, Any] | None = None) -> None:
        super().__init__(
            code=ErrorCode.LLM_VALIDATION_FAILED,
            message=message,
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            details=details,
        )


class LLMRepairException(SkoposException):
    def __init__(self, message: str, details: dict[str, Any] | None = None) -> None:
        super().__init__(
            code=ErrorCode.LLM_REPAIR_FAILED,
            message=message,
            status_code=status.HTTP_502_BAD_GATEWAY,
            details=details,
        )
