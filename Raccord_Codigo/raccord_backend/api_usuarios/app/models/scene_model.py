from sqlalchemy import Column, Integer, String, Text, Date
from app.config.database import Base

# ==========================================
# SCENE MODEL (tabla "escenas")
# ==========================================
# id_escena NO se genera acá: la BD tiene un trigger (gen_id_escena)
# que arma 'esc' + consecutivo (esc001, esc002, ...) en el INSERT.
# Igual que en Department, se deja sin default en el modelo para que
# el trigger la complete y SQLAlchemy la recupere con RETURNING.
#
# "modo_vista" (vistalugar: int/ext/int-ext/ext-int) y "momento_dia"
# (momentodia: dia/noche/amanecer/atardecer/...) son ENUM en Postgres,
# mapeados como texto plano igual que el resto de enums del proyecto.
#
# id_guion, id_desglose e id_rodaje son llaves foráneas. id_desglose e
# id_rodaje no tienen modelo propio todavía (desgloses / plan_rodaje no
# están implementados en este backend), así que quedan como columnas
# planas por ahora, igual que el resto de FKs del proyecto.
class Scene(Base):
    __tablename__ = "escenas"

    id_escena = Column(
        Text,
        primary_key=True,
        index=True
    )

    numero_de_escena = Column(
        String(45),
        nullable=False
    )

    encabezado = Column(
        Text,
        nullable=False
    )

    descripcion = Column(
        Text
    )

    id_guion = Column(  # llave foránea -> guiones.id_guion
        Integer,
        nullable=True
    )

    modo_vista = Column(
        String(20)
    )

    momento_dia = Column(
        String(20)
    )

    ciudad = Column(
        Text
    )

    pagina = Column(
        Integer
    )

    fecha_de_grabacion = Column(
        Date
    )

    dia_dramatico = Column(
        Integer
    )

    id_rodaje = Column(  # llave foránea -> plan_rodaje.id_rodaje (aún sin modelo)
        Text,
        nullable=True
    )

    id_desglose = Column(  # llave foránea -> desgloses.id_desglose (aún sin modelo)
        Text,
        nullable=True
    )
