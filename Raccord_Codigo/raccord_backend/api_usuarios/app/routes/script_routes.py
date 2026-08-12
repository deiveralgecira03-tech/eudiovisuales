from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.config.database import get_db
from app.controllers.script_controller import (
    get_scripts,
    get_script,
    get_scripts_by_project,
    create_script,
    update_script_full,
    update_script,
    delete_script
)
from app.schemas.script_schema import ScriptSchema, ScriptUpdateSchema

# 🔐 autenticación / permisos
from app.middleware.auth import get_current_user, require_permission

router = APIRouter()

@router.get("/scripts")
def scripts(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_scripts(db)

@router.get("/scripts/project/{id_project}")
def scripts_by_project(id_project: str, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_scripts_by_project(id_project, db)

@router.get("/scripts/{id}")
def script(id: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_script(id, db)

# Solo Administrador (1001) y Director (1002) suben/editan/eliminan
# guiones. Jefe de Departamento (1003), Onset (1004) y Usuario (1005)
# no tienen este permiso.
@router.post("/scripts")
def store_script(script: ScriptSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("upload_scripts"))):
    return create_script(script, db)

@router.put("/scripts/{id}")
def edit_script(id: int, script: ScriptSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("upload_scripts"))):
    return update_script_full(id, script, db)

@router.patch("/scripts/{id}")
def patch_script(id: int, script: ScriptUpdateSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("upload_scripts"))):
    return update_script(id, script, db)

@router.delete("/scripts/{id}")
def destroy_script(id: int, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("upload_scripts"))):
    return delete_script(id, db)
