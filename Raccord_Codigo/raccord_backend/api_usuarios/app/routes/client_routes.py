from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.config.database import get_db
from app.controllers.client_controller import (
    get_clients,
    get_client,
    create_client,
    update_client_full,
    update_client,
    delete_client
)
from app.schemas.client_schema import ClientSchema, ClientUpdateSchema

# 🔐 autenticación / permisos
from app.middleware.auth import get_current_user, require_permission

router = APIRouter()

@router.get("/clients")
def clients(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_clients(db)

@router.get("/clients/{id}")
def client(id: str, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_client(id, db)

@router.post("/clients")
def store_client(client: ClientSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("full_management"))):
    return create_client(client, db)

@router.put("/clients/{id}")
def edit_client(id: str, client: ClientSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("full_management"))):
    return update_client_full(id, client, db)

@router.patch("/clients/{id}")
def patch_client(id: str, client: ClientUpdateSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("full_management"))):
    return update_client(id, client, db)

@router.delete("/clients/{id}")
def destroy_client(id: str, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("full_management"))):
    return delete_client(id, db)
