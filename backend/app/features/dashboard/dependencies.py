from fastapi import Depends

from app.db.session import get_db

from app.features.dashboard.repository import DashboardRepository
from app.features.dashboard.service import DashboardService


def get_dashboard_service(db=Depends(get_db)):
    repo = DashboardRepository(db)
    return DashboardService(repo)