import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

/// A badge widget that displays the user's role (User / Admin).
class RoleBadge extends StatelessWidget {
  final String role;
  final double fontSize;

  const RoleBadge({
    super.key,
    required this.role,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = role.toLowerCase() == 'admin';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        gradient: isAdmin
            ? const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
              )
            : null,
        color: isAdmin ? null : AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: isAdmin
            ? null
            : Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin ? Icons.shield_outlined : Icons.verified,
            size: 14,
            color: isAdmin ? Colors.white : AppColors.success,
          ),
          const SizedBox(width: 6),
          Text(
            isAdmin ? 'Administrator' : 'Verified Voter',
            style: GoogleFonts.plusJakartaSans(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: isAdmin ? Colors.white : AppColors.success,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
