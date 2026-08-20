import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/session.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_register_screen.dart';
import 'screens/auth/two_factor_screen.dart';
import 'screens/breakdown/breakdown_screen.dart';
import 'screens/characters/actor_form_screen.dart';
import 'screens/characters/characters_screen.dart';
import 'screens/characters/crew_list_screen.dart';
import 'screens/dashboard/project_dashboard_screen.dart';
import 'screens/gallery/gallery_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/projects/project_selection_screen.dart';
import 'screens/roles/roles_screen.dart';
import 'screens/scenes/scenes_screen.dart';
import 'screens/scripts/scripts_screen.dart';
import 'screens/shooting_days/shooting_days_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/app_logo.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthSession()..bootstrap(),
      child: const RaccordApp(),
    ),
  );
}

class RaccordApp extends StatelessWidget {
  const RaccordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raccord',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const _SplashGate(),
      onGenerateRoute: _onGenerateRoute,
    );
  }
}

Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
  Widget page;

  switch (settings.name) {
    case '/login':
      page = const LoginRegisterScreen();
      break;
    case '/2fa':
      final args = settings.arguments as Map<String, dynamic>? ?? {};
      page = TwoFactorScreen(mail: args['mail'] as String? ?? '');
      break;
    case '/olvide-password':
      page = const ForgotPasswordScreen();
      break;
    case '/proyectos':
      page = const ProjectSelectionScreen();
      break;
    case '/dashboard':
      page = const ProjectDashboardScreen();
      break;
    case '/roles':
      page = const RolesScreen();
      break;
    case '/guiones':
      page = const ScriptsScreen();
      break;
    case '/escenas':
      page = const ScenesScreen();
      break;
    case '/personajes':
      page = const CharactersScreen();
      break;
    case '/actor-form':
      page = ActorFormScreen(idPersonaje: settings.arguments as String?);
      break;
    case '/crew-list':
      page = const CrewListScreen();
      break;
    case '/plan-rodaje':
      page = const ShootingDaysScreen();
      break;
    case '/desglose':
      page = const BreakdownScreen();
      break;
    case '/galeria':
      page = const GalleryScreen();
      break;
    case '/perfil':
      page = const ProfileScreen();
      break;
    default:
      return null;
  }

  return MaterialPageRoute(builder: (_) => page, settings: settings);
}

/// Decide la primera pantalla según el estado de sesión persistido:
/// sin token -> Login; con token pero sin proyecto activo -> Selección
/// de proyecto; con proyecto -> Dashboard.
class _SplashGate extends StatelessWidget {
  const _SplashGate();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();

    if (!session.ready) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIsotipo(size: 88),
              SizedBox(height: 24),
              CircularProgressIndicator(color: AppColors.azulProfundo),
            ],
          ),
        ),
      );
    }

    if (!session.isAuthenticated) return const LoginRegisterScreen();
    if (!session.hasProject) return const ProjectSelectionScreen();
    return const ProjectDashboardScreen();
  }
}
