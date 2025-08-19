import os
from backend.dtos import FullRecordDTO, CreateRecordDTO
from backend.repository import DataRepository
from typing import List
from uuid import uuid4
from sqlalchemy import text
import asyncio
from sqlalchemy.ext.asyncio import create_async_engine
import os

def get_data_service():
    data_repo = DataRepository()
    data_service = DataService(data_repo)
    return data_service

async def initialize_db(db_url: str):
    default_db = 'postgres'
    target_db = 'records_db'
    default_db_url = f"{db_url}/{default_db}"
    print(f"Connecting to default database: {default_db_url}")
    default_engine = create_async_engine(default_db_url, isolation_level="AUTOCOMMIT", echo=False)
    async with default_engine.begin() as conn:
        result = await conn.execute(text(f"SELECT 1 FROM pg_database WHERE datname = '{target_db}'"))
        exists = result.scalar() is not None
        if not exists:
            await conn.execute(text(f"CREATE DATABASE {target_db} OWNER postgres;"))
            await conn.execute(text(f"GRANT ALL PRIVILEGES ON DATABASE {target_db} TO postgres;"))
            print(f"Created database: {target_db}")
        else:
            print(f"Database {target_db} already exists")
    await default_engine.dispose()

    target_db_url = f"{db_url}/{target_db}"
    target_engine = create_async_engine(target_db_url, echo=False)
    
    async with target_engine.begin() as conn:
        await conn.execute(text(("""
            CREATE TABLE IF NOT EXISTS public.records (
                id uuid PRIMARY KEY,
                name text NOT NULL,
                value text NOT NULL,
            created_at timestamptz NOT NULL,
            updated_at timestamptz NOT NULL
        );
        """)))
    print(f"Ensured 'records' table exists in {target_db}")

class DataService:
    def __init__(self, data_repo: DataRepository):
        self.data_repo = data_repo
  


    async def test_db_connection(self, db) -> bool:
        try:
            await db.execute(text("SELECT 1 FROM records LIMIT 1"))
            return True
        except Exception as e:
            print(e)
            return False

    async def get_all_records(self, db) -> List[FullRecordDTO]:
        db_record = await self.data_repo.get_all_records(db)
        mapped_db_records = list(
            map(
                lambda x: FullRecordDTO(
                    id=str(x.id),
                    name=x.name,
                    value=x.value), db_record))
        return mapped_db_records

    async def get_record_by_id(self, record_id: str, db) -> FullRecordDTO:
        db_record = await self.data_repo.get_record_by_id(record_id, db)
        if not db_record:
            return None
        return FullRecordDTO(
            id=db_record.id,
            name=db_record.name,
            value=db_record.value
        )

    async def create_record(self, record: CreateRecordDTO, db) -> FullRecordDTO:
        
        record_id = str(uuid4())
        db_record = await self.data_repo.create_record(record=record,
                                                       record_id=record_id,
                                                       db=db)
        return db_record

    async def update_record(self, record_id: str, record: CreateRecordDTO, db) -> FullRecordDTO:
        db_record = await self.data_repo.update_record(record_id, record, db)
        if not db_record:
            return None
        return FullRecordDTO(
            id=str(db_record.id),
            name=db_record.name,
            value=db_record.value
        )

    async def delete_record(self, record_id: str, db) -> bool:
        return await self.data_repo.delete_record(record_id, db)
    
    


    
    