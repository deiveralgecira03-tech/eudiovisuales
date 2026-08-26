from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.config.database import get_db

from app.schemas.register_schema import RegisterSchema, InviteSchema

from app.controllers.register_controller import register, invite_users

# 🔐 autenticación / permisos
from app.middleware.auth import require_permission

# ==========================================
# ROUTER
# ==========================================
router = APIRouter(
    tags=["Auth - Register"]
)


# REGISTER (público: alta de empresa + primer usuario)
@router.post("/register")
def register_user(data: RegisterSchema, db: Session = Depends(get_db)):
    return register(data, db)


# INVITE USERS (gestionar accesos)
# Solo Administrador (1001), Director (1002) y Jefe de Departamento
# (1003) pueden invitar personas.
@router.post("/users/invite")
def invite(
    data: InviteSchema,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_permission("invite_users"))
):
    return invite_users(data.invitados, data.id_project, data.id_client, db)
