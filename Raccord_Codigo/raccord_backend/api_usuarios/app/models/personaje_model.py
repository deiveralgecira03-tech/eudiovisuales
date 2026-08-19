from sqlalchemy import Column, Integer, String, Text, FetchedValue
from app.config.database import Base

class Personaje(Base):
    __tablename__ = "personajes"

    # El id_personaje lo genera un trigger de PostgreSQL (formato "cast1",
    # "cast2", ...). FetchedValue() le dice a SQLAlchemy que no calcule
    # este valor en Python, sino que lo pida de vuelta a la base de datos
    # justo después del INSERT (vía RETURNING).
    id_personaje = Column(
        Text,
        primary_key=True,
        server_default=FetchedValue()
    )

    nombre = Column(
        String(45),
        nullable=False
    )

    edad = Column(
        Integer,
        nullable=False
    )

    codigo_personaje = Column(
        String(30),
        nullable=False
    )
