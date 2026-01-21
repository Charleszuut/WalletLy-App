import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/formatters.dart';

class SummaryTiles extends StatelessWidget {
  const SummaryTiles({
    super.key,
    required this.totalIncome,
    required this.totalExpenses,
  });

  final double totalIncome;
  final double totalExpenses;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final tileWidth = constraints.maxWidth >= 440
            ? (constraints.maxWidth - spacing) / 2
            : constraints.maxWidth;
        final isCompact = tileWidth < 220;

        return Wrap(
          spacing: spacing,
          runSpacing: 12,
          children: [
            SizedBox(
              width: tileWidth,
              child: _SummaryTile(
                label: 'Total Income',
                amount: totalIncome,
                color: theme.colorScheme.primary,
                icon: Icons.arrow_downward,
                compact: isCompact,
              ),
            ),
            SizedBox(
              width: tileWidth,
              child: _SummaryTile(
                label: 'Total Expenses',
                amount: totalExpenses,
                color: theme.colorScheme.error,
                icon: Icons.arrow_upward,
                compact: isCompact,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    required this.compact,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.all(compact ? 12 : 16);
    final avatarRadius = compact ? 18.0 : 20.0;
    final labelStyle = GoogleFonts.spaceGrotesk(
      fontSize: compact ? 11 : 12.5,
      fontWeight: FontWeight.w600,
      color: color.withValues(alpha: 0.75),
    );
    final amountStyle = GoogleFonts.spaceGrotesk(
      fontSize: compact ? 16.5 : 18,
      fontWeight: FontWeight.w700,
      color: color,
    );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            offset: Offset(0, 8),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: compact ? 16 : 18),
          ),
          SizedBox(width: compact ? 12 : 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: labelStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: compact ? 2 : 4),
              Text(Formatters.currency.format(amount), style: amountStyle),
            ],
          ),
          if (!compact) const Spacer(),
        ],
      ),
    );
  }
}
