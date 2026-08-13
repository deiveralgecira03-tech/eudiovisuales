from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.config.database import get_db
from app.controllers.shooting_day_controller import (
    get_shooting_days,
    get_shooting_day,
    create_shooting_day,
    update_shooting_day_full,
    update_shooting_day,
    delete_shooting_day
)
from app.schemas.shooting_day_schema import ShootingDaySchema, ShootingDayUpdateSchema

# 🔐 autenticación / permisos
from app.middleware.auth import get_current_user, require_permission

router = APIRouter()

@router.get("/shooting-days")
def shooting_days(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_shooting_days(db)

@router.get("/shooting-days/{id}")
def shooting_day(id: str, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_shooting_day(id, db)

# Mismo permiso que crear escenas: Administrador (1001) y Director
# (1002) arman el plan de rodaje; el resto de roles solo lo consulta.
@router.post("/shooting-days")
def store_shooting_day(day: ShootingDaySchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("create_scenes"))):
    return create_shooting_day(day, db)

@router.put("/shooting-days/{id}")
def edit_shooting_day(id: str, day: ShootingDaySchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("create_scenes"))):
    return update_shooting_day_full(id, day, db)

@router.patch("/shooting-days/{id}")
def patch_shooting_day(id: str, day: ShootingDayUpdateSchema, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("create_scenes"))):
    return update_shooting_day(id, day, db)

@router.delete("/shooting-days/{id}")
def destroy_shooting_day(id: str, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("create_scenes"))):
    return delete_shooting_day(id, db)
