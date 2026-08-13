from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.config.database import get_db
from app.controllers.scene_controller import (
    get_scenes,
    get_scene,
    get_scenes_by_script,
    get_scenes_by_rodaje,
    get_scenes_by_desglose,
    create_scene,
    update_scene_full,
    update_scene,
    delete_scene
)
from app.schemas.scene_schema import SceneSchema, SceneUpdateSchema

# 🔐 autenticación / permisos
from app.middleware.auth import get_current_user, require_permission

router = APIRouter()

@router.get("/scenes")
def scenes(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_scenes(db)

@router.get("/scenes/script/{id_guion}")
def scenes_by_script(id_guion: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_scenes_by_script(id_guion, db)

@router.get("/scenes/rodaje/{id_rodaje}")
def scenes_by_rodaje(id_rodaje: str, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_scenes_by_rodaje(id_rodaje, db)

@router.get("/scenes/desglose/{id_desglose}")
def scenes_by_desglose(id_desglose: str, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_scenes_by_desglose(id_desglose, db)

@router.get("/scenes/{id}")
def scene(id: str, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_scene(id, db)

# Solo Administrador (1001) y Director (1002) crean/editan/eliminan
# escenas. Jefe de Departamento (1003), Onset (1004) y Usuario (1005)
# no tienen este permiso.
@router.post("/scenes")
def store_scene(scene: SceneSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("create_scenes"))):
    return create_scene(scene, db)

@router.put("/scenes/{id}")
def edit_scene(id: str, scene: SceneSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("create_scenes"))):
    return update_scene_full(id, scene, db)

@router.patch("/scenes/{id}")
def patch_scene(id: str, scene: SceneUpdateSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("create_scenes"))):
    return update_scene(id, scene, db)

@router.delete("/scenes/{id}")
def destroy_scene(id: str, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("create_scenes"))):
    return delete_scene(id, db)
