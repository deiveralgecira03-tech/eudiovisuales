from fastapi import APIRouter, Depends, File, Form, UploadFile
from sqlalchemy.orm import Session
from app.config.database import get_db
from app.controllers.gallery_photo_controller import (
    get_photos_by_scene,
    upload_photo,
    get_photo_archivo,
    delete_photo,
)

# 🔐 autenticación / permisos
from app.middleware.auth import get_current_user, require_permission

router = APIRouter()


# Ver las fotos de continuidad de una escena: cualquier usuario
# autenticado (mismo nivel que ver la escena/el guion).
@router.get("/scenes/{id_escena}/fotos")
def photos_by_scene(id_escena: str, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_photos_by_scene(id_escena, db)


# Subir foto: permiso "upload_photos" (Administrador, Director, Jefe
# de Departamento y Onset lo tienen; Usuario no — ver
# app/utils/permissions.py).
@router.post("/scenes/{id_escena}/fotos")
async def store_photo(
    id_escena: str,
    tipo_foto: str = Form("Set"),
    personaje_codigo: str | None = Form(None),
    descripcion: str | None = Form(None),
    notas_continuidad: str | None = Form(None),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_permission("upload_photos")),
):
    return await upload_photo(id_escena, tipo_foto, personaje_codigo, descripcion, notas_continuidad, file, db)


# Ver/descargar el binario de la foto: cualquier usuario autenticado.
@router.get("/fotos/{id_foto}/archivo")
def download_photo_file(id_foto: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    return get_photo_archivo(id_foto, db)


# Eliminar foto: mismo permiso que subirla.
@router.delete("/fotos/{id_foto}")
def destroy_photo(id_foto: int, db: Session = Depends(get_db), current_user: dict = Depends(require_permission("upload_photos"))):
    return delete_photo(id_foto, db)
