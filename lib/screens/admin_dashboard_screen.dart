import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_dashboard_provider.dart';

/// Admin dashboard with live stats, category distribution, quick actions.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProvider>().fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Background blurs
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 260,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            right: -80,
            child: Container(
              width: 300,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withValues(alpha: 0.08),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 8),
                  _buildWelcomeRow(),
                  const SizedBox(height: 20),
                  _buildStatsGrid(),
                  const SizedBox(height: 20),
                  _buildCategoryDistribution(),
                  const SizedBox(height: 28),
                  _buildQuickActions(),
                  const SizedBox(height: 28),
                  _buildLiveMonitoring(),
                ],
              ),
            ),
          ),

          // Bottom nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(child: _buildBottomNav()),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appName.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.titleGradient.createShader(bounds),
                child: Text(
                  AppStrings.adminControl,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          // Notification bell with red dot
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.notifications_outlined,
                    color: Colors.grey.shade700, size: 26),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.info.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.admin_panel_settings,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.welcomeBack,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                AppStrings.chiefAdmin,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: _showLogoutDialog,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.logout, size: 20, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Consumer<AdminDashboardProvider>(
      builder: (context, prov, _) {
        final stats = prov.stats;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: _buildStatCard(
                    label: 'Total Votes',
                    value: '${stats.totalVotes}',
                    badge: stats.totalVotes > 0 ? 'Active' : 'No votes',
                    badgeColor: AppColors.success,
                    icon: Icons.how_to_vote_outlined,
                    iconColor: AppColors.info,
                  )),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildStatCard(
                    label: 'Turnout',
                    value:
                        '${stats.turnoutPercent.toStringAsFixed(1)}%',
                    badge: stats.turnoutPercent > 50 ? 'Good' : 'Low',
                    badgeColor: stats.turnoutPercent > 50
                        ? AppColors.success
                        : AppColors.warning,
                    icon: Icons.pie_chart_outline,
                    iconColor: AppColors.accent,
                    badgeIcon: Icons.check_circle,
                  )),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _buildStatCard(
                    label: 'Registered',
                    value: '${stats.totalUsers}',
                    badge: 'Users',
                    badgeColor: AppColors.info,
                    icon: Icons.people_outline,
                    iconColor: Colors.blue,
                  )),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildStatCard(
                    label: 'Candidates',
                    value: '${stats.totalCandidates}',
                    badge: '${stats.pendingCandidates} pending',
                    badgeColor: stats.pendingCandidates > 0
                        ? AppColors.warning
                        : AppColors.success,
                    icon: Icons.person_search_outlined,
                    iconColor: Colors.orange,
                    badgeIcon: stats.pendingCandidates > 0
                        ? Icons.pending
                        : Icons.check_circle,
                  )),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required Color iconColor,
    IconData? badgeIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2687).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -8,
            right: -8,
            child:
                Icon(icon, size: 48, color: iconColor.withValues(alpha: 0.1)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              _AnimatedCountText(value: value),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      badgeIcon ?? Icons.trending_up,
                      size: 12,
                      color: badgeColor,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        badge,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: badgeColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDistribution() {
    return Consumer<AdminDashboardProvider>(
      builder: (context, prov, _) {
        final stats = prov.stats;
        final maxVotes = [
          stats.presidentVotes,
          stats.secretaryVotes,
          stats.treasurerVotes,
        ].reduce((a, b) => a > b ? a : b).clamp(1, double.maxFinite.toInt());

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1F2687).withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category Distribution',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildBar('President', stats.presidentVotes, maxVotes,
                    AppColors.info),
                const SizedBox(height: 12),
                _buildBar('Secretary', stats.secretaryVotes, maxVotes,
                    AppColors.accent),
                const SizedBox(height: 12),
                _buildBar('Treasurer', stats.treasurerVotes, maxVotes,
                    AppColors.success),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBar(String label, int count, int max, Color color) {
    final fraction = max > 0 ? count / max : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              '$count votes',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: fraction),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.quickActions,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => context.read<AdminDashboardProvider>().refresh(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Refresh',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Top row
          Row(
            children: [
              Expanded(
                  child: GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushNamed('/admin-approval'),
                child: _buildActionCard(
                  title: 'Candidates',
                  subtitle: 'Review & Approve',
                  icon: Icons.person_search,
                  gradient: AppColors.primaryGradient,
                  shadowColor: AppColors.info,
                ),
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/admin-votes'),
                child: _buildActionCard(
                  title: 'Votes',
                  subtitle: 'Monitor & Manage',
                  icon: Icons.ballot_outlined,
                  gradient: AppColors.accentGradient,
                  shadowColor: AppColors.accent,
                ),
              )),
            ],
          ),
          const SizedBox(height: 12),

          // Bottom row
          Row(
            children: [
              Expanded(
                  child: GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushNamed('/admin-analytics'),
                child: _buildActionCard(
                  title: 'Analytics',
                  subtitle: 'Charts & Results',
                  icon: Icons.bar_chart_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shadowColor: AppColors.success,
                ),
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushNamed('/admin-blocked'),
                child: _buildActionCard(
                  title: 'Security',
                  subtitle: 'Blocked Flats',
                  icon: Icons.shield_outlined,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shadowColor: AppColors.error,
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required LinearGradient gradient,
    required Color shadowColor,
  }) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMonitoring() {
    return Consumer<AdminDashboardProvider>(
      builder: (context, prov, _) {
        final stats = prov.stats;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.liveMonitoring,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildMonitoringCard(
                title: 'Election Votes',
                subtitle:
                    '${stats.totalVotes} total • ${stats.totalCandidates} candidates',
                status: stats.totalVotes > 0 ? 'Active' : 'Waiting',
                statusColor:
                    stats.totalVotes > 0 ? AppColors.success : AppColors.warning,
                progress: stats.turnoutPercent / 100,
                progressColor: AppColors.info,
                bottomLeft: '${stats.totalUsers} Registered',
                bottomRight:
                    '${stats.turnoutPercent.toStringAsFixed(0)}% Turnout',
                bottomRightColor: AppColors.info,
                icon: Icons.how_to_vote,
                iconBgColor: Colors.blue.shade50,
                iconColor: Colors.blue.shade400,
              ),
              const SizedBox(height: 12),
              _buildMonitoringCard(
                title: 'Security Status',
                subtitle:
                    '${stats.blockedFlats} blocked flat${stats.blockedFlats != 1 ? 's' : ''}',
                status: stats.blockedFlats > 0 ? 'Alert' : 'Clear',
                statusColor: stats.blockedFlats > 0
                    ? AppColors.error
                    : AppColors.success,
                progress: 1.0,
                progressColor: stats.blockedFlats > 0
                    ? AppColors.error
                    : AppColors.success,
                bottomLeft: 'RLS Active',
                bottomRight: 'Enforced',
                bottomRightColor: AppColors.success,
                icon: Icons.security,
                iconBgColor: Colors.purple.shade50,
                iconColor: Colors.purple.shade400,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonitoringCard({
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required double progress,
    required Color progressColor,
    required String bottomLeft,
    required String bottomRight,
    required Color bottomRightColor,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2687).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      bottomLeft,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    Text(
                      bottomRight,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: bottomRightColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      Icons.dashboard_outlined,
      Icons.poll_outlined,
      Icons.people_outline,
      Icons.settings_outlined,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(2, (i) => _buildNavItem(items[i], i)),
          // FAB
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GestureDetector(
              onTap: () =>
                  Navigator.of(context).pushNamed('/admin-approval'),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.info.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
          ),
          ...List.generate(2, (i) => _buildNavItem(items[i + 2], i + 2)),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = index == _selectedNavIndex;
    // Route mapping: 0=dashboard(stay), 1=analytics, 2=votes, 3=blocked flats
    final routes = {
      1: '/admin-analytics',
      2: '/admin-votes',
      3: '/admin-blocked',
    };
    return GestureDetector(
      onTap: () {
        setState(() => _selectedNavIndex = index);
        final route = routes[index];
        if (route != null) {
          Navigator.of(context).pushNamed(route);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.info : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(height: 4),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.info : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthProvider>().signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child:
                const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

/// Animated count-up text widget.
class _AnimatedCountText extends StatelessWidget {
  final String value;
  const _AnimatedCountText({required this.value});

  @override
  Widget build(BuildContext context) {
    // Parse numeric value for animation
    final numericStr = value.replaceAll(RegExp(r'[^0-9.]'), '');
    final suffix = value.replaceAll(RegExp(r'[0-9.]'), '');
    final number = double.tryParse(numericStr) ?? 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: number),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, _) {
        String display;
        if (number == number.roundToDouble()) {
          display = '${animValue.toInt()}$suffix';
        } else {
          display = '${animValue.toStringAsFixed(1)}$suffix';
        }
        return Text(
          display,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        );
      },
    );
  }
}
