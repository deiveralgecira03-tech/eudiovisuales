from sqlalchemy.orm import Session
from app.models.personaje_model import Personaje
from app.schemas.personaje_schema import PersonajeSchema
from app.utils.response import api_response


def get_personajes(db: Session):
    personajes = db.query(Personaje).all()
    personajes_list = [
        {
            "id_personaje": p.id_personaje,
            "nombre": p.nombre,
            "edad": p.edad,
            "codigo_personaje": p.codigo_personaje
        }
        for p in personajes
    ]
    return api_response(True, "Lista de personajes", personajes_list)


def get_personaje(id: str, db: Session):
    personaje = db.query(Personaje).filter(Personaje.id_personaje == id).first()

    if not personaje:
        return api_response(False, "Personaje no encontrado")

    return api_response(True, "Personaje encontrado", {
        "id_personaje": personaje.id_personaje,
        "nombre": personaje.nombre,
        "edad": personaje.edad,
        "codigo_personaje": personaje.codigo_personaje
    })


def create_personaje(personaje: PersonajeSchema, db: Session):
    new_personaje = Personaje(
        nombre=personaje.nombre,
        edad=personaje.edad,
        codigo_personaje=personaje.codigo_personaje
    )

    db.add(new_personaje)
    db.commit()
    db.refresh(new_personaje)

    return api_response(True, "Personaje creado", {
        "id_personaje": new_personaje.id_personaje,
        "nombre": new_personaje.nombre
    })


def update_personaje_full(id: str, personaje: PersonajeSchema, db: Session):
    personaje_db = db.query(Personaje).filter(Personaje.id_personaje == id).first()

    if not personaje_db:
        return api_response(False, "Personaje no encontrado")

    personaje_db.nombre = personaje.nombre
    personaje_db.edad = personaje.edad
    personaje_db.codigo_personaje = personaje.codigo_personaje

    db.commit()
    db.refresh(personaje_db)

    return api_response(True, "Personaje actualizado", {
        "id_personaje": personaje_db.id_personaje,
        "nombre": personaje_db.nombre
    })


def update_personaje(id: str, personaje, db: Session):
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
        "nombre": personaje_db.nombre
    })


def delete_personaje(id: str, db: Session):
    personaje = db.query(Personaje).filter(Personaje.id_personaje == id).first()

    if not personaje:
        return api_response(False, "Personaje no encontrado")

    db.delete(personaje)
    db.commit()

    return api_response(True, "Personaje eliminado")
