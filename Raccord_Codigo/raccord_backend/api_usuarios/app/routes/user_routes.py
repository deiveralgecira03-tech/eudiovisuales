from fastapi import APIRouter, Depends, File, UploadFile
from sqlalchemy.orm import Session

from app.config.database import get_db

from app.schemas.user_schema import UserSchema, UserUpdateSchema, UserProfileUpdateSchema, ChangePasswordSchema, UserEstadoSchema

from app.controllers.user_controller import (
    get_users,
    get_user,
    create_user,
    update_user,
    update_user_full,
    delete_user,
    get_users_by_project,
    get_user_projects,
    update_own_profile,
    change_own_password,
    upload_own_photo,
    get_user_photo,
    set_user_estado
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
    id_user: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    return get_user_projects(id_user, db)


# ==========================================
# AUTO-SERVICIO (perfil propio) - declaradas ANTES de "/{id}" a
# propósito: como "/users/me" tiene la misma forma que "/users/{id}",
# FastAPI hace match por orden de declaración - si "/{id}" fuera
# primero, una petición a "/users/me" intentaría convertir "me" a int
# y fallaría con 422 en vez de llegar acá.
# ==========================================

# EDITAR MI PROPIO PERFIL (PROTEGIDO - cualquier usuario autenticado,
# nunca otro perfil, ver update_own_profile).
@router.patch("/me")
def patch_own_profile(
    user: UserProfileUpdateSchema,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    return update_own_profile(current_user["id_user"], user, db, current_user.get("id_rol"))


# CAMBIAR MI PROPIA CONTRASEÑA (PROTEGIDO - requiere la contraseña
# actual, ver change_own_password).
@router.post("/me/password")
def patch_own_password(
    data: ChangePasswordSchema,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    return change_own_password(current_user["id_user"], data.contrasena_actual, data.nueva_contrasena, db)


# SUBIR MI PROPIA FOTO DE PERFIL (PROTEGIDO).
@router.post("/me/foto")
async def store_own_photo(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    return await upload_own_photo(current_user["id_user"], file, db)


# VER LA FOTO DE PERFIL DE CUALQUIER USUARIO (PROTEGIDO - cualquier
# usuario autenticado; se usa también en listas como Roles del Equipo).
@router.get("/{id}/foto")
def photo(
    id: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    return get_user_photo(id, db)


# GET USER BY ID (PROTEGIDO)
@router.get("/{id}")
def user(
    id: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    return get_user(id, db)


# UPDATE USER - PUT (PROTEGIDO)
# Solo Administrador (1001) y Director (1002).
@router.put("/{id}")
def edit_user(
    id: str,
    user: UserSchema,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_permission("full_management"))
):
    return update_user_full(id, user, db)


# UPDATE USER - PATCH (PROTEGIDO)
# Solo Administrador (1001) y Director (1002).
@router.patch("/{id}")
def patch_user(
    id: str,
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
    id: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_permission("full_management"))
):
    return delete_user(id, db, current_user)


# SUSPENDER / REACTIVAR (PROTEGIDO)
# Administrador (1001) y Director (1002): todo el proyecto. Jefe de
# Departamento (1003): solo su propio departamento — esa parte del
# scoping se valida dentro del controller porque depende de comparar
# el departamento del que llama contra el del usuario objetivo.
@router.patch("/{id}/estado")
def patch_user_estado(
    id: str,
    data: UserEstadoSchema,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_permission("manage_team_status"))
):
    return set_user_estado(id, data.estado, current_user, db)
