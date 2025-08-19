
from backend.database import Base
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import Column, String, DateTime
from datetime import datetime, timezone

class RecordModel(Base):
    __tablename__ = 'records'
    
    id = Column(UUID, primary_key=True, index=True)
    name = Column(String, index=True)
    value = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), default=datetime.now(timezone.utc))

    def __repr__(self):
        return f"<Record(id={self.id}, name={self.name})>"