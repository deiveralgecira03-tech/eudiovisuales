from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.config.database import get_db
from app.controllers.breakdown_controller import (
    get_items_by_scene,
    get_item,
    create_item,
    update_item_full,
    update_item,
    delete_item,
    get_detalle_by_item,
    create_detalle,
    update_detalle_full,
    update_detalle,
    delete_detalle,
    get_pendientes_mi_departamento
)
from app.schemas.breakdown_schema import (
    DesgloseItemSchema,
    DesgloseItemUpdateSchema,
    DesgloseDetalleSchema,
    DesgloseDetalleUpdateSchema
)

# 🔐 autenticación / permisos
from app.middleware.auth import get_current_user, require_permission

router = APIRouter()


# ==========================================
# NIVEL GENERAL (desglose_items)
# ==========================================
# Lectura abierta a cualquier usuario autenticado. Escritura solo
# Administrador/Director (permiso "manage_general_breakdown").
@router.get("/breakdown/items/scene/{id_escena}")
def items_by_scene(id_escena: str, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_items_by_scene(id_escena, db)

@router.get("/breakdown/items/{id}")
def item(id: str, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_item(id, db)

@router.post("/breakdown/items")
def store_item(item: DesgloseItemSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("manage_general_breakdown"))):
    return create_item(item, db, current_user)

@router.put("/breakdown/items/{id}")
def edit_item(id: str, item: DesgloseItemSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("manage_general_breakdown"))):
    return update_item_full(id, item, db)

@router.patch("/breakdown/items/{id}")
def patch_item(id: str, item: DesgloseItemUpdateSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("manage_general_breakdown"))):
    return update_item(id, item, db)

@router.delete("/breakdown/items/{id}")
def destroy_item(id: str, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("manage_general_breakdown"))):
    return delete_item(id, db)


# ==========================================
# NIVEL ESPECIFICO (desglose_item_detalle)
# ==========================================
# require_permission bloquea por ROL (Administrador/Director quedan
# fuera porque en la matriz view/edit_department_breakdown son False
# para ellos). El match por id_departamento se valida además dentro
# del controller.
@router.get("/breakdown/items/{id_desglose_item}/detalle")
def detalle_by_item(id_desglose_item: str, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("view_department_breakdown"))):
    return get_detalle_by_item(id_desglose_item, db, current_user)

@router.post("/breakdown/items/{id_desglose_item}/detalle")
def store_detalle(id_desglose_item: str, detalle: DesgloseDetalleSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("edit_department_breakdown"))):
    return create_detalle(id_desglose_item, detalle, db, current_user)

@router.put("/breakdown/detalle/{id}")
def edit_detalle(id: str, detalle: DesgloseDetalleSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("edit_department_breakdown"))):
    return update_detalle_full(id, detalle, db, current_user)

@router.patch("/breakdown/detalle/{id}")
def patch_detalle(id: str, detalle: DesgloseDetalleUpdateSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("edit_department_breakdown"))):
    return update_detalle(id, detalle, db, current_user)

@router.delete("/breakdown/detalle/{id}")
def destroy_detalle(id: str, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("edit_department_breakdown"))):
    return delete_detalle(id, db, current_user)


# ==========================================
# PENDIENTES DEL PROPIO DEPARTAMENTO
# ==========================================
@router.get("/breakdown/pendientes")
def pendientes_mi_departamento(db: Session = Depends(get_db), current_user: dict = Depends(require_permission("view_department_breakdown"))):
    return get_pendientes_mi_departamento(db, current_user)
