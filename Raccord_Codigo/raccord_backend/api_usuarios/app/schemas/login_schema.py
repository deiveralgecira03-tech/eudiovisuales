from pydantic import BaseModel


# ==========================================
# LOGIN
# ==========================================
class LoginSchema(BaseModel):
    mail: str
    contrasena: str


# ==========================================
# 2FA (segundo factor, parte del flujo de login)
# ==========================================
class TwoFactorSendSchema(BaseModel):
    mail: str
    device_id: str
    contrasena: str


class TwoFactorVerifySchema(BaseModel):
    mail: str
    codigo: str
    device_id: str
    contrasena: str
