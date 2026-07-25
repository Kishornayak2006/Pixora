from fastapi import Depends
from sqlalchemy.orm import Session

from app.db.session import get_db

from app.features.analytics.repository import AnalyticsRepository
from app.features.analytics.service import AnalyticsService


def get_analytics_service(
    db: Session = Depends(get_db),
):
    repository = AnalyticsRepository(db)
    return AnalyticsService(repository)