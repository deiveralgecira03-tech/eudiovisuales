from sqlalchemy.orm import Session
from app.models.personaje_model import Personaje
from app.schemas.personaje_schema import PersonajeSchema
from app.utils.response import api_response


# GET ALL PERSONAJES

def get_personajes(db: Session):
    personajes = db.query(Personaje).all()
    personajes_list = [
        {
            "id_personaje": p.id_personaje,
            "nombre_personaje": p.nombre_personaje,
            "descripcion": p.descripcion,
            "id_project": p.id_project,
            "id_actor": p.id_actor
        }
        for p in personajes
    ]
    return api_response(True, "Lista de personajes", personajes_list)


# GET PERSONAJE BY ID

def get_personaje(id: int, db: Session):
    personaje = db.query(Personaje).filter(Personaje.id_personaje == id).first()

    if not personaje:
        return api_response(False, "Personaje no encontrado")

    return api_response(True, "Personaje encontrado", {
        "id_personaje": personaje.id_personaje,
        "nombre_personaje": personaje.nombre_personaje,
        "descripcion": personaje.descripcion,
        "id_project": personaje.id_project,
        "id_actor": personaje.id_actor
    })


# GET PERSONAJES BY PROJECT

def get_personajes_by_project(id_project: str, db: Session):
    personajes = db.query(Personaje).filter(Personaje.id_project == id_project).all()
    personajes_list = [
        {
            "id_personaje": p.id_personaje,
            "nombre_personaje": p.nombre_personaje,
            "descripcion": p.descripcion,
            "id_project": p.id_project,
            "id_actor": p.id_actor
        }
        for p in personajes
    ]
    return api_response(True, "Personajes del proyecto", personajes_list)


# CREATE PERSONAJE

def create_personaje(personaje: PersonajeSchema, db: Session):
    new_personaje = Personaje(
        nombre_personaje=personaje.nombre_personaje,
        descripcion=personaje.descripcion,
        id_project=personaje.id_project,
        id_actor=personaje.id_actor
    )

    db.add(new_personaje)
    db.commit()
    db.refresh(new_personaje)

    return api_response(True, "Personaje creado", {
        "id_personaje": new_personaje.id_personaje,
        "nombre_personaje": new_personaje.nombre_personaje
    })


# UPDATE PERSONAJE (PUT)

def update_personaje_full(id: int, personaje: PersonajeSchema, db: Session):
    personaje_db = db.query(Personaje).filter(Personaje.id_personaje == id).first()

    if not personaje_db:
        return api_response(False, "Personaje no encontrado")

    personaje_db.nombre_personaje = personaje.nombre_personaje
    personaje_db.descripcion = personaje.descripcion
    personaje_db.id_project = personaje.id_project
    personaje_db.id_actor = personaje.id_actor

    db.commit()
    db.refresh(personaje_db)

    return api_response(True, "Personaje actualizado", {
        "id_personaje": personaje_db.id_personaje,
        "nombre_personaje": personaje_db.nombre_personaje
    })


# UPDATE PERSONAJE (PATCH)

def update_personaje(id: int, personaje, db: Session):
    personaje_db = db.query(Personaje).filter(Personaje.id_personaje == id).first()

    if not personaje_db:
        return api_response(False, "Personaje no encontrado")

    update_data = personaje.model_dump(exclude_unset=True)

    for key, value in update_data.items():
        setattr(personaje_db, key, value)

    db.commit()
    db.refresh(personaje_db)

    return api_response(True, "Personaje actualizado", {
        "id_personaje": personaje_db.id_personaje,
        "nombre_personaje": personaje_db.nombre_personaje
    })


# DELETE PERSONAJE

def delete_personaje(id: int, db: Session):
    personaje = db.query(Personaje).filter(Personaje.id_personaje == id).first()

    if not personaje:
        return api_response(False, "Personaje no encontrado")

    db.delete(personaje)
    db.commit()

    return api_response(True, "Personaje eliminado")
