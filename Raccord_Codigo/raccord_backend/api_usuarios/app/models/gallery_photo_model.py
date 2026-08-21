from sqlalchemy import Column, Integer, String, Text, LargeBinary, DateTime, ForeignKey, func
from app.config.database import Base

# ==========================================
# GALLERY PHOTO MODEL (tabla "fotos_continuidad")
# ==========================================
# Fotos de continuidad visual asociadas a una escena (mockup 6.1):
# vestuario, maquillaje, props, set, etc. La imagen se guarda como
# BYTEA en Postgres, mismo patrón que el PDF de guiones
# (archivo_contenido en script_model.py) — se sube con
# POST /scenes/{id_escena}/fotos y se sirve con
# GET /fotos/{id_foto}/archivo, nunca dentro del JSON normal de la
# lista (para no inflar esas respuestas).
#
# A diferencia de escenas/personajes/departamentos, esta tabla es
# nueva y no tiene un trigger de Postgres para generar su id, así que
# usa un autoincrement normal de SQLAlchemy (igual que "guiones").
class GalleryPhoto(Base):
    __tablename__ = "fotos_continuidad"

    id_foto = Column(
        Integer,
        primary_key=True,
        index=True,
        autoincrement=True
    )

    id_escena = Column(  # llave foránea -> escenas.id_escena
        Text,
        ForeignKey("escenas.id_escena", ondelete="CASCADE"),
        nullable=False
    )

    # Tipo de foto (Set, Personaje, Vestuario, Maquillaje, Props,
    # Locación, Otro) — texto libre validado del lado de la API
    # (ver TipoFoto en gallery_photo_schema.py).
    tipo_foto = Column(
        String(30),
        nullable=False,
        server_default="Set"
    )

    # Código del personaje al que aplica esta foto (ej. "P001"), texto
    # libre igual que en el mockup — no es FK a personajes porque no
    # siempre una foto de continuidad corresponde a un personaje
    # (puede ser del set, de un prop, etc.).
    personaje_codigo = Column(
        String(30),
        nullable=True
    )

    descripcion = Column(
        Text,
        nullable=True
    )

    notas_continuidad = Column(
        Text,
        nullable=True
    )

    archivo_nombre = Column(String(255), nullable=False)
    archivo_contenido = Column(LargeBinary, nullable=False)
    archivo_tipo = Column(String(100), nullable=False)
    archivo_tamano = Column(Integer, nullable=False)

    fecha_subida = Column(
        DateTime,
        nullable=False,
        server_default=func.now()
    )
