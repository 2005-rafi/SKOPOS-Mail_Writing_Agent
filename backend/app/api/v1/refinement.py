"""Conversational refinement endpoint."""

from fastapi import APIRouter, Depends, Request
from app.core.config import get_settings
from app.core.rate_limit import rate_limiter
from app.core.security import UserContext
from app.middleware.auth import get_current_user
from app.schemas.refinement import RefineRequest, RefineResponse
from app.services.refinement_service import RefinementService

router = APIRouter(tags=["Writing Engine"])


@router.post(
    "/refine",
    response_model=RefineResponse,
    summary="Refine Previous Output",
)
async def refine_communication(
    request_data: RefineRequest,
    request: Request,
    user: UserContext = Depends(get_current_user),
) -> RefineResponse:
    """Apply targeted conversational instruction to update an existing draft."""
    settings = get_settings()

    client_ip = request.client.host if request.client else "127.0.0.1"
    rate_limit_key = f"{user.uid}:{client_ip}:refine"
    rate_limiter.check_and_record(
        key=rate_limit_key,
        limit=settings.RATE_LIMIT_REFINE_PER_MINUTE,
    )

    return await RefinementService.refine(request=request_data, user=user)
