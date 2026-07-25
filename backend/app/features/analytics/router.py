from fastapi import APIRouter, Depends

from app.features.analytics.dependencies import get_analytics_service
from app.features.analytics.schemas import (
    MonthlyEventStat,
    MonthlyPhotoStat,
    EventTypeStat,
    ProcessingStat,
    StorageStat,
)
from app.features.analytics.service import AnalyticsService
from app.features.auth.dependencies import get_current_user
from app.features.auth.models import User

router = APIRouter(
    prefix="/analytics",
    tags=["Analytics"],
)


@router.get(
    "/events/monthly",
    response_model=list[MonthlyEventStat],
)
def monthly_events(
    current_user: User = Depends(get_current_user),
    service: AnalyticsService = Depends(get_analytics_service),
):
    return service.monthly_events(current_user.studio.id)


@router.get(
    "/photos/monthly",
    response_model=list[MonthlyPhotoStat],
)
def monthly_photos(
    current_user: User = Depends(get_current_user),
    service: AnalyticsService = Depends(get_analytics_service),
):
    return service.monthly_photos(current_user.studio.id)


@router.get(
    "/event-types",
    response_model=list[EventTypeStat],
)
def event_types(
    current_user: User = Depends(get_current_user),
    service: AnalyticsService = Depends(get_analytics_service),
):
    return service.event_types(current_user.studio.id)


@router.get(
    "/processing",
    response_model=ProcessingStat,
)
def processing_stats(
    current_user: User = Depends(get_current_user),
    service: AnalyticsService = Depends(get_analytics_service),
):
    return service.processing_stats(current_user.studio.id)


@router.get(
    "/storage",
    response_model=list[StorageStat],
)
def storage_stats(
    current_user: User = Depends(get_current_user),
    service: AnalyticsService = Depends(get_analytics_service),
):
    return service.storage_stats(current_user.studio.id)