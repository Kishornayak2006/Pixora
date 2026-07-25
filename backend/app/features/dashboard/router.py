from fastapi import APIRouter, Depends

from app.features.auth.dependencies import get_current_user
from app.features.auth.models import User

from app.features.dashboard.dependencies import get_dashboard_service
from app.features.dashboard.schemas import DashboardResponse

router = APIRouter(
    prefix="/dashboard",
    tags=["Dashboard"],
)


@router.get(
    "",
    response_model=DashboardResponse,
)
def dashboard(
    current_user: User = Depends(get_current_user),
    service=Depends(get_dashboard_service),
):
    return service.get_dashboard(
        current_user.studio.id
    )