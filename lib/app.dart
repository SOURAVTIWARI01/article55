import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/user_dashboard_screen.dart';
import 'screens/admin_dashboard_screen.dart';

/// Root application widget with routing, providers, and theme support.
class Article55App extends StatelessWidget {
  const Article55App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Article 55',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: '/',
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  /// Route generator with fade+slide page transitions.
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return AppTheme.fadeSlideRoute(const SplashScreen());
      case '/login':
        return AppTheme.fadeSlideRoute(const LoginScreen());
      case '/register':
        return AppTheme.fadeSlideRoute(const RegistrationScreen());
      case '/user-dashboard':
        return AppTheme.fadeSlideRoute(const UserDashboardScreen());
      case '/admin-dashboard':
        return AppTheme.fadeSlideRoute(const AdminDashboardScreen());
      default:
        return AppTheme.fadeSlideRoute(const LoginScreen());
    }
  }
}
