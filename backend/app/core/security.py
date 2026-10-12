"""Authentication and identity verification for Firebase and Dev/Guest modes.

Never trusts user identity provided in the request body.
"""

import hashlib
from typing import NamedTuple
from fastapi import Request
from app.core.config import get_settings
from app.core.errors import AuthInvalidException, AuthRequiredException


class UserContext(NamedTuple):
    """Context extracted from verified user credentials."""
    uid: str
    is_guest: bool
    email: str | None = None


# Cache for initialized Firebase app
_firebase_initialized = False


def _init_firebase_if_needed() -> bool:
    """Initialize Firebase Admin SDK if configuration is present."""
    global _firebase_initialized
    if _firebase_initialized:
        return True

    settings = get_settings()
    if not settings.FIREBASE_PROJECT_ID and not settings.FIREBASE_CREDENTIALS_PATH:
        return False

    try:
        import firebase_admin
        from firebase_admin import credentials

        if not firebase_admin._apps:
            if settings.FIREBASE_CREDENTIALS_PATH:
                cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
                firebase_admin.initialize_app(cred)
            else:
                firebase_admin.initialize_app(
                    options={"projectId": settings.FIREBASE_PROJECT_ID}
                )
        _firebase_initialized = True
        return True
    except Exception:
        return False


def verify_auth_token(request: Request) -> UserContext:
    """Verify incoming Authorization header and extract user context.

    If in DEV_GUEST_MODE and no valid token is provided, returns a stable guest context.
    """
    settings = get_settings()
    auth_header = request.headers.get("Authorization")
    client_ip = request.client.host if request.client else "127.0.0.1"

    if not auth_header or not auth_header.startswith("Bearer "):
        if settings.DEV_GUEST_MODE:
            # Deterministic guest UID based on client IP
            ip_hash = hashlib.sha256(client_ip.encode()).hexdigest()[:12]
            return UserContext(uid=f"guest_{ip_hash}", is_guest=True)
        raise AuthRequiredException()

    token = auth_header.split("Bearer ", 1)[1].strip()

    # Special handling for explicit dev guest token
    if token.startswith("guest_") and settings.DEV_GUEST_MODE:
        return UserContext(uid=token, is_guest=True)

    # Attempt Firebase token verification if Firebase is configured
    if _init_firebase_if_needed():
        try:
            from firebase_admin import auth
            decoded_token = auth.verify_id_token(token)
            uid = decoded_token.get("uid")
            if not uid:
                raise AuthInvalidException("Token does not contain a valid UID.")
            return UserContext(
                uid=uid,
                is_guest=decoded_token.get("firebase", {}).get("sign_in_provider") == "anonymous",
                email=decoded_token.get("email"),
            )
        except Exception as exc:
            if settings.DEV_GUEST_MODE:
                ip_hash = hashlib.sha256(client_ip.encode()).hexdigest()[:12]
                return UserContext(uid=f"guest_{ip_hash}", is_guest=True)
            raise AuthInvalidException(str(exc)) from exc

    # If Firebase not configured but guest mode enabled
    if settings.DEV_GUEST_MODE:
        ip_hash = hashlib.sha256(token.encode()).hexdigest()[:12]
        return UserContext(uid=f"guest_{ip_hash}", is_guest=True)

    raise AuthInvalidException("Authentication provider is not configured.")
