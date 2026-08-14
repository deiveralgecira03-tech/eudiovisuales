from sqlalchemy import Column, Integer, String, Text, ForeignKey
from app.config.database import Base

class Personaje(Base):
    __tablename__ = "personajes"

    id_personaje = Column(
        Integer,
        primary_key=True,
        index=True,
        autoincrement=True
    )

    nombre_personaje = Column(
        String(100),
        nullable=False
    )

    descripcion = Column(
        Text
    )

    id_project = Column(
        String(20),
        ForeignKey("projects.id_project", ondelete="CASCADE"),
        nullable=False
    )

    id_actor = Column(
        Integer,
        ForeignKey("actors.id_actor", ondelete="SET NULL"),
        nullable=True
    )
