
from dotenv import load_dotenv
from fastapi import FastAPI, Request, HTTPException, Depends
from fastapi.responses import Response
from backend.database import get_db
from backend.dtos import CreateRecordDTO, FullRecordDTO
from backend.services import get_data_service, initialize_db
from typing import List
import os

app = FastAPI()

load_dotenv()

def _trim_db_url(url: str) -> str:
    """
    Removes the database name from the end of a DB URL (after the last '/').
    Example: 'postgresql+asyncpg://user:pass@host:5432/dbname' -> 'postgresql+asyncpg://user:pass@host:5432'
    """
    return url.rsplit('/', 1)[0] if '/' in url else url

@app.on_event("startup")
async def startup_event():
    try:
        async for db in get_db():
            data_service = get_data_service()
            db_url = os.getenv("DATABASE_URL")
            trimmed_db_url = _trim_db_url(db_url)
            await initialize_db(trimmed_db_url)
            break
        print("Database initialized successfully.")
    except Exception as e:
        print(f"Database initialization failed: {e}")

@app.get("/records")
async def get_all_records(
        db=Depends(get_db),
        data_service=Depends(get_data_service)
    ) -> List[FullRecordDTO]:
    try:
        data = await data_service.get_all_records(db)
        if not data:
            data = []
        return data
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
    
@app.get("/records/{record_id}")
async def get_record_by_id(
        record_id: str,
        db=Depends(get_db),
        data_service=Depends(get_data_service)
    ) -> FullRecordDTO:
    try:
        data = await data_service.get_record_by_id(record_id, db)
        if not data:
            raise HTTPException(status_code=404, detail="Record not found")
        return data
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/records")
async def create_record(
        record: CreateRecordDTO,
        request: Request,
        db=Depends(get_db),
        data_service=Depends(get_data_service)
    ) -> Response:
    try:
        data = await data_service.create_record(record=record, db=db)
        if not data:
            raise HTTPException(status_code=400, detail="Failed to create record")
        return Response(content=data.json(), media_type="application/json", status_code=201)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
    
@app.put("/records/{record_id}")
async def update_record(
        record_id: str,
        record: CreateRecordDTO,
        db=Depends(get_db),
        data_service=Depends(get_data_service)
    ) -> FullRecordDTO:
    try:
        data = await data_service.update_record(record_id, record, db)
        if not data:
            raise HTTPException(status_code=404, detail="Record not found")
        return data
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@app.delete("/records/{record_id}")
async def delete_record(
        record_id: str,
        db=Depends(get_db),
        data_service=Depends(get_data_service)
    ) -> dict:
    try:
        success = await data_service.delete_record(record_id, db)
        if not success:
            raise HTTPException(status_code=404, detail="Record not found")
        return {"detail": "Record deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@app.get("/test-db-connection")
async def health_check(
        db=Depends(get_db),
        data_service=Depends(get_data_service)
    ) -> dict:
    try:
        is_connected = await data_service.test_db_connection(db)
        return {"db_connection": "healthy" if is_connected else "unhealthy",
                "version": "2.0.0"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))