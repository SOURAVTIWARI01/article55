import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/voting_provider.dart';
import '../widgets/candidate_card.dart';
import '../widgets/category_tab_bar.dart';
import '../widgets/vote_button.dart';

/// Category-based voting screen with single-select mode.
class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen>
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final flatNumber = auth.currentUser?.flatNumber ?? '';
      context.read<VotingProvider>().initialize(flatNumber);
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
                      Text(
                        'Cast Your Vote',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select one candidate per category',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
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

                // Candidate list
                Expanded(child: _buildCandidateList()),
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
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/results'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Results',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateList() {
    return Consumer2<VotingProvider, AuthProvider>(
      builder: (context, voting, auth, _) {
        if (voting.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final candidates =
            voting.candidatesByCategory[_currentCategory] ?? [];
        final hasVoted = voting.hasVotedIn(_currentCategory);

        if (candidates.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.how_to_vote_outlined,
                    size: 56, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  'No candidates yet',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Voted badge
            if (hasVoted)
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 24, right: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 18, color: AppColors.success),
                      const SizedBox(width: 8),
                      Text(
                        'You have voted in this category',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: candidates.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final candidate = candidates[index];
                  final voteCount = voting.getVoteCount(candidate.id);

                  return CandidateCard(
                    candidate: candidate,
                    trailing: VoteButton(
                      voteCount: voteCount,
                      isDisabled: hasVoted,
                      isSelected: false,
                      onTap: hasVoted
                          ? null
                          : () => _confirmVote(candidate.id, candidate.fullName),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmVote(String candidateId, String candidateName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Confirm Vote',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: RichText(
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            children: [
              const TextSpan(text: 'Vote for '),
              TextSpan(
                text: candidateName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text:
                    ' as ${CategoryTabBar.categories[_selectedTab]}? This action cannot be undone.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final auth = context.read<AuthProvider>();
              final voting = context.read<VotingProvider>();
              final success = await voting.castVote(
                userId: auth.currentUser?.id ?? '',
                flatNumber: auth.currentUser?.flatNumber ?? '',
                category: _currentCategory,
                candidateId: candidateId,
              );

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                      ? 'Vote cast successfully!'
                      : (voting.error ?? 'Vote failed')),
                  backgroundColor: success ? AppColors.success : AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Text('Confirm Vote',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
