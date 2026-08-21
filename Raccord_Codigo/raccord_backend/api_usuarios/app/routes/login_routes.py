from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.config.database import get_db

from app.schemas.login_schema import (
    LoginSchema,
    TwoFactorSendSchema,
    TwoFactorVerifySchema
)

from app.controllers.login_controller import (
    login_user,
    check_2fa_required,
    send_2fa_code,
    verify_2fa_code
)

# ==========================================
# ROUTER (público, es el punto de entrada de sesión)
# ==========================================
router = APIRouter(
    prefix="/users",
    tags=["Auth - Login"]
)


# LOGIN
@router.post("/login")
def login(user: LoginSchema, db: Session = Depends(get_db)):
    return login_user(user.mail, user.contrasena, db)


# 2FA - VERIFICAR SI NECESITA 2FA
@router.post("/2fa/check")
def check_2fa(data: TwoFactorSendSchema, db: Session = Depends(get_db)):
    return check_2fa_required(data.mail, data.device_id, data.contrasena, db)


# 2FA - ENVIAR CODIGO
@router.post("/2fa/send")
def send_2fa(data: TwoFactorSendSchema, db: Session = Depends(get_db)):
    return send_2fa_code(data.mail, data.device_id, data.contrasena, db)


# 2FA - VERIFICAR CODIGO
@router.post("/2fa/verify")
def verify_2fa(data: TwoFactorVerifySchema, db: Session = Depends(get_db)):
    return verify_2fa_code(data.mail, data.codigo, data.device_id, data.contrasena, db)
