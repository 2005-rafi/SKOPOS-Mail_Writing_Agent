"""Aggregated API v1 Router."""

from fastapi import APIRouter
from app.api.v1.config import router as config_router
from app.api.v1.generation import router as generation_router
from app.api.v1.health import router as health_router
from app.api.v1.provider import router as provider_router
from app.api.v1.refinement import router as refinement_router
from app.api.v1.rewrite import router as rewrite_router

api_v1_router = APIRouter()

api_v1_router.include_router(health_router)
api_v1_router.include_router(config_router)
api_v1_router.include_router(generation_router)
api_v1_router.include_router(rewrite_router)
api_v1_router.include_router(refinement_router)
api_v1_router.include_router(provider_router)
