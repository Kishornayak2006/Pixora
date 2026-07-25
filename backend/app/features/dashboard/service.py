from app.features.dashboard.repository import DashboardRepository


class DashboardService:

    def __init__(self, repository: DashboardRepository):
        self.repository = repository

    def get_dashboard(self, studio_id: int):
        return self.repository.get_dashboard(studio_id)