from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.config.database import get_db

from app.schemas.password_schema import RecoverSchema, ResetPasswordSchema

from app.controllers.password_controller import recover_password, reset_password

# ==========================================
# ROUTER (público: se usa antes de tener sesión)
# ==========================================
router = APIRouter(
    prefix="/users",
    tags=["Auth - Password"]
)


# RECOVER PASSWORD
@router.post("/recover-password")
def recover(data: RecoverSchema, db: Session = Depends(get_db)):
    return recover_password(data.mail, db)


# RESET PASSWORD
@router.post("/reset-password")
def reset(data: ResetPasswordSchema, db: Session = Depends(get_db)):
    return reset_password(data.mail, data.codigo, data.nueva_contrasena, db)
