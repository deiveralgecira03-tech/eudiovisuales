/// Espejo en Dart de app/utils/permissions.py — SOLO para decidir qué
/// mostrar/ocultar en la UI. La autorización real siempre la hace el
/// backend (Depends(require_permission(...))); si este mapa queda
/// desincronizado el peor caso es un botón visible que el backend
/// rechaza con 403, nunca una acción no autorizada que se ejecute.
class Roles {
  Roles._();

  static const administrador = 1001;
  static const director = 1002;
  static const jefeDepartamento = 1003;
  static const onset = 1004;
  static const usuario = 1005;

  static String label(int? idRol) {
    switch (idRol) {
      case administrador:
        return 'Administrador';
      case director:
        return 'Director';
      case jefeDepartamento:
        return 'Jefe de Departamento';
      case onset:
        return 'Onset';
      case usuario:
        return 'Usuario';
      default:
        return 'Sin rol';
    }
  }
}

const Map<int, Map<String, bool>> _rolePermissions = {
  Roles.administrador: {
    'full_management': true,
    'create_project': true,
    'manage_projects': true,
    'invite_users': true,
    'delete_admin_users': true,
    'manage_team_status': true,
    'download_files': true,
    'upload_scripts': true,
    'create_scenes': true,
    'create_characters': true,
    'upload_photos': true,
    'delete_photos': true,
    'comment_scenes': true,
    'manage_general_breakdown': true,
    'view_department_breakdown': false,
    'edit_department_breakdown': false,
  },
  Roles.director: {
    'full_management': true,
    'create_project': false,
    'manage_projects': true,
    'invite_users': true,
    'delete_admin_users': false,
    'manage_team_status': true,
    'download_files': true,
    'upload_scripts': true,
    'create_scenes': true,
    'create_characters': true,
    'upload_photos': true,
    'delete_photos': true,
    'comment_scenes': true,
    'manage_general_breakdown': true,
    'view_department_breakdown': false,
    'edit_department_breakdown': false,
  },
  Roles.jefeDepartamento: {
    'full_management': false,
    'create_project': false,
    'manage_projects': false,
    'invite_users': true,
    'delete_admin_users': false,
    'manage_team_status': true, // solo su propio departamento — se filtra en la UI, el backend es quien realmente lo exige
    'download_files': true,
    'upload_scripts': false,
    'create_scenes': false,
    'create_characters': false,
    'upload_photos': true,
    'delete_photos': true,
    'comment_scenes': false,
    'manage_general_breakdown': false,
    'view_department_breakdown': true,
    'edit_department_breakdown': true,
  },
  Roles.onset: {
    'full_management': false,
    'create_project': false,
    'manage_projects': false,
    'invite_users': false,
    'delete_admin_users': false,
    'manage_team_status': false,
    'download_files': false,
    'upload_scripts': false,
    'create_scenes': false,
    'create_characters': false,
    'upload_photos': true,
    'delete_photos': false, // Onset sube fotos de continuidad, pero no puede eliminarlas
    'comment_scenes': true,
    'manage_general_breakdown': false,
    'view_department_breakdown': true,
    'edit_department_breakdown': false,
  },
  Roles.usuario: {
    'full_management': false,
    'create_project': false,
    'manage_projects': false,
    'invite_users': false,
    'delete_admin_users': false,
    'manage_team_status': false,
    'download_files': false,
    'upload_scripts': false,
    'create_scenes': false,
    'create_characters': false,
    'upload_photos': false,
    'delete_photos': false,
    'comment_scenes': false,
    'manage_general_breakdown': false,
    'view_department_breakdown': true,
    'edit_department_breakdown': false,
  },
};

bool hasPermission(int? idRol, String permission) {
  final role = _rolePermissions[idRol];
  if (role == null) return false;
  return role[permission] ?? false;
}
