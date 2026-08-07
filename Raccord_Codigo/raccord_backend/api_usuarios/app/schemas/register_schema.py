from pydantic import BaseModel
from typing import Optional


# ==========================================
# REGISTRO (Cliente/Empresa + Usuario)
# ==========================================
class RegisterSchema(BaseModel):
    # Datos empresa
    razon_social: str
    representante_legal: str
    email_empresa: str
    address: Optional[str] = None
    telephone: Optional[str] = None
    number_cellphone: Optional[str] = None
    document: str
    id_document: str

    # Datos usuario
    nombre: str
    apellido: str
    mail: str
    msisdn: str
    contrasena: str


# ==========================================
# INVITAR USUARIOS A UN PROYECTO
# ==========================================
class InviteSchema(BaseModel):
    correos: list[str]
    id_project: str
    id_client: int
    id_rol: int
