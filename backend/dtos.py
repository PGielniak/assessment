from pydantic import BaseModel, Field, field_validator
import uuid


class CreateRecordDTO(BaseModel):
    name: str = Field(..., description="Name associated with the record")
    value: str = Field(..., description="Value of the record")
    
class FullRecordDTO(BaseModel):
    id: str = Field(..., description="Unique identifier of the record")
    name: str = Field(..., description="Name associated with the record")
    value: str = Field(..., description="Value of the record")
    
    @field_validator('id')
    @classmethod
    def validate_guid_uuid(cls, v: str) -> str:
        try:
            uuid_obj = uuid.UUID(v)
            return str(uuid_obj)
        except ValueError:
            raise ValueError('ID must be a valid GUID/UUID format')
    
