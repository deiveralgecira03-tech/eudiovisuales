from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.config.database import get_db
from app.controllers.breakdown_sheet_controller import (
    get_breakdown_sheets,
    get_breakdown_sheet,
    create_breakdown_sheet,
    update_breakdown_sheet_full,
    update_breakdown_sheet,
    delete_breakdown_sheet
)
from app.schemas.breakdown_sheet_schema import BreakdownSheetSchema, BreakdownSheetUpdateSchema

# 🔐 autenticación / permisos
from app.middleware.auth import get_current_user, require_permission

router = APIRouter()

@router.get("/breakdown-sheets")
def breakdown_sheets(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_breakdown_sheets(db)

@router.get("/breakdown-sheets/{id}")
def breakdown_sheet(id: str, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_breakdown_sheet(id, db)

# Mismo permiso que crear escenas: Administrador (1001) y Director
# (1002) arman el contenedor del desglose; el resto de roles solo lo
# consulta (y, en /breakdown/items, ve el desglose general por
# categoría de cada escena).
@router.post("/breakdown-sheets")
def store_breakdown_sheet(sheet: BreakdownSheetSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("create_scenes"))):
    return create_breakdown_sheet(sheet, db)

@router.put("/breakdown-sheets/{id}")
def edit_breakdown_sheet(id: str, sheet: BreakdownSheetSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("create_scenes"))):
    return update_breakdown_sheet_full(id, sheet, db)

@router.patch("/breakdown-sheets/{id}")
def patch_breakdown_sheet(id: str, sheet: BreakdownSheetUpdateSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("create_scenes"))):
    return update_breakdown_sheet(id, sheet, db)

@router.delete("/breakdown-sheets/{id}")
def destroy_breakdown_sheet(id: str, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("create_scenes"))):
    return delete_breakdown_sheet(id, db)
