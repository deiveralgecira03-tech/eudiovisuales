from sqlalchemy.orm import Session

from app.models.script_model import Script
from app.models.scene_model import Scene

from app.schemas.script_schema import ScriptSchema

from app.utils.response import api_response


# ==========================================
# GET ALL SCRIPTS
# ==========================================
def get_scripts(db: Session):
    scripts = db.query(Script).order_by(Script.id_guion).all()

    scripts_list = [
        {
            "id_guion": s.id_guion,
            "numero_de_version": s.numero_de_version,
            "fecha_de_emision": str(s.fecha_de_emision),
            "estado": s.estado,
            "archivo": s.archivo,
            "nombre": s.nombre,
            "descripcion": s.descripcion,
            "id_project": s.id_project
        }
        for s in scripts
    ]

    return api_response(True, "Lista de guiones", scripts_list)


# ==========================================
# GET SCRIPT BY ID
# ==========================================
def get_script(id: int, db: Session):
    script = db.query(Script).filter(Script.id_guion == id).first()

    if not script:
        return api_response(False, "Guion no encontrado")

    return api_response(True, "Guion encontrado", {
        "id_guion": script.id_guion,
        "numero_de_version": script.numero_de_version,
        "fecha_de_emision": str(script.fecha_de_emision),
        "estado": script.estado,
        "archivo": script.archivo,
        "nombre": script.nombre,
        "descripcion": script.descripcion,
        "id_project": script.id_project
    })


# ==========================================
# GET SCRIPTS BY PROJECT
# ==========================================
def get_scripts_by_project(id_project: str, db: Session):
    scripts = db.query(Script).filter(Script.id_project == id_project).order_by(Script.id_guion).all()

    scripts_list = [
        {
            "id_guion": s.id_guion,
            "numero_de_version": s.numero_de_version,
            "fecha_de_emision": str(s.fecha_de_emision),
            "estado": s.estado,
            "archivo": s.archivo,
            "nombre": s.nombre,
            "descripcion": s.descripcion,
            "id_project": s.id_project
        }
        for s in scripts
    ]

    return api_response(True, "Guiones del proyecto", scripts_list)


# ==========================================
# CREATE SCRIPT
# ==========================================
def create_script(script: ScriptSchema, db: Session):
    existing = db.query(Script).filter(Script.numero_de_version == script.numero_de_version).first()

    if existing:
        return api_response(False, "Ya existe un guion con ese número de versión", error="DUPLICATE_VERSION")

    new_script = Script(
        numero_de_version=script.numero_de_version,
        fecha_de_emision=script.fecha_de_emision,
        estado=script.estado,
        archivo=script.archivo,
        nombre=script.nombre,
        descripcion=script.descripcion,
        id_project=script.id_project
    )

    db.add(new_script)
    db.commit()
    db.refresh(new_script)

    return api_response(True, "Guion creado", {
        "id_guion": new_script.id_guion,
        "numero_de_version": new_script.numero_de_version,
        "nombre": new_script.nombre,
        "id_project": new_script.id_project
    })


# ==========================================
# UPDATE SCRIPT (PUT - completo)
# ==========================================
def update_script_full(id: int, script: ScriptSchema, db: Session):
    script_db = db.query(Script).filter(Script.id_guion == id).first()

    if not script_db:
        return api_response(False, "Guion no encontrado")

    version_exists = db.query(Script).filter(
        Script.numero_de_version == script.numero_de_version,
        Script.id_guion != id
    ).first()

    if version_exists:
        return api_response(False, "Ya existe otro guion con ese número de versión", error="DUPLICATE_VERSION")

    script_db.numero_de_version = script.numero_de_version
    script_db.fecha_de_emision = script.fecha_de_emision
    script_db.estado = script.estado
    script_db.archivo = script.archivo
    script_db.nombre = script.nombre
    script_db.descripcion = script.descripcion
    script_db.id_project = script.id_project

    db.commit()
    db.refresh(script_db)

    return api_response(True, "Guion actualizado", {
        "id_guion": script_db.id_guion,
        "numero_de_version": script_db.numero_de_version,
        "nombre": script_db.nombre
    })


# ==========================================
# UPDATE SCRIPT (PATCH - parcial)
# ==========================================
def update_script(id: int, script, db: Session):
    script_db = db.query(Script).filter(Script.id_guion == id).first()

    if not script_db:
        return api_response(False, "Guion no encontrado")

    update_data = script.model_dump(exclude_unset=True)

    if "numero_de_version" in update_data:
        version_exists = db.query(Script).filter(
            Script.numero_de_version == update_data["numero_de_version"],
            Script.id_guion != id
        ).first()

        if version_exists:
            return api_response(False, "Ya existe otro guion con ese número de versión", error="DUPLICATE_VERSION")

    for key, value in update_data.items():
        setattr(script_db, key, value)

    db.commit()
    db.refresh(script_db)

    return api_response(True, "Guion actualizado", {
        "id_guion": script_db.id_guion,
        "numero_de_version": script_db.numero_de_version,
        "nombre": script_db.nombre
    })


# ==========================================
# DELETE SCRIPT
# ==========================================
# En la BD, escenas.id_guion tiene FK ON DELETE CASCADE hacia guiones.
# Ahora que existe el modelo Scene, se bloquea el borrado si el guion
# todavía tiene escenas asociadas, igual que se hace en
# delete_department con los usuarios de un departamento.
def delete_script(id: int, db: Session):
    script = db.query(Script).filter(Script.id_guion == id).first()

    if not script:
        return api_response(False, "Guion no encontrado")

    scenes_in_script = db.query(Scene).filter(Scene.id_guion == id).count()

    if scenes_in_script > 0:
        return api_response(
            False,
            f"No se puede eliminar: hay {scenes_in_script} escena(s) asociadas a este guion",
            error="SCRIPT_IN_USE"
        )

    db.delete(script)
    db.commit()

    return api_response(True, "Guion eliminado")
