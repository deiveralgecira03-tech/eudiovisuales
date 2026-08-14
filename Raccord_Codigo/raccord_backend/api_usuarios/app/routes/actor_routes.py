from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.config.database import get_db
from app.controllers.actor_controller import (
    get_actors,
    get_actor,
    create_actor,
    update_actor_full,
    update_actor,
    delete_actor
)
from app.schemas.actor_schema import ActorSchema, ActorUpdateSchema

from app.middleware.auth import get_current_user, require_permission

router = APIRouter()

@router.get("/actors")
def actors(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_actors(db)

@router.get("/actors/{id}")
def actor(id: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_actor(id, db)

@router.post("/actors")
def store_actor(actor: ActorSchema, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return create_actor(actor, db)

@router.put("/actors/{id}")
def edit_actor(id: int, actor: ActorSchema, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return update_actor_full(id, actor, db)

@router.patch("/actors/{id}")
def patch_actor(id: int, actor: ActorUpdateSchema, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return update_actor(id, actor, db)

@router.delete("/actors/{id}")
def destroy_actor(id: int, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("full_management"))):
    return delete_actor(id, db)
