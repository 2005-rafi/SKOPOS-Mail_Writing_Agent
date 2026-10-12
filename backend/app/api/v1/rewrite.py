"""Draft rewrite endpoint."""

from fastapi import APIRouter, Depends, Request
from app.core.config import get_settings
from app.core.rate_limit import rate_limiter
from app.core.security import UserContext
from app.middleware.auth import get_current_user
from app.schemas.rewrite import RewriteRequest, RewriteResponse
from app.services.rewrite_service import RewriteService

router = APIRouter(tags=["Writing Engine"])


@router.post(
    "/rewrite",
    response_model=RewriteResponse,
    summary="Rewrite Existing Content",
)
async def rewrite_communication(
    request_data: RewriteRequest,
    request: Request,
    user: UserContext = Depends(get_current_user),
) -> RewriteResponse:
    """Rewrite existing draft or rough notes into polished communication."""
    settings = get_settings()

    client_ip = request.client.host if request.client else "127.0.0.1"
    rate_limit_key = f"{user.uid}:{client_ip}:rewrite"
    rate_limiter.check_and_record(
        key=rate_limit_key,
        limit=settings.RATE_LIMIT_REWRITE_PER_MINUTE,
    )

    return await RewriteService.rewrite(request=request_data, user=user)
