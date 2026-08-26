from sqlalchemy.orm import Session

from app.models.scene_model import Scene

from app.schemas.scene_schema import SceneSchema

from app.utils.response import api_response


# ==========================================
# SERIALIZAR ESCENA
# ==========================================
def _serialize(s: Scene):
    return {
        "id_escena": s.id_escena,
        "numero_de_escena": s.numero_de_escena,
        "encabezado": s.encabezado,
        "descripcion": s.descripcion,
        "id_guion": s.id_guion,
        "modo_vista": s.modo_vista,
        "momento_dia": s.momento_dia,
        "ciudad": s.ciudad,
        "pagina": s.pagina,
        "fecha_de_grabacion": str(s.fecha_de_grabacion) if s.fecha_de_grabacion else None,
        "dia_dramatico": s.dia_dramatico,
        "id_rodaje": s.id_rodaje,
        "id_desglose": s.id_desglose,
        "estado": s.estado,
        "locacion_rodaje": s.locacion_rodaje,
        "tiempo_estimado": s.tiempo_estimado,
        "hora_inicio_rodaje": str(s.hora_inicio_rodaje) if s.hora_inicio_rodaje else None,
        "notas_rodaje": s.notas_rodaje,
        "orden_rodaje": s.orden_rodaje
    }


# ==========================================
# GET ALL SCENES
# ==========================================
def get_scenes(db: Session):
    scenes = db.query(Scene).order_by(Scene.id_escena).all()
    return api_response(True, "Lista de escenas", [_serialize(s) for s in scenes])


# ==========================================
# GET SCENE BY ID
# ==========================================
def get_scene(id: str, db: Session):
    scene = db.query(Scene).filter(Scene.id_escena == id).first()

    if not scene:
        return api_response(False, "Escena no encontrada")

    return api_response(True, "Escena encontrada", _serialize(scene))


# ==========================================
# GET SCENES BY SCRIPT (GUION)
# ==========================================
def get_scenes_by_script(id_guion: str, db: Session):
    scenes = db.query(Scene).filter(Scene.id_guion == id_guion).order_by(Scene.id_escena).all()
    return api_response(True, "Escenas del guion", [_serialize(s) for s in scenes])


# ==========================================
# GET SCENES BY SHOOTING DAY (PLAN DE RODAJE)
# ==========================================
def get_scenes_by_rodaje(id_rodaje: str, db: Session):
    scenes = db.query(Scene).filter(Scene.id_rodaje == id_rodaje).order_by(Scene.id_escena).all()
    return api_response(True, "Escenas del día de rodaje", [_serialize(s) for s in scenes])


# ==========================================
# GET SCENES BY BREAKDOWN SHEET (DESGLOSE)
# ==========================================
def get_scenes_by_desglose(id_desglose: str, db: Session):
    scenes = db.query(Scene).filter(Scene.id_desglose == id_desglose).order_by(Scene.id_escena).all()
    return api_response(True, "Escenas del desglose", [_serialize(s) for s in scenes])


# ==========================================
# CREATE SCENE
# ==========================================
def create_scene(scene: SceneSchema, db: Session):
    new_scene = Scene(
        numero_de_escena=scene.numero_de_escena,
        encabezado=scene.encabezado,
        descripcion=scene.descripcion,
        id_guion=scene.id_guion,
        modo_vista=scene.modo_vista,
        momento_dia=scene.momento_dia,
        ciudad=scene.ciudad,
        pagina=scene.pagina,
        fecha_de_grabacion=scene.fecha_de_grabacion,
        dia_dramatico=scene.dia_dramatico,
        id_rodaje=scene.id_rodaje,
        id_desglose=scene.id_desglose,
        estado=scene.estado or "Pendiente",
        locacion_rodaje=scene.locacion_rodaje,
        tiempo_estimado=scene.tiempo_estimado,
        hora_inicio_rodaje=scene.hora_inicio_rodaje,
        notas_rodaje=scene.notas_rodaje,
        orden_rodaje=scene.orden_rodaje
    )

    db.add(new_scene)
    db.commit()
    db.refresh(new_scene)

    return api_response(True, "Escena creada", _serialize(new_scene))


# ==========================================
# UPDATE SCENE (PUT - completo)
# ==========================================
def update_scene_full(id: str, scene: SceneSchema, db: Session):
    scene_db = db.query(Scene).filter(Scene.id_escena == id).first()

    if not scene_db:
        return api_response(False, "Escena no encontrada")

    scene_db.numero_de_escena = scene.numero_de_escena
    scene_db.encabezado = scene.encabezado
    scene_db.descripcion = scene.descripcion
    scene_db.id_guion = scene.id_guion
    scene_db.modo_vista = scene.modo_vista
    scene_db.momento_dia = scene.momento_dia
    scene_db.ciudad = scene.ciudad
    scene_db.pagina = scene.pagina
    scene_db.fecha_de_grabacion = scene.fecha_de_grabacion
    scene_db.dia_dramatico = scene.dia_dramatico
    scene_db.id_rodaje = scene.id_rodaje
    scene_db.id_desglose = scene.id_desglose
    scene_db.estado = scene.estado or scene_db.estado
    scene_db.locacion_rodaje = scene.locacion_rodaje
    scene_db.tiempo_estimado = scene.tiempo_estimado
    scene_db.hora_inicio_rodaje = scene.hora_inicio_rodaje
    scene_db.notas_rodaje = scene.notas_rodaje
    scene_db.orden_rodaje = scene.orden_rodaje

    db.commit()
    db.refresh(scene_db)

    return api_response(True, "Escena actualizada", _serialize(scene_db))


# ==========================================
# UPDATE SCENE (PATCH - parcial)
# ==========================================
def update_scene(id: str, scene, db: Session):
    scene_db = db.query(Scene).filter(Scene.id_escena == id).first()

    if not scene_db:
        return api_response(False, "Escena no encontrada")

    update_data = scene.model_dump(exclude_unset=True)

    for key, value in update_data.items():
        setattr(scene_db, key, value)

    db.commit()
    db.refresh(scene_db)

    return api_response(True, "Escena actualizada", _serialize(scene_db))


# ==========================================
# DELETE SCENE
# ==========================================
# escenas_personajes.id_escena tiene FK ON DELETE CASCADE hacia
# escenas, pero es solo una tabla de relación (no borra personajes,
# solo el vínculo), así que no hace falta bloquear el borrado como se
# hizo con departamentos. Cuando exista el módulo de personajes, vale
# la pena revisar si conviene avisar cuántos vínculos se van a perder.
def delete_scene(id: str, db: Session):
    scene = db.query(Scene).filter(Scene.id_escena == id).first()

    if not scene:
        return api_response(False, "Escena no encontrada")

    db.delete(scene)
    db.commit()

    return api_response(True, "Escena eliminada")
