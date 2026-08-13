from sqlalchemy import Column, Integer, String, Text, ForeignKey, DateTime
from sqlalchemy.sql import func
from app.config.database import Base

# ==========================================
# DESGLOSE - NIVEL GENERAL (tabla "desglose_items")
# ==========================================
# Un item por (escena, categoria, elemento). Ej: escena esc014,
# categoria "Extras", nombre_item "Gente de mercado", cantidad 95.
# Lo crea/edita Administrador o Director (permiso
# "manage_general_breakdown"). Es de lectura abierta para cualquier
# usuario autenticado, igual que departamentos/guiones/escenas.
#
# id_departamento indica qué área es dueña de ese item (quién lo va a
# segmentar en el nivel específico). Puede ser nulo para items sin
# área dueña (ej. notas generales de producción).
#
# Tabla nueva, no existe todavía en el dump de Postgres: usa PK
# autoincremental simple (SERIAL), igual que guiones.id_guion, en vez
# de un trigger custom.
class DesgloseItem(Base):
    __tablename__ = "desglose_items"

    id_desglose_item = Column(
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

    id_departamento = Column(  # llave foránea -> departamentos.id_departamento
        Text,
        ForeignKey("departamentos.id_departamento"),
        nullable=True
    )

    categoria = Column(
        String(50),
        nullable=False
    )

    nombre_item = Column(
        Text,
        nullable=False
    )

    cantidad = Column(
        Integer,
        nullable=True
    )

    notas = Column(
        Text,
        nullable=True
    )

    id_user_creador = Column(  # llave foránea -> users.id_user
        Integer,
        ForeignKey("users.id_user"),
        nullable=True
    )

    created_at = Column(
        DateTime,
        server_default=func.now()
    )

    updated_at = Column(
        DateTime,
        server_default=func.now(),
        onupdate=func.now()
    )


# ==========================================
# DESGLOSE - NIVEL ESPECIFICO (tabla "desglose_item_detalle")
# ==========================================
# Segmentación interna que hace el Jefe de Departamento sobre un item
# general. Ej: del item "95 gente de mercado", detalle "Mujeres: 30",
# "Hombres: 40", "Niños: 25". Solo la ve/edita el equipo del mismo
# id_departamento del item padre (Jefe edita, Onset/Usuario del mismo
# depto solo consultan). Administrador/Director NO ven este nivel.
#
# estado/prioridad permiten usar esta tabla como lista de pendientes
# del departamento (qué falta resolver, qué se prioriza primero).
class DesgloseItemDetalle(Base):
    __tablename__ = "desglose_item_detalle"

    id_detalle = Column(
        Integer,
        primary_key=True,
        index=True,
        autoincrement=True
    )

    id_desglose_item = Column(  # llave foránea -> desglose_items.id_desglose_item
        Integer,
        ForeignKey("desglose_items.id_desglose_item", ondelete="CASCADE"),
        nullable=False
    )

    etiqueta = Column(
        String(100),
        nullable=False
    )

    cantidad = Column(
        Integer,
        nullable=True
    )

    estado = Column(
        String(20),
        nullable=False,
        server_default="pendiente"
    )

    prioridad = Column(
        String(10),
        nullable=True
    )

    notas = Column(
        Text,
        nullable=True
    )

    id_user_editor = Column(  # llave foránea -> users.id_user
        Integer,
        ForeignKey("users.id_user"),
        nullable=True
    )

    updated_at = Column(
        DateTime,
        server_default=func.now(),
        onupdate=func.now()
    )
