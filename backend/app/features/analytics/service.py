from app.features.analytics.repository import AnalyticsRepository


class AnalyticsService:

    def __init__(self, repository: AnalyticsRepository):
        self.repository = repository

    def monthly_events(self, studio_id: int):
        return self.repository.monthly_events(studio_id)

    def monthly_photos(self, studio_id: int):
        return self.repository.monthly_photos(studio_id)

    def event_types(self, studio_id: int):
        return self.repository.event_types(studio_id)

    def processing_stats(self, studio_id: int):
        return self.repository.processing_stats(studio_id)

    def storage_stats(self, studio_id: int):
        return self.repository.storage_stats(studio_id)