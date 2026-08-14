from sqlalchemy.orm import Session
from app.models.actor_model import Actor
from app.schemas.actor_schema import ActorSchema
from app.utils.response import api_response


# GET ALL ACTORS

def get_actors(db: Session):
    actors = db.query(Actor).all()
    actors_list = [
        {
            "id_actor": a.id_actor,
            "nombre": a.nombre,
            "apellido": a.apellido,
            "email": a.email,
            "telefono": a.telefono,
            "activo": a.activo
        }
        for a in actors
    ]
    return api_response(True, "Lista de actores", actors_list)


# GET ACTOR BY ID

def get_actor(id: int, db: Session):
    actor = db.query(Actor).filter(Actor.id_actor == id).first()

    if not actor:
        return api_response(False, "Actor no encontrado")

    return api_response(True, "Actor encontrado", {
        "id_actor": actor.id_actor,
        "nombre": actor.nombre,
        "apellido": actor.apellido,
        "email": actor.email,
        "telefono": actor.telefono,
        "activo": actor.activo
    })


# CREATE ACTOR

def create_actor(actor: ActorSchema, db: Session):
    new_actor = Actor(
        nombre=actor.nombre,
        apellido=actor.apellido,
        email=actor.email,
        telefono=actor.telefono,
        activo=actor.activo
    )

    db.add(new_actor)
    db.commit()
    db.refresh(new_actor)

    return api_response(True, "Actor creado", {
        "id_actor": new_actor.id_actor,
        "nombre": new_actor.nombre,
        "apellido": new_actor.apellido
    })


# UPDATE ACTOR (PUT)

def update_actor_full(id: int, actor: ActorSchema, db: Session):
    actor_db = db.query(Actor).filter(Actor.id_actor == id).first()

    if not actor_db:
        return api_response(False, "Actor no encontrado")

    actor_db.nombre = actor.nombre
    actor_db.apellido = actor.apellido
    actor_db.email = actor.email
    actor_db.telefono = actor.telefono
    actor_db.activo = actor.activo

    db.commit()
    db.refresh(actor_db)

    return api_response(True, "Actor actualizado", {
        "id_actor": actor_db.id_actor,
        "nombre": actor_db.nombre
    })


# UPDATE ACTOR (PATCH)

def update_actor(id: int, actor, db: Session):
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


# DELETE ACTOR

def delete_actor(id: int, db: Session):
    actor = db.query(Actor).filter(Actor.id_actor == id).first()

    if not actor:
        return api_response(False, "Actor no encontrado")

    db.delete(actor)
    db.commit()

    return api_response(True, "Actor eliminado")
