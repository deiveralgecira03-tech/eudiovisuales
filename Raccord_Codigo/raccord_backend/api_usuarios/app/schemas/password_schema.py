from pydantic import BaseModel


# ==========================================
# RECUPERACIÓN DE CONTRASEÑA
# ==========================================
class RecoverSchema(BaseModel):
    mail: str


class ResetPasswordSchema(BaseModel):
    mail: str
    codigo: str
    nueva_contrasena: str
