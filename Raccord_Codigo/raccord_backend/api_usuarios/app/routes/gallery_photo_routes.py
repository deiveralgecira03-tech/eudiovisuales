from fastapi import APIRouter, Depends, File, Form, UploadFile
from sqlalchemy.orm import Session
from app.config.database import get_db
from app.controllers.gallery_photo_controller import (
    get_photos_by_scene,
    get_all_photos,
    upload_photo,
    get_photo_archivo,
    delete_photo,
)
from app.models.scene_model import Scene
from app.models.gallery_photo_model import GalleryPhoto

# 🔐 autenticación / permisos — resueltos por proyecto, ver
# app/utils/project_scope.py. GalleryPhoto/Scene no tienen columna
# id_project propia: se resuelve subiendo por id_escena -> id_guion ->
# guiones.id_project.
from app.utils.project_scope import (
    require_project_member,
    require_record_project_permission,
    resolve_project_of_scene,
    resolve_project_via_scene_fk,
)

router = APIRouter()


# Ver las fotos de continuidad de una escena: cualquier miembro del
# proyecto de esa escena.
@router.get("/scenes/{id_escena}/fotos")
def photos_by_scene(
    id_escena: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_record_project_permission(
        None, model=Scene, pk_column="id_escena", pk_path_param="id_escena",
        resolve_project=resolve_project_of_scene, not_found_message="Escena no encontrada",
    )),
):
    return get_photos_by_scene(id_escena, db)


# Galería global de UN proyecto — antes /fotos sin filtro devolvía las
# fotos de TODOS los proyectos.
@router.get("/fotos/project/{id_project}")
def all_photos(id_project: str, db: Session = Depends(get_db), current_user: dict = Depends(require_project_member())):
    return get_all_photos(id_project, db)


# Subir foto: permiso "upload_photos" (Administrador, Director, Jefe
# de Departamento y Onset lo tienen; Usuario no — ver
# app/utils/permissions.py) — resuelto dentro del proyecto de la
# escena a la que se sube la foto.
@router.post("/scenes/{id_escena}/fotos")
async def store_photo(
    id_escena: str,
    tipo_foto: str = Form("Set"),
    personaje_codigo: str | None = Form(None),
    descripcion: str | None = Form(None),
    notas_continuidad: str | None = Form(None),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_record_project_permission(
        "upload_photos", model=Scene, pk_column="id_escena", pk_path_param="id_escena",
        resolve_project=resolve_project_of_scene, not_found_message="Escena no encontrada",
    )),
):
    return await upload_photo(id_escena, tipo_foto, personaje_codigo, descripcion, notas_continuidad, file, db)


# Ver/descargar el binario de la foto: cualquier miembro del proyecto
# dueño de la escena de esa foto.
@router.get("/fotos/{id_foto}/archivo")
def download_photo_file(
    id_foto: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_record_project_permission(
        None, model=GalleryPhoto, pk_column="id_foto", pk_path_param="id_foto",
        resolve_project=resolve_project_via_scene_fk("id_escena"), not_found_message="Foto no encontrada",
    )),
):
    return get_photo_archivo(id_foto, db)


# Eliminar foto: mismo permiso que subirla, resuelto contra el proyecto
# de la escena dueña de la foto.
@router.delete("/fotos/{id_foto}")
def destroy_photo(
    id_foto: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_record_project_permission(
        "upload_photos", model=GalleryPhoto, pk_column="id_foto", pk_path_param="id_foto",
        resolve_project=resolve_project_via_scene_fk("id_escena"), not_found_message="Foto no encontrada",
    )),
):
    return delete_photo(id_foto, db)
