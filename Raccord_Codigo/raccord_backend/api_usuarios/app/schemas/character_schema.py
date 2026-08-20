from pydantic import BaseModel
from typing import Optional


# ==========================================
# PERSONAJES
# ==========================================
# id_personaje no va en el schema de creación: lo genera el trigger de
# la base de datos (cast1, cast2, ...).
class CharacterSchema(BaseModel):
    nombre: str
    edad: int
    codigo_personaje: str


class CharacterUpdateSchema(BaseModel):
    nombre: Optional[str] = None
    edad: Optional[int] = None
    codigo_personaje: Optional[str] = None
