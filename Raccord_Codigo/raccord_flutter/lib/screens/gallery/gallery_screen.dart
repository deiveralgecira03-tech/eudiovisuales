import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/state_views.dart';

/// Mockups 9, 9.1, 9.2, 9.3, 12, 15: fotos de continuidad y galería.
/// El backend (api_usuarios) todavía no expone endpoints de carga ni
/// consulta de fotos, así que esta pantalla se deja como placeholder
/// honesto en vez de simular datos — se conecta en cuanto exista la
/// ruta (algo como /scenes/{id}/photos).
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Galería',
      showBack: true,
      body: ComingSoonView(
        title: 'Fotos de continuidad — próximamente',
        detail:
            'Esta sección está diseñada en los mockups (subida de fotos Set/Propuesta/Prueba, '
            'notas de continuidad), pero el backend aún no tiene endpoints para guardarlas. '
            'En cuanto se agregue la ruta correspondiente, esta pantalla se conecta igual que '
            'el resto de módulos.',
      ),
    );
  }
}
