from pydantic import BaseModel
from typing import Optional

class PersonajeSchema(BaseModel):
    nombre: str
    edad: int
    codigo_personaje: str

class PersonajeUpdateSchema(BaseModel):
    nombre: Optional[str] = None
    edad: Optional[int] = None
    codigo_personaje: Optional[str] = None
