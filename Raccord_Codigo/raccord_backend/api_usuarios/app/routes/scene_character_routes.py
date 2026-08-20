from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.config.database import get_db
from app.controllers.scene_character_controller import (
    get_cast_by_scene,
    add_character_to_scene,
    remove_character_from_scene
)
from app.schemas.scene_character_schema import SceneCharacterSchema

# 🔐 autenticación / permisos
from app.middleware.auth import get_current_user, require_permission

router = APIRouter()

@router.get("/scenes/{id_escena}/cast")
def cast_by_scene(id_escena: str, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_cast_by_scene(id_escena, db)

# Mismo permiso que crear personajes/escenas: Administrador (1001) y
# Director (1002) arman el cast de cada escena.
@router.post("/scenes/{id_escena}/cast")
def store_cast(id_escena: str, data: SceneCharacterSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("create_characters"))):
    return add_character_to_scene(id_escena, data, db)

@router.delete("/scenes/{id_escena}/cast/{id_personaje}")
def destroy_cast(id_escena: str, id_personaje: str, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("create_characters"))):
    return remove_character_from_scene(id_escena, id_personaje, db)
