from sqlalchemy.orm import Session
from app.models.actor_model import Actor
from app.schemas.actor_schema import ActorSchema
from app.utils.response import api_response


def _actor_to_dict(a: Actor):
    return {
        "id_actor": a.id_actor,
        "nombre": a.nombre,
        "apellido": a.apellido,
        "genero": a.genero,
        "fecha_de_nacimiento": a.fecha_de_nacimiento,
        "talla_zapatos": a.talla_zapatos,
        "ancho_espalda": a.ancho_espalda,
        "pecho": a.pecho,
        "cintura": a.cintura,
        "cadera": a.cadera,
        "largo_manga": a.largo_manga,
        "largo_pierna": a.largo_pierna,
        "talla_anillo": a.talla_anillo,
        "contorno_cabeza": a.contorno_cabeza,
        "contorno_cuello": a.contorno_cuello,
        "color_cabello": a.color_cabello,
        "textura_cabello": a.textura_cabello,
        "tipo_piel": a.tipo_piel,
        "color_ojos": a.color_ojos,
        "alergias": a.alergias,
        "habilidades_especiales": a.habilidades_especiales,
        "restricciones": a.restricciones,
        "comentarios_adicionales": a.comentarios_adicionales,
        "nacionalidad": a.nacionalidad,
        "doble_riesgo": a.doble_riesgo,
        "id_personaje": a.id_personaje
    }


def get_actors(db: Session):
    actors = db.query(Actor).all()
    return api_response(True, "Lista de actores", [_actor_to_dict(a) for a in actors])


def get_actor(id: str, db: Session):
    actor = db.query(Actor).filter(Actor.id_actor == id).first()

    if not actor:
        return api_response(False, "Actor no encontrado")

    return api_response(True, "Actor encontrado", _actor_to_dict(actor))


def create_actor(actor: ActorSchema, db: Session):
    new_actor = Actor(**actor.model_dump())

    db.add(new_actor)
    db.commit()
    db.refresh(new_actor)

    return api_response(True, "Actor creado", {
        "id_actor": new_actor.id_actor,
        "nombre": new_actor.nombre,
        "apellido": new_actor.apellido
    })


def update_actor_full(id: str, actor: ActorSchema, db: Session):
    actor_db = db.query(Actor).filter(Actor.id_actor == id).first()

    if not actor_db:
        return api_response(False, "Actor no encontrado")

    for key, value in actor.model_dump().items():
        setattr(actor_db, key, value)

    db.commit()
    db.refresh(actor_db)

    return api_response(True, "Actor actualizado", {
        "id_actor": actor_db.id_actor,
        "nombre": actor_db.nombre
    })


def update_actor(id: str, actor, db: Session):
    actor_db = db.query(Actor).filter(Actor.id_actor == id).first()

    if not actor_db:
        return api_response(False, "Actor no encontrado")

    update_data = actor.model_dump(exclude_unset=True)

    for key, value in update_data.items():
        setattr(actor_db, key, value)

    db.commit()
    db.refresh(actor_db)

    return api_response(True, "Actor actualizado", {
        "id_actor": actor_db.id_actor,
        "nombre": actor_db.nombre
    })


def delete_actor(id: str, db: Session):
    actor = db.query(Actor).filter(Actor.id_actor == id).first()

    if not actor:
        return api_response(False, "Actor no encontrado")

    db.delete(actor)
    db.commit()

    return api_response(True, "Actor eliminado")
