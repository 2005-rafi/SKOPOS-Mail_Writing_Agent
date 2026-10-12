"""Generation endpoint for emails and letters."""

from fastapi import APIRouter, Depends, Request
from app.core.config import get_settings
from app.core.rate_limit import rate_limiter
from app.core.security import UserContext
from app.middleware.auth import get_current_user
from app.schemas.generation import GenerateRequest, GenerateResponse
from app.services.generation_service import GenerationService

router = APIRouter(tags=["Writing Engine"])


@router.post(
    "/generate",
    response_model=GenerateResponse,
    summary="Generate Communication from Scenario",
)
async def generate_communication(
    request_data: GenerateRequest,
    request: Request,
    user: UserContext = Depends(get_current_user),
) -> GenerateResponse:
    """Generate professional email or letter adhering to user preferences."""
    settings = get_settings()

    # Enforce rate limiting per user UID and client IP
    client_ip = request.client.host if request.client else "127.0.0.1"
    rate_limit_key = f"{user.uid}:{client_ip}:generate"
    rate_limiter.check_and_record(
        key=rate_limit_key,
        limit=settings.RATE_LIMIT_GENERATE_PER_MINUTE,
    )

    return await GenerationService.generate(request=request_data, user=user)
