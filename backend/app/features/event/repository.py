from sqlalchemy.orm import Session

from app.features.event.models import Event


class EventRepository:
    def __init__(self, db: Session):
        self.db = db

    def get(self, event_id: int):
        return self.db.get(Event, event_id)

    def create(self, event: Event) -> Event:
        self.db.add(event)
        self.db.commit()
        self.db.refresh(event)
        return event

    def get_by_studio_id(self, studio_id: int) -> list[Event]:
        return (
            self.db.query(Event)
            .filter(Event.studio_id == studio_id)
            .order_by(Event.created_at.desc())
            .all()
        )
    
    def get_by_id(self, event_id: int):
        return (
            self.db.query(Event)
            .filter(Event.id == event_id)
            .first()
        )


    def update(self, event: Event):
        self.db.commit()
        self.db.refresh(event)
        return event


    def delete(self, event: Event):
        self.db.delete(event)
        self.db.commit()
        