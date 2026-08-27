from pydantic import BaseModel
from typing import Optional
from datetime import datetime


# ==========================================
# USUARIO (CRUD)
# ==========================================
class UserSchema(BaseModel):
    nombre: str
    apellido: str
    identificacion: str
    id_identificacion: str
    mail: str
    msisdn: str
    direccion: str
    fecha_de_nacimiento: datetime
    estado: str
    contrasena: str
    id_departamento: str
    id_project: str
    id_rol: int


class UserUpdateSchema(BaseModel):
    nombre: Optional[str] = None
    apellido: Optional[str] = None
    identificacion: Optional[str] = None
    id_identificacion: Optional[str] = None
    mail: Optional[str] = None
    msisdn: Optional[str] = None
    direccion: Optional[str] = None
    fecha_de_nacimiento: Optional[datetime] = None
    estado: Optional[str] = None
    contrasena: Optional[str] = None
    id_departamento: Optional[str] = None
    id_project: Optional[str] = None
    id_rol: Optional[int] = None


# ==========================================
# VINCULACIÓN USUARIO - PROYECTO
# ==========================================
class UserProjectSchema(BaseModel):
    id_user: int
    id_project: str
    id_rol: int = 1005
