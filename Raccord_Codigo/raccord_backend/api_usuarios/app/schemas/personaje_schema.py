from pydantic import BaseModel
from typing import Optional

class PersonajeSchema(BaseModel):
    nombre_personaje: str
    descripcion: Optional[str] = None
    id_project: str
    id_actor: Optional[int] = None

class PersonajeUpdateSchema(BaseModel):
    nombre_personaje: Optional[str] = None
    descripcion: Optional[str] = None
    id_project: Optional[str] = None
    id_actor: Optional[int] = None
