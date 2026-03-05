import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/admin_guard.dart';
import 'providers/auth_provider.dart';
import 'providers/candidate_provider.dart';
import 'providers/voting_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/admin_dashboard_provider.dart';
import 'providers/vote_monitoring_provider.dart';
import 'providers/security_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/user_dashboard_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/candidate_form_screen.dart';
import 'screens/admin_approval_screen.dart';
import 'screens/voting_screen.dart';
import 'screens/results_screen.dart';
import 'screens/vote_monitoring_screen.dart';
import 'screens/admin_analytics_screen.dart';
import 'screens/blocked_flats_screen.dart';

/// Root application widget with routing, providers, and theme support.
class Article55App extends StatelessWidget {
  const Article55App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CandidateProvider()),
        ChangeNotifierProvider(create: (_) => VotingProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
        ChangeNotifierProvider(create: (_) => VoteMonitoringProvider()),
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProv, _) => MaterialApp(
          title: 'Article 55',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProv.themeMode,
          initialRoute: '/',
          onGenerateRoute: _onGenerateRoute,
        ),
      ),
    );
  }

  /// Route generator with fade+slide page transitions.
  /// Admin routes wrapped with AdminGuard for RBAC.
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
      case '/candidate-form':
        return AppTheme.fadeSlideRoute(const CandidateFormScreen());
      case '/voting':
        return AppTheme.fadeSlideRoute(const VotingScreen());
      case '/results':
        return AppTheme.fadeSlideRoute(const ResultsScreen());

      // ─── Admin routes (RBAC guarded) ──────────────────────
      case '/admin-dashboard':
        return AppTheme.fadeSlideRoute(
            const AdminGuard(child: AdminDashboardScreen()));
      case '/admin-approval':
        return AppTheme.fadeSlideRoute(
            const AdminGuard(child: AdminApprovalScreen()));
      case '/admin-votes':
        return AppTheme.fadeSlideRoute(
            const AdminGuard(child: VoteMonitoringScreen()));
      case '/admin-analytics':
        return AppTheme.fadeSlideRoute(
            const AdminGuard(child: AdminAnalyticsScreen()));
      case '/admin-blocked':
        return AppTheme.fadeSlideRoute(
            const AdminGuard(child: BlockedFlatsScreen()));

      default:
        return AppTheme.fadeSlideRoute(const LoginScreen());
    }
  }
}
