from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.config.database import get_db

from app.schemas.user_schema import UserSchema, UserUpdateSchema

from app.controllers.user_controller import (
    get_users,
    get_user,
    create_user,
    update_user,
    update_user_full,
    delete_user,
    get_users_by_project,
    get_user_projects
)

# 🔐 IMPORTANTE: autenticación / permisos
from app.middleware.auth import get_current_user, require_permission

# ==========================================
# ROUTER (CRUD de usuarios, todo protegido)
# ==========================================
router = APIRouter(
    prefix="/users",
    tags=["Users"]
)


# GET ALL USERS (PROTEGIDO)
@router.get("")
def users(
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    return get_users(db)


# CREATE USER (PROTEGIDO - alta administrativa, distinta de /register)
# Solo Administrador (1001) y Director (1002) dan de alta usuarios.
@router.post("")
def store_user(
    user: UserSchema,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_permission("full_management"))
):
    return create_user(user, db)


# GET USERS BY PROJECT (PROTEGIDO)
@router.get("/project/{id_project}")
def users_by_project(
    id_project: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    return get_users_by_project(id_project, db)


# GET PROJECTS BY USER (PROTEGIDO)
@router.get("/{id_user}/projects")
def user_projects(
    id_user: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    return get_user_projects(id_user, db)


# GET USER BY ID (PROTEGIDO)
@router.get("/{id}")
def user(
    id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    return get_user(id, db)


# UPDATE USER - PUT (PROTEGIDO)
# Solo Administrador (1001) y Director (1002).
@router.put("/{id}")
def edit_user(
    id: int,
    user: UserSchema,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_permission("full_management"))
):
    return update_user_full(id, user, db)


# UPDATE USER - PATCH (PROTEGIDO)
# Solo Administrador (1001) y Director (1002).
@router.patch("/{id}")
def patch_user(
    id: int,
    user: UserUpdateSchema,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_permission("full_management"))
):
    return update_user(id, user, db)


# DELETE USER (PROTEGIDO)
# Administrador (1001) y Director (1002) pueden eliminar usuarios, pero
# Director NO puede eliminar usuarios con rol Administrador (1001) —
# esa regla puntual se valida dentro del controller, porque depende del
# rol del usuario objetivo, no solo del que hace la petición.
@router.delete("/{id}")
def destroy_user(
    id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_permission("full_management"))
):
    return delete_user(id, db, current_user)
