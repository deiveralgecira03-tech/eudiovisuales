from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.config.database import get_db
from app.controllers.personaje_controller import (
    get_personajes,
    get_personaje,
    get_personajes_by_project,
    create_personaje,
    update_personaje_full,
    update_personaje,
    delete_personaje
)
from app.schemas.personaje_schema import PersonajeSchema, PersonajeUpdateSchema

from app.middleware.auth import get_current_user, require_permission

router = APIRouter()

@router.get("/personajes")
def personajes(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_personajes(db)

@router.get("/personajes/{id}")
def personaje(id: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_personaje(id, db)

@router.get("/projects/{id_project}/personajes")
def personajes_by_project(id_project: str, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_personajes_by_project(id_project, db)

@router.post("/personajes")
def store_personaje(personaje: PersonajeSchema, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return create_personaje(personaje, db)

@router.put("/personajes/{id}")
def edit_personaje(id: int, personaje: PersonajeSchema, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return update_personaje_full(id, personaje, db)

@router.patch("/personajes/{id}")
def patch_personaje(id: int, personaje: PersonajeUpdateSchema, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return update_personaje(id, personaje, db)

@router.delete("/personajes/{id}")
def destroy_personaje(id: int, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("full_management"))):
    return delete_personaje(id, db)
