"""Authentication dependency injecting verified UserContext into routes."""

from fastapi import Depends, Request
from app.core.security import UserContext, verify_auth_token


def get_current_user(request: Request) -> UserContext:
    """Dependency that extracts and validates the requesting user's identity."""
    user = verify_auth_token(request)
    request.state.user = user
    return user
