from backend.models import RecordModel
from typing import List
from backend.dtos import FullRecordDTO, CreateRecordDTO
import uuid
from sqlalchemy.future import select

class DataRepository:
    def __init__(self):
        pass
    
    async def get_all_records(self, db) -> List[RecordModel]:
        result = await db.execute(select(RecordModel))
        records = result.scalars().all()
        return records

    async def get_record_by_id(self, record_id: str, db) -> FullRecordDTO:
        record_uuid = uuid.UUID(record_id)
        query = select(RecordModel).filter(RecordModel.id == record_uuid)
        result = await db.execute(query)
        record = result.scalar_one_or_none()
        return FullRecordDTO(
            id=str(record.id),
            name=record.name,
            value=record.value
        )

    async def create_record(self, record: CreateRecordDTO, record_id: str, db) -> FullRecordDTO:
        record_uuid = uuid.UUID(record_id)
        new_record = RecordModel(id=record_uuid, name=record.name, value=record.value)
        db.add(new_record)
        await db.commit()
        await db.refresh(new_record)
        
        return FullRecordDTO(
            id=str(new_record.id),
            name=new_record.name,
            value=new_record.value
        )

    async def update_record(self, record_id: str, record, db) -> FullRecordDTO:
        record_uuid = uuid.UUID(record_id)
        query = select(RecordModel).filter(RecordModel.id == record_uuid)
        result = await db.execute(query)
        db_record = result.scalar_one_or_none()
        
        db_record.name = record.name
        db_record.value = record.value
        await db.commit()
        await db.refresh(db_record)
        return db_record

    async def delete_record(self, record_id: str, db) -> bool:
        record_uuid = uuid.UUID(record_id)
        query = select(RecordModel).filter(RecordModel.id == record_uuid)
        result = await db.execute(query)
        db_record = result.scalar_one_or_none()
        if not db_record:
            return False
        await db.delete(db_record)
        await db.commit()
        return True