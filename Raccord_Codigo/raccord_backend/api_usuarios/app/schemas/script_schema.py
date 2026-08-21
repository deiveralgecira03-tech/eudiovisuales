from pydantic import BaseModel
from typing import Optional, Literal
from datetime import date

# Debe coincidir exactamente con el ENUM estado_guion de la BD.
EstadoGuion = Literal["Borrador", "Revisión", "Aprobado", "En Rodaje", "Archivado"]


# ==========================================
# GUIONES
# ==========================================
class ScriptSchema(BaseModel):
    numero_de_version: str
    fecha_de_emision: date
    estado: EstadoGuion
    # Ya no es obligatorio: el PDF real se sube aparte con
    # POST /scripts/{id}/archivo justo después de crear el guión. Este
    # campo queda como texto libre opcional (legado).
    archivo: Optional[str] = ""
    nombre: str
    descripcion: Optional[str] = None
    id_project: Optional[str] = None


class ScriptUpdateSchema(BaseModel):
    numero_de_version: Optional[str] = None
    fecha_de_emision: Optional[date] = None
    estado: Optional[EstadoGuion] = None
    archivo: Optional[str] = None
    nombre: Optional[str] = None
    descripcion: Optional[str] = None
    id_project: Optional[str] = None
