from pydantic import BaseModel, EmailStr
from typing import Optional

class ActorSchema(BaseModel):
    nombre: str
    apellido: str
    email: Optional[EmailStr] = None
    telefono: Optional[str] = None
    activo: Optional[bool] = True

class ActorUpdateSchema(BaseModel):
    nombre: Optional[str] = None
    apellido: Optional[str] = None
    email: Optional[EmailStr] = None
    telefono: Optional[str] = None
    activo: Optional[bool] = None
