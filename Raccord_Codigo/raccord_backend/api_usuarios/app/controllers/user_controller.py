from sqlalchemy.orm import Session

from app.models.user_model import User
from app.models.project_model import Project
from app.models.user_project_model import UserProject

from app.schemas.user_schema import UserSchema

from app.utils.hash import hash_password
from app.utils.formatters import format_text
from app.utils.response import api_response
from app.utils.permissions import has_permission, ADMINISTRADOR


# ==========================================
# GET ALL USERS
# ==========================================
def get_users(db: Session):
    users = db.query(User).all()
    users_list = [
        {
            "id_user": u.id_user,
            "nombre": u.nombre,
            "apellido": u.apellido,
            "identificacion": u.identificacion,
            "id_identificacion": u.id_identificacion,
            "mail": u.mail,
            "msisdn": u.msisdn,
            "direccion": u.direccion,
            "fecha_de_nacimiento": str(u.fecha_de_nacimiento),
            "estado": u.estado,
            "fecha_de_creacion": str(u.fecha_de_creacion),
            "ultimo_acceso": str(u.ultimo_acceso),
            "id_departamento": u.id_departamento,
            "id_project": u.id_project,
            "id_rol": u.id_rol
        }
        for u in users
    ]
    return api_response(True, "Lista de usuarios", users_list)


# ==========================================
# GET USER BY ID
# ==========================================
def get_user(id: int, db: Session):
    user = db.query(User).filter(User.id_user == id).first()

    if not user:
        return api_response(False, "Usuario no encontrado")

    return api_response(True, "Usuario encontrado", {
        "id_user": user.id_user,
        "nombre": user.nombre,
        "apellido": user.apellido,
        "identificacion": user.identificacion,
        "id_identificacion": user.id_identificacion,
        "mail": user.mail,
        "msisdn": user.msisdn,
        "direccion": user.direccion,
        "fecha_de_nacimiento": str(user.fecha_de_nacimiento),
        "estado": user.estado,
        "fecha_de_creacion": str(user.fecha_de_creacion),
        "ultimo_acceso": str(user.ultimo_acceso),
        "id_departamento": user.id_departamento,
        "id_project": user.id_project,
        "id_rol": user.id_rol
    })


# ==========================================
# CREATE USER
# ==========================================
def create_user(user: UserSchema, db: Session):
    existing = db.query(User).filter(User.mail == user.mail).first()

    if existing:
        return api_response(False, "Correo ya registrado", error="DUPLICATE_EMAIL")

    existing_id = db.query(User).filter(User.id_identificacion == user.id_identificacion).first()

    if existing_id:
        return api_response(False, "Identificacion ya registrada", error="DUPLICATE_ID")

    hashed_password = hash_password(user.contrasena)

    new_user = User(
        nombre=format_text(user.nombre),
        apellido=format_text(user.apellido),
        identificacion=user.identificacion,
        id_identificacion=user.id_identificacion,
        mail=user.mail.strip().lower(),
        msisdn=user.msisdn,
        direccion=format_text(user.direccion),
        fecha_de_nacimiento=user.fecha_de_nacimiento,
        estado=user.estado,
        contrasena=hashed_password,
        id_departamento=user.id_departamento,
        id_project=user.id_project,
        id_rol=user.id_rol
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return api_response(True, "Usuario registrado correctamente", {
        "id_user": new_user.id_user,
        "nombre": new_user.nombre,
        "apellido": new_user.apellido,
        "mail": new_user.mail
    })


# ==========================================
# UPDATE USER (PUT - completo)
# ==========================================
def update_user_full(id: int, user: UserSchema, db: Session):
    user_db = db.query(User).filter(User.id_user == id).first()

    if not user_db:
        return api_response(False, "Usuario no encontrado")

    user_db.nombre = format_text(user.nombre)
    user_db.apellido = format_text(user.apellido)
    user_db.identificacion = user.identificacion
    user_db.id_identificacion = user.id_identificacion
    user_db.mail = user.mail.strip().lower()
    user_db.msisdn = user.msisdn
    user_db.direccion = format_text(user.direccion)
    user_db.fecha_de_nacimiento = user.fecha_de_nacimiento
    user_db.estado = user.estado
    user_db.contrasena = hash_password(user.contrasena)
    user_db.id_departamento = user.id_departamento
    user_db.id_project = user.id_project
    user_db.id_rol = user.id_rol

    db.commit()
    db.refresh(user_db)

    return api_response(True, "Usuario actualizado", {
        "id_user": user_db.id_user,
        "nombre": user_db.nombre,
        "apellido": user_db.apellido,
        "mail": user_db.mail
    })


# ==========================================
# UPDATE USER (PATCH - parcial)
# ==========================================
def update_user(id: int, user, db: Session):
    user_db = db.query(User).filter(User.id_user == id).first()

    if not user_db:
        return api_response(False, "Usuario no encontrado")

    update_data = user.model_dump(exclude_unset=True)

    campos_texto = ["nombre", "apellido", "direccion"]
    campos_lower = ["mail"]

    for key, value in update_data.items():
        if key == "contrasena" and value is not None:
            value = hash_password(value)
        elif key in campos_texto and value is not None:
            value = format_text(value)
        elif key in campos_lower and value is not None:
            value = value.strip().lower()
        setattr(user_db, key, value)

    db.commit()
    db.refresh(user_db)

    return api_response(True, "Usuario actualizado", {
        "id_user": user_db.id_user,
        "nombre": user_db.nombre,
        "apellido": user_db.apellido,
        "mail": user_db.mail
    })


# ==========================================
# DELETE USER
# ==========================================
# Director (1002) tiene el mismo nivel de acceso que Administrador
# (1001), excepto que no puede eliminar usuarios con rol Administrador.
def delete_user(id: int, db: Session, current_user: dict = None):
    user = db.query(User).filter(User.id_user == id).first()

    if not user:
        return api_response(False, "Usuario no encontrado")

    if user.id_rol == ADMINISTRADOR and current_user is not None:
        if not has_permission(current_user.get("id_rol"), "delete_admin_users"):
            return api_response(
                False,
                "No tienes permisos para eliminar un usuario Administrador",
                error="FORBIDDEN"
            )

    db.delete(user)
    db.commit()

    return api_response(True, "Usuario eliminado")


# ==========================================
# GET USERS BY PROJECT
# ==========================================
def get_users_by_project(id_project: str, db: Session):
    user_projects = db.query(User, UserProject.id_rol).join(
        UserProject, User.id_user == UserProject.id_user
    ).filter(UserProject.id_project == id_project).all()

    users_list = [
        {
            "id_user": user.id_user,
            "nombre": user.nombre,
            "apellido": user.apellido,
            "mail": user.mail,
            "msisdn": user.msisdn,
            "estado": user.estado,
            "id_rol": rol,
            "id_project": id_project
        }
        for user, rol in user_projects
    ]
    return api_response(True, "Usuarios del proyecto", users_list)


# ==========================================
# GET PROJECTS BY USER
# ==========================================
def get_user_projects(id_user: int, db: Session):
    projects = db.query(Project, UserProject.id_rol).join(
        UserProject, Project.id_project == UserProject.id_project
    ).filter(UserProject.id_user == id_user).all()

    result = [
        {
            "id_project": project.id_project,
            "project_name": project.project_name,
            "formato_de_produccion": project.formato_de_produccion,
            "genero": project.genero,
            "director": project.director,
            "id_client": project.id_client,
            "id_rol": rol
        }
        for project, rol in projects
    ]

    return api_response(True, "Proyectos del usuario", result)
