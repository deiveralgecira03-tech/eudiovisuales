from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.config.database import get_db
from app.controllers.character_controller import (
    get_characters,
    get_character,
    create_character,
    update_character_full,
    update_character,
    delete_character
)
from app.schemas.character_schema import CharacterSchema, CharacterUpdateSchema

# 🔐 autenticación / permisos
from app.middleware.auth import get_current_user, require_permission

router = APIRouter()

@router.get("/characters")
def characters(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_characters(db)

@router.get("/characters/{id}")
def character(id: str, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_character(id, db)

# Solo Administrador (1001) y Director (1002) crean/editan/eliminan
# personajes (permiso "create_characters", ya definido en la matriz RBAC).
@router.post("/characters")
def store_character(character: CharacterSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("create_characters"))):
    return create_character(character, db)

@router.put("/characters/{id}")
def edit_character(id: str, character: CharacterSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("create_characters"))):
    return update_character_full(id, character, db)

@router.patch("/characters/{id}")
def patch_character(id: str, character: CharacterUpdateSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("create_characters"))):
    return update_character(id, character, db)

@router.delete("/characters/{id}")
def destroy_character(id: str, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("create_characters"))):
    return delete_character(id, db)
