from app.features.queue.repository import QueueRepository


class QueueService:

    def __init__(self, repository: QueueRepository):
        self.repository = repository

    def get_queue_status(self, event_id: int):
        return self.repository.get_queue_status(event_id)