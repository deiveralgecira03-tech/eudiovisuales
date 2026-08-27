# ==========================================
# CATALOGO DE ROLES
# ==========================================
# Debe coincidir con la tabla "roles" (id_rol) de la base de datos.
ADMINISTRADOR = 1001
DIRECTOR = 1002
JEFE_DEPARTAMENTO = 1003
ONSET = 1004
USUARIO = 1005


# ==========================================
# MATRIZ DE PERMISOS POR ROL
# ==========================================
# Reglas acordadas:
#
# 1001 Administrador      -> control total, sin restricciones.
# 1002 Director            -> mismo nivel de acceso que 1001, EXCEPTO:
#                             no puede crear proyectos (solo elegir entre
#                             los que ya existen) y no puede eliminar
#                             usuarios con rol 1001.
# 1003 Jefe de Departamento -> puede descargar documentos, puede invitar
#                             (gestionar accesos) y subir fotos, pero NO
#                             puede subir guiones ni crear escenas o
#                             personajes.
# 1004 Onset                -> puede ver todo, subir fotografías y
#                             comentar en escenas. Sin permisos de
#                             administración.
# 1005 Usuario               -> solo lectura (visualizador).
#
# NOTA: "download_files", "upload_scripts", "create_scenes",
# "create_characters", "upload_photos" y "comment_scenes" todavía no
# tienen endpoints en este backend (guiones/escenas/personajes/fotos/
# comentarios no están implementados). Quedan listos en la matriz para
# que, cuando se creen esas rutas, solo haga falta agregar
# Depends(require_permission("<permiso>")) — sin tener que rediseñar
# el esquema de permisos.
ROLE_PERMISSIONS = {
    ADMINISTRADOR: {
        "full_management": True,     # CRUD total de usuarios, clientes y roles
        "create_project": True,
        "manage_projects": True,     # editar / eliminar proyectos
        "invite_users": True,
        "delete_admin_users": True,  # puede eliminar usuarios con id_rol 1001
        "download_files": True,
        "upload_scripts": True,
        "create_scenes": True,
        "create_characters": True,
        "upload_photos": True,
        "comment_scenes": True,
        "read_only": False,
    },
    DIRECTOR: {
        "full_management": True,
        "create_project": False,
        "manage_projects": True,
        "invite_users": True,
        "delete_admin_users": False,
        "download_files": True,
        "upload_scripts": True,
        "create_scenes": True,
        "create_characters": True,
        "upload_photos": True,
        "comment_scenes": True,
        "read_only": False,
    },
    JEFE_DEPARTAMENTO: {
        "full_management": False,
        "create_project": False,
        "manage_projects": False,
        "invite_users": True,
        "delete_admin_users": False,
        "download_files": True,
        "upload_scripts": False,
        "create_scenes": False,
        "create_characters": False,
        "upload_photos": True,
        "comment_scenes": False,
        "read_only": False,
    },
    ONSET: {
        "full_management": False,
        "create_project": False,
        "manage_projects": False,
        "invite_users": False,
        "delete_admin_users": False,
        "download_files": False,
        "upload_scripts": False,
        "create_scenes": False,
        "create_characters": False,
        "upload_photos": True,
        "comment_scenes": True,
        "read_only": False,
    },
    USUARIO: {
        "full_management": False,
        "create_project": False,
        "manage_projects": False,
        "invite_users": False,
        "delete_admin_users": False,
        "download_files": False,
        "upload_scripts": False,
        "create_scenes": False,
        "create_characters": False,
        "upload_photos": False,
        "comment_scenes": False,
        "read_only": True,
    },
}


# ==========================================
# HELPER
# ==========================================
def has_permission(id_rol: int, permission: str) -> bool:
    role = ROLE_PERMISSIONS.get(id_rol)

    if not role:
        return False

    return role.get(permission, False)
