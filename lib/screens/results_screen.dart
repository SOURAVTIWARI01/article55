import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/candidate_model.dart';
import '../providers/voting_provider.dart';
import '../widgets/category_tab_bar.dart';

/// Live results screen with animated vote counts and progress bars.
class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();

    // Start realtime updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VotingProvider>().startRealtimeUpdates();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String get _currentCategory => CategoryTabBar.categoryKeys[_selectedTab];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: Theme.of(context).brightness == Brightness.dark ? AppColors.splashGradientDark : AppColors.splashGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.titleGradient.createShader(bounds),
                        child: Text(
                          'Live Results',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Updating in real-time',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Category tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: CategoryTabBar(
                    selectedIndex: _selectedTab,
                    onTabChanged: (i) => setState(() => _selectedTab = i),
                  ),
                ),
                const SizedBox(height: 20),

                // Results list
                Expanded(child: _buildResultsList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return Consumer<VotingProvider>(
      builder: (context, voting, _) {
        final candidates =
            voting.candidatesByCategory[_currentCategory] ?? [];

        if (candidates.isEmpty) {
          return Center(
            child: Text(
              'No candidates in this category',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          );
        }

        // Calculate total votes in this category
        int totalVotes = 0;
        for (final c in candidates) {
          totalVotes += voting.getVoteCount(c.id);
        }

        // Sort by votes (descending)
        final sorted = List<CandidateModel>.from(candidates)
          ..sort((a, b) =>
              voting.getVoteCount(b.id).compareTo(voting.getVoteCount(a.id)));

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: sorted.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final candidate = sorted[index];
            final votes = voting.getVoteCount(candidate.id);
            final pct = totalVotes > 0 ? votes / totalVotes : 0.0;
            final isLeading = index == 0 && votes > 0;

            return _buildResultCard(
              candidate: candidate,
              votes: votes,
              percentage: pct,
              rank: index + 1,
              isLeading: isLeading,
            );
          },
        );
      },
    );
  }

  Widget _buildResultCard({
    required CandidateModel candidate,
    required int votes,
    required double percentage,
    required int rank,
    required bool isLeading,
  }) {
    final color = _getCategoryColor(candidate.category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLeading
            ? color.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLeading
              ? color.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.6),
          width: isLeading ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2687).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isLeading ? color : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isLeading
                  ? const Icon(Icons.emoji_events, size: 18, color: Colors.white)
                  : Text(
                      '#$rank',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade500,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // Info + progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.fullName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: percentage),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 6,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$votes vote${votes != 1 ? 's' : ''}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: percentage * 100),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Text(
                          '${value.toStringAsFixed(1)}%',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        );
                      },
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'president':
        return AppColors.info;
      case 'secretary':
        return AppColors.accent;
      case 'treasurer':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }
}
