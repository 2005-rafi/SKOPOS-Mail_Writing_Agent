"""Global exception handling translating all errors into the standardized PRD error contract.

Format:
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-friendly explanation.",
    "requestId": "req_xxx",
    "details": {}
  }
}
"""

from fastapi import FastAPI, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from app.core.constants import ErrorCode
from app.core.errors import SkoposException
from app.core.logging import logger


def register_error_handlers(app: FastAPI) -> None:
    """Register uniform exception handlers on the FastAPI application."""

    @app.exception_handler(SkoposException)
    async def skopos_exception_handler(request: Request, exc: SkoposException) -> JSONResponse:
        request_id = getattr(request.state, "request_id", "req_unknown")
        logger.warning(
            f"Domain Exception [{exc.code}] on {request.method} {request.url.path} (ID: {request_id}): {exc.message}"
        )
        content = {
            "success": False,
            "error": {
                "code": exc.code,
                "message": exc.message,
                "requestId": request_id,
            },
        }
        if exc.details:
            content["error"]["details"] = exc.details

        return JSONResponse(
            status_code=exc.status_code,
            content=content,
            headers={"X-Request-ID": request_id},
        )

    @app.exception_handler(RequestValidationError)
    async def validation_exception_handler(request: Request, exc: RequestValidationError) -> JSONResponse:
        request_id = getattr(request.state, "request_id", "req_unknown")
        error_messages = []
        for err in exc.errors():
            loc = " -> ".join(str(l) for l in err.get("loc", []))
            msg = err.get("msg", "invalid")
            error_messages.append(f"{loc}: {msg}")

        summary = "; ".join(error_messages) or "Invalid request parameters."
        logger.info(f"Validation failure on {request.url.path} (ID: {request_id}): {summary}")

        return JSONResponse(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            content={
                "success": False,
                "error": {
                    "code": ErrorCode.VALIDATION_FAILED,
                    "message": summary,
                    "requestId": request_id,
                    "details": {"validationErrors": exc.errors()},
                },
            },
            headers={"X-Request-ID": request_id},
        )

    @app.exception_handler(Exception)
    async def unhandled_exception_handler(request: Request, exc: Exception) -> JSONResponse:
        request_id = getattr(request.state, "request_id", "req_unknown")
        logger.error(
            f"Unhandled Exception on {request.method} {request.url.path} (ID: {request_id}): {exc}",
            exc_info=True,
        )
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={
                "success": False,
                "error": {
                    "code": ErrorCode.INTERNAL_ERROR,
                    "message": "An unexpected error occurred while processing your request.",
                    "requestId": request_id,
                },
            },
            headers={"X-Request-ID": request_id},
        )
