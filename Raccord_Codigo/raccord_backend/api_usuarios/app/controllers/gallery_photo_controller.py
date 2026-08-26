from fastapi import HTTPException, UploadFile
from fastapi.responses import Response
from sqlalchemy.orm import Session

from app.models.gallery_photo_model import GalleryPhoto
from app.models.scene_model import Scene

from app.utils.response import api_response
from app.utils.minio_client import BUCKET_IMAGENES, upload_file, delete_file, download_file

# Fotos (JPEG/PNG/WEBP), con un tope de tamaño razonable — mismo
# criterio que el PDF de guiones (ver ALLOWED_CONTENT_TYPES en
# script_controller.py). El binario se sube al bucket "imagenes" de
# MinIO, no a la base de datos.
ALLOWED_CONTENT_TYPES = {"image/jpeg", "image/png", "image/webp"}
MAX_FILE_SIZE_BYTES = 15 * 1024 * 1024  # 15 MB


def _serialize(p: GalleryPhoto):
    return {
        "id_foto": p.id_foto,
        "id_escena": p.id_escena,
        "tipo_foto": p.tipo_foto,
        "personaje_codigo": p.personaje_codigo,
        "descripcion": p.descripcion,
        "notas_continuidad": p.notas_continuidad,
        "archivo_nombre": p.archivo_nombre,
        "archivo_tamano": p.archivo_tamano,
        "fecha_subida": p.fecha_subida.isoformat() if p.fecha_subida else None,
    }


# ==========================================
# GET FOTOS DE UNA ESCENA (solo metadatos, sin el binario)
# ==========================================
def get_photos_by_scene(id_escena: str, db: Session):
    scene = db.query(Scene).filter(Scene.id_escena == id_escena).first()

    if not scene:
        return api_response(False, "Escena no encontrada")

    photos = (
        db.query(GalleryPhoto)
        .filter(GalleryPhoto.id_escena == id_escena)
        .order_by(GalleryPhoto.fecha_subida.desc())
        .all()
    )

    return api_response(True, "Fotos de continuidad de la escena", [_serialize(p) for p in photos])


# ==========================================
# UPLOAD FOTO DE CONTINUIDAD
# ==========================================
# multipart/form-data: el archivo llega como UploadFile, los demás
# campos (tipo_foto, personaje_codigo, descripcion, notas_continuidad)
# como Form(...) en la ruta — no se puede usar un schema de Pydantic
# normal junto con un File en el mismo body multipart.
async def upload_photo(
    id_escena: str,
    tipo_foto: str,
    personaje_codigo: str | None,
    descripcion: str | None,
    notas_continuidad: str | None,
    file: UploadFile,
    db: Session,
):
    scene = db.query(Scene).filter(Scene.id_escena == id_escena).first()

    if not scene:
        return api_response(False, "Escena no encontrada", error="SCENE_NOT_FOUND")

    if file.content_type not in ALLOWED_CONTENT_TYPES:
        return api_response(False, "Solo se permiten imágenes JPEG, PNG o WEBP", error="INVALID_FILE_TYPE")

    contenido = await file.read()

    if not contenido:
        return api_response(False, "El archivo está vacío", error="EMPTY_FILE")

    if len(contenido) > MAX_FILE_SIZE_BYTES:
        return api_response(
            False,
            f"El archivo supera el tamaño máximo permitido ({MAX_FILE_SIZE_BYTES // (1024 * 1024)} MB)",
            error="FILE_TOO_LARGE"
        )

    archivo_nombre = file.filename or "foto.jpg"

    photo = GalleryPhoto(
        id_escena=id_escena,
        tipo_foto=tipo_foto or "Set",
        personaje_codigo=personaje_codigo,
        descripcion=descripcion,
        notas_continuidad=notas_continuidad,
        archivo_nombre=archivo_nombre,
        archivo_key="",  # se completa abajo, una vez se conoce id_foto
        archivo_tipo=file.content_type,
        archivo_tamano=len(contenido),
    )

    db.add(photo)
    db.flush()  # asigna id_foto (autoincrement) sin cerrar la transacción

    object_key = f"{id_escena}/{photo.id_foto}_{archivo_nombre}"
    upload_file(BUCKET_IMAGENES, object_key, contenido, file.content_type)
    photo.archivo_key = object_key

    db.commit()
    db.refresh(photo)

    return api_response(True, "Foto cargada correctamente", _serialize(photo))


# ==========================================
# GET FOTO (visualizar / descargar)
# ==========================================
# Igual que con los guiones: el endpoint valida JWT (ver
# gallery_photo_routes.py) y recién ahí el backend trae el binario de
# MinIO y lo devuelve directo, en vez de redirigir al navegador a una
# URL de MinIO (eso rompía por CORS - ver nota en
# app/utils/minio_client.py).
def get_photo_archivo(id_foto: str, db: Session):
    photo = db.query(GalleryPhoto).filter(GalleryPhoto.id_foto == id_foto).first()

    if not photo:
        raise HTTPException(status_code=404, detail="Foto no encontrada")

    try:
        contenido = download_file(BUCKET_IMAGENES, photo.archivo_key)
    except Exception:
        raise HTTPException(status_code=404, detail="No se pudo recuperar el archivo desde el almacenamiento")

    return Response(
        content=contenido,
        media_type=photo.archivo_tipo,
        headers={"Content-Disposition": f'inline; filename="{photo.archivo_nombre}"'}
    )


# ==========================================
# DELETE FOTO
# ==========================================
def delete_photo(id_foto: str, db: Session):
    photo = db.query(GalleryPhoto).filter(GalleryPhoto.id_foto == id_foto).first()

    if not photo:
        return api_response(False, "Foto no encontrada")

    # Se borra también el archivo en MinIO.
    delete_file(BUCKET_IMAGENES, photo.archivo_key)

    db.delete(photo)
    db.commit()

    return api_response(True, "Foto eliminada")
