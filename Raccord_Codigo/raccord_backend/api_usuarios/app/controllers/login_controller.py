import logging
import random
import string
from datetime import datetime, timedelta

from sqlalchemy.orm import Session
from sqlalchemy.sql import func

logger = logging.getLogger("raccord")

from app.models.user_model import User
from app.models.project_model import Project
from app.models.user_project_model import UserProject

from app.utils.hash import verify_password
from app.utils.security import create_access_token
from app.utils.response import api_response
from app.utils.mail import send_2fa_email

# ==========================================
# 2FA - DISPOSITIVOS VERIFICADOS / CODIGOS
# ==========================================
# Cuánto tiempo se confía en un dispositivo ya verificado antes de
# volver a pedir código de verificación.
DEVICE_TRUST_HOURS = 12

verified_devices = {}
two_factor_codes = {}


# ==========================================
# OBTENER id_client A PARTIR DEL USUARIO
# ==========================================
def _get_client_from_user(user: User, db: Session):
    user_project = db.query(UserProject).filter(
        UserProject.id_user == user.id_user
    ).first()

    if not user_project:
        return None

    project = db.query(Project).filter(
        Project.id_project == user_project.id_project
    ).first()

    return project.id_client if project else None


# ==========================================
# CONSTRUIR RESPUESTA DE SESION (TOKEN + USUARIO)
# ==========================================
def _build_session_response(user: User, db: Session, message: str, extra: dict = None):
    token = create_access_token({
        "id_user": user.id_user,
        "mail": user.mail,
        "id_rol": user.id_rol
    })

    data = {
        "access_token": token,
        "token_type": "Bearer",
        "usuario": {
            "id_user": user.id_user,
            "nombre": user.nombre,
            "apellido": user.apellido,
            "mail": user.mail,
            "id_rol": user.id_rol,
            "id_client": _get_client_from_user(user, db)
        }
    }

    if extra:
        data["usuario"].update(extra)

    return api_response(True, message, data)


# ==========================================
# LOGIN
# ==========================================
def login_user(mail: str, contrasena: str, db: Session):
    user = db.query(User).filter(User.mail == mail).first()

    if not user:
        return api_response(False, "Correo no registrado", error="USER_NOT_FOUND")

    try:
        password_ok = verify_password(contrasena, user.contrasena)
    except Exception:
        # Ej: hash corrupto/formato incompatible en la BD. No debe
        # tumbar la petición con un 500 crudo.
        logger.exception("Error verificando contraseña para %s", mail)
        return api_response(False, "No fue posible validar las credenciales", error="AUTH_ERROR")

    if not password_ok:
        return api_response(False, "Contraseña incorrecta", error="INVALID_PASSWORD")

    user.ultimo_acceso = func.now()
    db.commit()

    return _build_session_response(user, db, "Login exitoso")


# ==========================================
# 2FA - ¿EL DISPOSITIVO YA ESTA VERIFICADO?
# ==========================================
def _device_is_verified(mail: str, device_id: str) -> bool:
    key = f"{mail}:{device_id}"
    expira = verified_devices.get(key)

    if not expira:
        return False

    if datetime.now() > expira:
        # ventana de confianza vencida, se debe volver a verificar
        del verified_devices[key]
        return False

    return True


# ==========================================
# 2FA - VERIFICAR SI DISPOSITIVO NECESITA 2FA
# ==========================================
# Un dispositivo ya verificado dentro de la ventana de confianza
# (DEVICE_TRUST_HOURS) no vuelve a pedir código. Si es un dispositivo
# nuevo, o pasó la ventana, sí se requiere.
def check_2fa_required(mail: str, device_id: str):
    if _device_is_verified(mail, device_id):
        return api_response(True, "Dispositivo confiable, no se requiere verificación", {
            "requires_2fa": False
        })

    return api_response(True, "Se requiere verificación", {
        "requires_2fa": True
    })


# ==========================================
# 2FA - ENVIAR CODIGO
# ==========================================
def send_2fa_code(mail: str, device_id: str, db: Session):
    if _device_is_verified(mail, device_id):
        return api_response(True, "Dispositivo confiable, no se requiere verificación", {
            "requires_2fa": False
        })

    user = db.query(User).filter(User.mail == mail).first()

    if not user:
        return api_response(False, "Usuario no encontrado", error="USER_NOT_FOUND")

    codigo = ''.join(random.choices(string.digits, k=6))

    two_factor_codes[mail] = {
        "codigo": codigo,
        "device_id": device_id,
        "expira": datetime.now() + timedelta(minutes=10)
    }

    enviado = send_2fa_email(mail, codigo)

    if not enviado:
        return api_response(False, "Error al enviar código", error="MAIL_ERROR")

    return api_response(True, "Código de verificación enviado al correo", {
        "requires_2fa": True
    })


# ==========================================
# 2FA - VERIFICAR CODIGO
# ==========================================
def verify_2fa_code(mail: str, codigo: str, device_id: str, db: Session):
    if mail not in two_factor_codes:
        return api_response(False, "No hay código de verificación pendiente", error="NO_CODE")

    datos = two_factor_codes[mail]

    if datetime.now() > datos["expira"]:
        del two_factor_codes[mail]
        return api_response(False, "Código expirado", error="CODE_EXPIRED")

    if datos["codigo"] != codigo:
        return api_response(False, "Código incorrecto", error="INVALID_CODE")

    key = f"{mail}:{device_id}"
    verified_devices[key] = datetime.now() + timedelta(hours=DEVICE_TRUST_HOURS)

    del two_factor_codes[mail]

    user = db.query(User).filter(User.mail == mail).first()

    if not user:
        return api_response(False, "Usuario no encontrado", error="USER_NOT_FOUND")

    user.ultimo_acceso = func.now()
    db.commit()

    return _build_session_response(
        user, db, "Verificación exitosa", extra={"device_verified": True}
    )
